# frozen_string_literal: true

require_relative '../command'
require_relative '../config'

require 'tty-command'
require 'tty-editor'

module Poke
  module Commands
    class Config < Poke::Command
      private

      def run(output: $stdout)
        return TTY::Editor.open(Poke::Config::PATH) if @options.fetch(:open, nil)

        out, _err = TTY::Command.new(printer: :null).run("cat #{Poke::Config::PATH}")
        output << "#{out}\n"
      end
    end
  end
end
