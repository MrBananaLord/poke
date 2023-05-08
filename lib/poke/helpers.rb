# frozen_string_literal: true

require 'pry'
require 'pry-nav'

module Poke
  module Helpers
    def execute(*)
      raise(
        NotImplementedError,
        "#{self.class}##{__method__} must be implemented"
      )
    end

    def command(options = {})
      @command ||= begin
        require 'tty-command'
        TTY::Command.new(**options)
      end
    end

    def prompt(options = {})
      @prompt ||= begin
        require 'tty-prompt'
        TTY::Prompt.new(**options)
      end
    end

    def pastel(options = {})
      @pastel ||= Pastel.new(**options)
    end

    def cursor
      @cursor ||= begin
        require 'tty-cursor'
        TTY::Cursor
      end
    end
  end
end
