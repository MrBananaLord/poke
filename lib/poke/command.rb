# frozen_string_literal: true

module Poke
  class Command
    # Execute this command
    #
    # @api public
    def execute(*)
      raise(
        NotImplementedError,
        "#{self.class}##{__method__} must be implemented"
      )
    end

    # Below are examples of how to integrate TTY components

    # The external commands runner
    #
    # @see http://www.rubydoc.info/gems/tty-command
    #
    # @api public
    # def command(**options)
    #   require "tty-command"
    #   TTY::Command.new(options)
    # end

    # The interactive prompt
    #
    # @see http://www.rubydoc.info/gems/tty-prompt
    #
    # @api public
    # def prompt(**options)
    #   require "tty-prompt"
    #   TTY::Prompt.new(options)
    # end
  end
end
