# frozen_string_literal: true

require_relative '../helpers'
require_relative '../group_variables'
require 'json'
require 'pathname'

module Poke
  module Commands
    class Curl
      include Poke::Helpers

      def initialize(file, options)
        @file = file
        @options = options
      end

      def execute(output: $stdout, errors: $stderr)
        group_variables = GroupVariables.from_path("#{::Pathname.new(@file).dirname}/variables.json")

        env = @options.fetch(:env, group_variables.default_env)
        raise GroupVariables::InvalidEnv unless group_variables.valid_env?(env)

        errors << group_variables.variables(env)
        errors << "\n\n"

        out, err = begin
          command(printer: :null).run(group_variables.variables(env), @file)
        rescue StandardError
          TTY::Command::ExitError
        end
        errors << err
        output << "\n"

        output << out
        output << "\n"
      end
    end
  end
end
