# frozen_string_literal: true

require_relative '../command'
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
    class Curl < Poke::Command
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
      }.freeze

      private

      def run(output: $stdout, errors: $stderr)
        if (name = @options.fetch(:name, nil))
          path = Config.find_by_alias(name)
        else
          choices = Request.all.sort_by(&:use_count).reverse.map { |r| { r.name => r.path } }
          path = TTY::Prompt.new.select('Select the endpoint', choices, filter: true, quiet: true)
        end
        LastRecentlyUsed.use!(namespace: 'requests', key: path)
        group = Poke::Group.from_request_path(path)
        LastRecentlyUsed.use!(namespace: 'groups', key: group.name)

        if (name = @options.fetch(:set_name, nil))
          Config.set_alias!(name, path)
          output << "#{path} aliased to #{name}\n\n"
          return
        end

        return TTY::Editor.open(path) if @options.fetch(:open, nil)

        env = @options.fetch(:env, group.config.default_env)
        raise Poke::GroupConfig::InvalidEnv unless group.config.valid_env?(env)

        curl_command, comments = build_command(path)

        table = TTY::Table.new(
          [['ENV', env]] +
          group.config.variables(env).to_a +
          [['CMD', curl_command]] +
          [['COMMENTS', comments]]
        )
        errors << table.render(:unicode, multiline: true, padding: [0, 1, 0, 1])
        errors << "\n\n"

        command = TTY::Command.new(printer: :null).run!(
          group.config.variables(env),
          curl_command
        )
        if command.failure?
          output << Pastel.new.decorate(command.err, :red)
          output << Poke::Paint.farewell
          return
        else
          errors << Pastel.new.decorate(command.err, :green)
          errors << "\n"
          stats = JSON.parse(command.out)

          table = TTY::Table.new(WRITE_OUT_FIELDS.map { |field, lambda| [field, lambda.call(stats[field])] }.to_a)
          errors << table.render(:unicode, padding: [0, 1, 0, 1])
          errors << "\n\n"

          errors << " source file:   #{Pastel.new.decorate(path.to_s, :magenta)}\n"
          errors << " request url:   #{Pastel.new.decorate(stats['url'], :blue)}\n"
          errors << " response path: #{Pastel.new.decorate(stats['filename_effective'], :magenta)}\n"
        end

        output << "\n#{File.read(Poke::Config.response_path)}\n"
      end

      def build_command(path)
        out = TTY::Command.new(printer: :null).run("cat #{path}").out
        out << "\n" unless out[-1] == "\n"

        command_lines = out.split(" \\\n").map(&:strip)

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
