# frozen_string_literal: true

require_relative '../command'
require_relative '../config'

require 'tty-command'

module Poke
  module Commands
    class Response < Poke::Command
      private

      def run(output: $stdout)
        out, _err = TTY::Command.new(printer: :null).run("cat #{Poke::Config.response_path}")
        output << "#{out}\n"
      end
    end
  end
end
