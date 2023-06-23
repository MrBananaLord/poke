# frozen_string_literal: true

require 'thor'

module Poke
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    desc 'version', 'poke version'
    def version
      require_relative 'version'
      puts "v#{Poke::VERSION}"
    end
    map %w[--version -v] => :version

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
    method_option :print, aliases: '-p', type: :string, desc: 'Print out response body'
    method_option :open, aliases: '-o', type: :string, desc: 'Open request in the editor'
    method_option :set_alias, aliases: '-A', type: :string, desc: 'Set request alias'
    method_option :alias, aliases: '-a', type: :string, desc: 'Find request by alias instead of searching it'
    def curl(*)
      if options[:help]
        invoke :help, ['curl']
      else
        require_relative 'commands/curl'
        Poke::Commands::Curl.new(options).execute
      end
    end

    desc 'response', 'Print out last response'
    method_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'
    def response(*)
      if options[:help]
        invoke :help, ['response']
      else
        require_relative 'commands/response'
        Poke::Commands::Response.new(options).execute
      end
    end

    require_relative 'commands/lru'
    register Poke::Commands::Lru, 'lru', 'lru [SUBCOMMAND]', 'Manage usage statistics'

    default_task :curl

    def self.exit_on_failure?
      true
    end
  end
end
