# frozen_string_literal: true

require_relative './group'

require 'pathname'

require 'tty-command'

module Poke
  class Request
    def self.all
      @all ||= begin
        request_paths = TTY::Command.new(printer: :null).run("find #{Dir.home}/.poke -name '*.curl'").out.split("\n")

        request_paths.map do |path|
          path = Pathname.new(path)

          group_name = path.to_s.gsub(%r{#{Config.root_path}/([^\/]+)/.*}, '\1')
          name = path.to_s.gsub(%r{#{Config.root_path}/(.*)\.curl}, '\1')
          alias_name = Config.find_alias_by_request_name(name)

          new(group_name:, name:, alias_name:, path:)
        end
      end
    end

    def self.find_by_name(name)
      all.find { |request| request.name == name }
    end

    attr_reader :path, :name, :alias_name, :group_name

    def initialize(path:, name:, alias_name:, group_name:)
      @path = path
      @name = name
      @alias_name = alias_name
      @group_name = group_name
    end

    def name_with_alias
      "#{name}#{alias_name ? " (#{alias_name})" : ''}"
    end

    def position
      LastRecentlyUsed.position(namespace: 'requests', key: name.to_s)
    end

    def use!
      LastRecentlyUsed.use!(namespace: 'requests', key: name.to_s)
    end

    def group
      Group.all.find { |g| g.name == group_name }
    end
  end
end
