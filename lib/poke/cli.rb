# frozen_string_literal: true

require 'thor'

module Poke
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'poke version'
    def version
      require_relative 'version'
      puts "v#{Poke::VERSION}"
    end
    map %w[--version] => :version

    desc 'env', 'Display and edit environments'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def env(*)
      if options[:help]
        invoke :help, ['env']
      else
        require_relative 'commands/env'
        Poke::Commands::Env.new(options).execute
      end
    end

    desc 'curl', 'Find and execute a request'
    method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
    method_option :env, aliases: '-e', type: :string, desc: 'Set target environment'
    method_option :verbose, aliases: '-v', type: :string, desc: 'Print out response body'
    method_option :open, aliases: '-o', type: :string, desc: 'Open response in the editor'
    def curl(*)
      if options[:help]
        invoke :help, ['curl']
      else
        require_relative 'commands/curl'
        Poke::Commands::Curl.new(options).execute
      end
    end

    desc 'cat [FILE_NAME]', 'Print response or stats'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def cat(file_name = 'response')
      if options[:help]
        invoke :help, ['curl']
      else
        require_relative 'commands/cat'
        Poke::Commands::Cat.new(file_name, options).execute
      end
    end

    default_task :curl

    def self.exit_on_failure?
      true
    end
  end
end
