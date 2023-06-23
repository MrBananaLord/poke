# frozen_string_literal: true

require_relative '../config'

module Poke
  module Commands
    class Lru < Thor
      namespace :lru

      desc 'reset', 'Reset usage statistics'
      def reset(*)
        if options[:help]
          invoke :help, ['reset']
        else
          require_relative 'lru/reset'
          Poke::Commands::Lru::Reset.new(options).execute
        end
      end

      desc 'cat', 'Display usage statistics'
      def cat(*)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'lru/cat'
          Poke::Commands::Lru::Cat.new(options).execute
        end
      end
    end
  end
end
