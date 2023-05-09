# frozen_string_literal: true

require_relative '../config'

require 'tty-command'

module Poke
  module Commands
    class Cat
      def initialize(options)
        @options = options
      end

      def execute(output: $stdout)
        out, _err = TTY::Command.new(printer: :null).run("cat #{Poke::Config.root_path}/response.json")
        output << "#{out}\n"
      end
    end
  end
end
