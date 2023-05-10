# frozen_string_literal: true

require_relative '../config'

require 'tty-command'

module Poke
  module Commands
    class Cat
      def initialize(file_name, options)
        @file_name = file_name
        @options = options
      end

      def execute(output: $stdout)
        raise Error unless %w[response lru].include?(@file_name)

        out, _err = TTY::Command.new(printer: :null).run("cat #{Poke::Config.root_path}/#{@file_name}.json")
        output << "#{out}\n"
      end
    end
  end
end
