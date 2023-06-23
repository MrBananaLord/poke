# frozen_string_literal: true

require_relative './group_config'
require_relative './request'

require 'pathname'
require 'json'

require 'tty-command'

module Poke
  class Group
    def self.all
      @all ||= begin
        config_paths = TTY::Command.new(printer: :null).run("find #{Dir.home}/.poke -name 'config.json'").out.split("\n")

        config_paths.map do |config_path|
          name = ::Pathname.new(config_path).parent.basename.to_s
          new(name:, config_path:)
        end
      end
    end

    def self.from_request_path(path)
      group_name = path.to_s.gsub(%r{#{Config.root_path}/([^\/]+)/.*}, '\1')
      new(name: group_name, config_path: "#{Config.root_path}/#{group_name}/config.json")
    end

    attr_reader :name, :config_path, :config

    def initialize(name:, config_path:)
      @name = name
      @config_path = config_path
      @config = Poke::GroupConfig.from_path(config_path)
    end

    def save_config!
      @config.save_to(@config_path)
    end

    def requests
      @requests ||= Request.all.filter { |request| request.group_name == name }
    end
  end
end
