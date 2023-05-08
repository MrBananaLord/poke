# frozen_string_literal: true

require "thor"

module Poke
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    desc "version", "poke version"
    def version
      require_relative "version"
      puts "v#{Poke::VERSION}"
    end
    map %w[--version -v] => :version

    desc "curl FILE", "Command description..."
    method_option :help, aliases: "-h", type: :boolean,
                         desc: "Display usage information"
    def curl(file)
      if options[:help]
        invoke :help, ["curl"]
      else
        require_relative "commands/curl"
        Poke::Commands::Curl.new(file, options).execute
      end
    end

    default_task :curl

    def self.exit_on_failure?
      true
    end
  end
end