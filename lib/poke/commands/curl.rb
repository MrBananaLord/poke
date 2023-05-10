# frozen_string_literal: true

require_relative '../group'
require_relative '../config'
require_relative '../paint'
require_relative '../last_recently_used'

require 'pathname'
require 'pastel'

require 'tty-command'
require 'tty-editor'
require 'tty-table'

module Poke
  module Commands
    class Curl
      WRITE_OUT_FIELDS = {
        'response_code' => ->(e) { e },
        'size_download' => ->(e) { format('%.2fkB', (e / 1000)) },
        'time_appconnect' => ->(e) { format('%.2fms', (e * 1000)) },
        'time_connect' => ->(e) { format('%.2fms', (e * 1000)) },
        'time_namelookup' => ->(e) { format('%.2fms', (e * 1000)) },
        'time_pretransfer' => ->(e) { format('%.2fms', (e * 1000)) },
        'time_redirect' => ->(e) { format('%.2fms', (e * 1000)) },
        'time_starttransfer' => ->(e) { format('%.2fms', (e * 1000)) },
        'time_total' => ->(e) { format('%.2fms', (e * 1000)) }
      }

      def initialize(options)
        @options = options
      end

      def execute(output: $stdout, errors: $stderr)
        output << Poke::Paint.welcome

        choices = Request.all.sort_by(&:use_count).reverse.map do |request|
          { "#{request.group_name}: #{request.name}": request.path }
        end

        path = TTY::Prompt.new.select('Select the endpoint', choices, filter: true, quiet: true)
        LastRecentlyUsed.use!(namespace: 'requests', key: path)
        group = Poke::Group.from_path(path)
        LastRecentlyUsed.use!(namespace: 'group', key: group.name)

        env = @options.fetch(:env, group.config.default_env)
        raise Poke::GroupConfig::InvalidEnv unless group.config.valid_env?(env)

        curl_command, comments = build_command(path)

        table = TTY::Table.new(
          [['ENV', env]] +
          group.config.variables(env).to_a +
          [['CMD', curl_command]] +
          [['COMMENTS', comments]]
        )
        output << table.render(:unicode, multiline: true, padding: [0, 1, 0, 1])
        output << "\n\n"

        command = TTY::Command.new(printer: :null).run!(
          group.config.variables(env),
          curl_command
        )
        if command.failure?
          errors << Pastel.new.decorate(command.err, :red)
          output << Poke::Paint.farewell
          return
        else
          errors << Pastel.new.decorate(command.err, :green)
          output << "\n"
          stats = JSON.parse(command.out)

          table = TTY::Table.new(WRITE_OUT_FIELDS.map { |field, lambda| [field, lambda.call(stats[field])] }.to_a)
          output << table.render(:unicode, padding: [0, 1, 0, 1])
          output << "\n\n"
          output << " request url:   #{Pastel.new.decorate(stats['url'], :blue)}\n"
          output << " response path: #{Pastel.new.decorate(stats['filename_effective'], :magenta)}\n"

        end

        if @options.fetch(:verbose, nil)
          output << "\n#{File.read(Poke::Config.response_path)}\n"
        elsif @options.fetch(:open, nil)
          TTY::Editor.open(Poke::Config.response_path)
        end
        output << Poke::Paint.farewell
      end

      private

      def build_command(path)
        command_lines = TTY::Command.new(printer: :null).run("cat #{path}").out.split(" \\\n").map(&:strip)
        comments = command_lines.filter { |line| line.start_with?('#') }.join(" \\\n")
        command_lines = command_lines.reject { |line| line.start_with?('#') }
        command_lines += additional_curl_params

        [command_lines.join(" \\\n  "), comments]
      end

      # rubocop:disable Style/FormatStringToken
      def additional_curl_params
        [
          "-o #{Poke::Config.response_path}",
          '-w "%{json}"'
        ]
      end
      # rubocop:enable Style/FormatStringToken
    end
  end
end
