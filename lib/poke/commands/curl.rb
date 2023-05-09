# frozen_string_literal: true

require_relative '../group'
require_relative '../config'
require_relative '../paint'

require 'pathname'
require 'pastel'

require 'tty-command'
require 'tty-editor'
require 'tty-table'

module Poke
  module Commands
    class Curl
      def initialize(options)
        @options = options
      end

      def execute(output: $stdout, errors: $stderr)
        output << Poke::Paint.welcome

        choices = Group.all.map do |group|
          group.requests.map do |request|
            { "#{group.name}: #{request.name}": request.path }
          end
        end.flatten

        path = TTY::Prompt.new.select('Select the endpoint', choices, filter: true, quiet: true)
        group = Poke::Group.from_path(path)

        env = @options.fetch(:env, group.config.default_env)
        raise Poke::GroupConfig::InvalidEnv unless group.config.valid_env?(env)

        table = TTY::Table.new(
          [["ENV", env]] +
          group.config.variables(env).to_a +
          [["CMD", TTY::Command.new(printer: :null).run("cat #{path}").out]]
        )
        output << table.render(:unicode, multiline: true)
        output << "\n\n"

        command = TTY::Command.new(printer: :null).run!(
          group.config.variables(env),
          path.to_s,
          out: Poke::Config.response_path
        )
        if command.failure?
          errors << Pastel.new.decorate(command.err, :red)
          output << Poke::Paint.farewell
          return
        else
          errors << Pastel.new.decorate(command.err, :green)
        end

        if @options.fetch(:verbose, nil)
          output << "\n#{File.read(Poke::Config.response_path)}\n"
        elsif @options.fetch(:open, nil)
          TTY::Editor.open(Poke::Config.response_path)
        else
          output << "\nResponse stored in #{Poke::Config.response_path}\n"
        end
        output << Poke::Paint.farewell
      end
    end
  end
end
