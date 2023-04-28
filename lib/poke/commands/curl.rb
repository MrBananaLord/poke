# frozen_string_literal: true

require_relative "../command"

module Poke
  module Commands
    class Curl < Poke::Command
      def initialize(file, options)
        @file = file
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...
        output.puts "OK"
      end
    end
  end
end
