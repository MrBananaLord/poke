# frozen_string_literal: true

require_relative '../command'
require_relative '../group'

require 'json'
require 'tty-editor'
require 'tty-prompt'

module Poke
  module Commands
    class Env < Poke::Command
      private

      def run(output: $stdout)
        groups = Poke::Group.all
        group_name = TTY::Prompt.new.select('Select the group', groups.map(&:name), filter: true, quiet: true)
        group = groups.find { |g| g.name == group_name }

        if @options[:open]
          TTY::Editor.open(group.config_path)
        else
          output.puts JSON.pretty_generate(group.config.to_h)
        end
      end
    end
  end
end
