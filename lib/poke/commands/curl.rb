# frozen_string_literal: true

require_relative '../command'
require 'json'
require 'pathname'
require 'pry'

module Poke
  module Commands
    class Curl < Poke::Command
      def initialize(file, options)
        @file = file
        @options = options
      end

      def execute(input: $stdin, output: $stdout, errors: $stderr)
        # home = command(printer: :quiet).run('echo $HOME').out.strip
        # endpoints = command(printer: :null).run('find $HOME/.poke -name "*.curl"')

        # endpoint = prompt.select('Select the endpoint', endpoints.out.split("\n"), filter: true)

        env = 'development' # TODO: how to pass options
        variables = JSON.parse(File.read("#{::Pathname.new(@file).dirname}/variables.json"))[env]
        # variables = variables.map { |e| e.join('=') }
        errors << variables
        errors << "\n\n"

        out, err = command(printer: :null).run(variables, @file) rescue TTY::Command::ExitError 
        errors << err
        output << "\n"

        output << out
        output << "\n"

        # File.open("#{home}/.poke/response.json", 'w+') do |file|
        #   file.write command(printer: :null, pty: true).run("#{variables} #{endpoint}").out
        # end

        # require 'tty-editor'
        # TTY::Editor.open("#{home}/.poke/response.json")
      end
    end
  end
end
