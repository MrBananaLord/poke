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

    def self.from_path(path)
      new(name: path.parent.basename.to_s, config_path: "#{path.dirname}/config.json")
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

    def use_count
      LastRecentlyUsed.groups[name.to_s] || 0
    end
  end
end
