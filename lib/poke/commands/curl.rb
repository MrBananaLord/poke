# frozen_string_literal: true

require_relative "../command"

module Poke
  module Commands
    class Curl < Poke::Command
      def initialize(file, options)
        @file = file
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        # home = command(printer: :null).run('echo $HOME').out.strip
        # endpoints = command(printer: :null).run('find $HOME/.poke -name "*.curl"')

        # endpoint = prompt.select('Select the endpoint', endpoints.out.split("\n"), filter: true)

        # env = 'development' # TODO: how to pass options
        # variables = JSON.parse(File.read("#{::Pathname.new(endpoint).dirname}/variables.json"))[env]
        # variables = variables.map { |e| e.join('=') }.flatten.join(' ')

        # File.open("#{home}/.poke/response.json", 'w+') do |file|
        #   file.write command(printer: :null, pty: true).run("#{variables} #{endpoint}").out
        # end

        # require 'tty-editor'
        # TTY::Editor.open("#{home}/.poke/response.json")
        output.puts "OK"
      end
    end
  end
end
