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

          new(group_name:, name:, path:)
        end
      end
    end

    attr_reader :path, :name, :group_name

    def initialize(path:, name:, group_name:)
      @path = path
      @name = name
      @group_name = group_name
    end

    def use_count
      LastRecentlyUsed.requests[path.to_s] || 0
    end

    def group
      Group.all.find { |g| g.name == group_name }
    end
  end
end
