# frozen_string_literal: true

require 'json'

module Poke
  class Config
    class NotFound < StandardError; end

    ROOT_PATH = "#{Dir.home}/.poke".freeze

    def self.root_path
      ROOT_PATH
    end

    def self.valid?
      Dir.exist?("#{Dir.home}/.poke") &&
        File.exist?("#{Dir.home}/.poke/aliases.json") &&
        File.exist?("#{Dir.home}/.poke/lru.json") &&
        File.exist?("#{Dir.home}/.poke/response.json")
    end

    def self.response_path
      [root_path, 'response.json'].join('/')
    end

    def self.lru_path
      [root_path, 'lru.json'].join('/')
    end

    def self.aliases_path
      [root_path, 'aliases.json'].join('/')
    end

    def self.aliases
      @aliases ||= JSON.parse(File.read(aliases_path))
    end

    def self.find_request_name_by_alias(value)
      result = aliases[value]

      raise NotFound unless result

      result
    end

    def self.find_alias_by_request_name(value)
      aliases.find { |_k, v| v == value }&.first
    end

    def self.set_alias!(value, path)
      aliases[value] = path.to_s
      File.write(aliases_path, aliases.to_json)
    end
  end
end
