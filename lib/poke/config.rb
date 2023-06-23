# frozen_string_literal: true

require 'json'

module Poke
  class Config
    class NotFound < StandardError; end

    PATH = "#{Dir.home}/.poke.json".freeze
    DEFAULT_ROOT_PATH = "#{Dir.home}/.poke".freeze

    def self.all
      @all ||= begin
        config = File.exist?(PATH) ? JSON.parse(File.read(PATH)) : {}
        config['root_path'] ||= DEFAULT_ROOT_PATH
        config
      end
    end

    def self.root_path
      all['root_path']
    end

    def self.response_path
      [root_path, 'response.json'].join('/')
    end

    def self.lru_path
      [root_path, 'lru.json'].join('/')
    end

    def self.find_request_name_by_alias(value)
      result = all.dig('aliases', value)
      raise NotFound unless result

      result
    end

    def self.set_alias!(value, path)
      all['aliases'] ||= {}
      all['aliases'][value] = path.to_s
      File.write(PATH, all.to_json)
    end
  end
end
