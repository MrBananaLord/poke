# frozen_string_literal: true

require_relative '../../command'
require_relative '../../config'

require 'tty-command'

module Poke
  module Commands
    class Lru
      class Reset < Poke::Command
        private

        def run
          TTY::Command.new(printer: :null).run("echo {} > #{Poke::Config.root_path}/lru.json")

          require_relative 'cat'
          Poke::Commands::Lru::Cat.new(@options).execute
        end
      end
    end
  end
end
