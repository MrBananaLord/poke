# frozen_string_literal: true

require_relative '../group'
require_relative '../paint'

require 'pastel'

require 'tty-box'
require 'tty-command'
require 'tty-cursor'
require 'tty-editor'
require 'tty-prompt'
require 'tty-table'

module Poke
  module Commands
    class Env
      def initialize(options)
        @options = options
      end

      def execute(output: $stdout)
        output << Poke::Paint.welcome
        groups = Poke::Group.all
        group_name = TTY::Prompt.new.select('Select the group', groups.map(&:name), filter: true, quiet: true)
        group = groups.find { |g| g.name == group_name }

        manage_group_config(output:, group:)
      end

      private

      def cursor
        @cursor ||= TTY::Cursor
      end

      def pastel
        @pastel ||= Pastel.new
      end

      def manage_group_config(output:, group:)
        output << cursor.save

        render(output, group)

        loop do
          case TTY::Prompt.new.keypress('', quiet: true)
          when 'c'
            group.config.default_env = TTY::Prompt.new.select(
              'Select new default environment', group.config.envs,
              filter: true, quiet: true
            )
            group.save_config!

            render(output, group)
          when 'e'
            TTY::Editor.open(group.config_path)
            output << Poke::Paint.farewell
            break
          when 'q'
            output << Poke::Paint.farewell
            break
          end
        end
      end

      def render(output, group)
        output << cursor.restore
        output << cursor.clear_screen_down

        title = ['| ', pastel.decorate(group.name.upcase, :yellow, :underline, :bold), ' |'].join
        footer = '| q → quit | c → change default env | e → edit config file |'
        table = TTY::Table.new(
          header: ['env \\ var', *group.config.variables(group.config.default_env).keys],
          rows: group.config.envs.map do |name|
            [name, *group.config.variables(name).values]
          end
        )

        # output << "\n"
        output << TTY::Box.frame(align: :center, title: { top_center: title, bottom_center: footer }) do
          [
            "(default env: #{group.config.default_env})\n\n",
            TTY::Table::Renderer::Unicode.new(table).render
          ].join('')
        end
      end
    end
  end
end
