# frozen_string_literal: true

require_relative './config'

require 'json'

module Poke
  class LastRecentlyUsed
    def self.all
      @all ||= if File.exist?(Poke::Config.lru_path)
                 JSON.parse(File.read(Poke::Config.lru_path))
               else
                 {}
               end
    end

    def self.groups
      all['groups'] ||= {}
    end

    def self.requests
      all['requests'] ||= {}
    end

    def self.use!(namespace:, key:)
      all[namespace] ||= {}
      all[namespace]['lru'] ||= []
      all[namespace]['lru'].delete(key.to_s)
      all[namespace]['lru'].unshift(key.to_s)

      File.write(Poke::Config.lru_path, all.to_json)
    end

    def self.position(namespace:, key:)
      all.dig(namespace, 'lru')&.index(key) || Float::INFINITY
    end
  end
end
