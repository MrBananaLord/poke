# frozen_string_literal: true

require_relative '../helpers'
require_relative '../group_variables'

require 'json'
require 'tty-table'

module Poke
  module Commands
    class Env
      include Poke::Helpers

      def initialize(options)
        @options = options
        @config_paths = command(printer: :null).run('find $HOME/.poke -name "variables.json"').out.split("\n")
        @group_names = @config_paths.map { |path| Pathname.new(path).parent.basename.to_s }
      end

      def execute(output: $stdout)
        group_name = prompt.select('Select the group', @group_names, filter: true, quiet: true)

        manage_group_config(output:, group_name:)
      end

      private

      def manage_group_config(output:, group_name:)
        loop do
          group_variables = GroupVariables.from_path(@config_paths[@group_names.index(group_name)])

          output << cursor.save

          render(output, group_name, group_variables)

          case prompt.keypress('q → quit | s → set default env', quiet: true)
          when 's'
            group_variables.default_env = prompt.select('Select new default environment', group_variables.envs,
                                                        filter: true, quiet: true)
            group_variables.save_to(@config_paths[@group_names.index(group_name)])

            output << cursor.restore
            output << cursor.clear_screen_down
          when 'q'
            output << "kthxbye\n"
            break
          end
        end
      end

      def render(output, group, group_variables)
        output << pastel.decorate(group.upcase, :magenta, :underline, :bold)
        output << " (default env: #{group_variables.default_env})"
        output << "\n"

        table = TTY::Table.new(
          header: ['env \\ var', *group_variables.variables(group_variables.default_env).keys],
          rows: group_variables.envs.map do |name|
            [name, *group_variables.variables(name).values]
          end
        )

        output << TTY::Table::Renderer::Unicode.new(table).render
        output << "\n"
      end
    end
  end
end
