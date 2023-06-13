# frozen_string_literal: true

require_relative '../../command'
require_relative '../../config'

require 'tty-command'

module Poke
  module Commands
    class Lru
      class Cat < Poke::Command
        private

        def run(output: $stdout)
          out, _err = TTY::Command.new(printer: :null).run("cat #{Poke::Config.root_path}/lru.json")
          output << out.to_s
        end
      end
    end
  end
end
