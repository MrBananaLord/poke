# frozen_string_literal: true

module Poke
  class Command
    class NotImplementedError < StandardError; end

    def initialize(options = {})
      @options = options
    end

    def execute(args = {})
      run(*args)
    end

    private

    def run
      raise NotImplementedError
    end
  end
end
