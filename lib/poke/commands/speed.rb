# frozen_string_literal: true

require_relative '../command'
require_relative '../group'
require_relative '../config'
require_relative '../paint'
require_relative '../last_recently_used'
require_relative '../curl_parser'

require 'pathname'
require 'pastel'

require 'tty-command'
require 'tty-editor'
require 'tty-table'

module Poke
  module Commands
    class Speed < Poke::Command
      WRITE_OUT_FIELDS = {
        'response_code' => ->(e) { e },
        'time_total' => ->(e) { format('%.2fms', (e * 1000)) }
      }.freeze

      private

      def run(output: $stdout, errors: $stderr)
        if (name = @options.fetch(:name, nil))
          request = Request.find_by_name(Config.find_request_name_by_alias(name))
        else
          errors << "Please define the target endpoint with -n or --name\n"
          return
        end

        request.use!
        request.group.use!

        env = @options.fetch(:env, request.group.config.default_env)
        raise Poke::GroupConfig::InvalidEnv unless request.group.config.valid_env?(env)

        curl_command, comments = build_command(request.path)

        table = TTY::Table.new(
          [['ENV', env]] +
          request.group.config.variables(env).to_a +
          [['CMD', curl_command]] +
          [['COMMENTS', comments]]
        )
        errors << table.render(:unicode, multiline: true, padding: [0, 1, 0, 1])
        errors << "\n\n"


        times = []
        count = @options.fetch(:count, 10)

        errors << "Running speed test for #{request.name} #{count} times\n\n"

        count.to_i.times do
          command = TTY::Command.new(printer: :null).run!(
            request.group.config.variables(env),
            curl_command
          )

          if command.failure?
            output << Pastel.new.decorate(command.err, :red)
          else
            errors << Pastel.new.decorate(command.err, :green)
            errors << "\n"
            stats = JSON.parse(command.out)
            times << stats['time_total']

            table = TTY::Table.new(WRITE_OUT_FIELDS.map { |field, lambda| [field, lambda.call(stats[field])] }.to_a)
            errors << table.render(:unicode, padding: [0, 1, 0, 1])
            errors << "\n\n"
          end
        end
        errors << "Run count: #{count}\nAverage time: #{format('%.2fms', (times.sum / times.size * 1000))}\n\n"
      end

      def build_command(path)
        content = File.read(path)
        parser = CurlParser.new(content)
        
        # Add our additional curl parameters
        parser.add_argument("-o #{Poke::Config.response_path}")
        parser.add_argument('-w "%{json}"')
        
        [parser.to_command_with_line_continuation, parser.comments.join("\n")]
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
