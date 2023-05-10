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
      all[namespace][key.to_s] ||= 0
      all[namespace][key.to_s] += 1

      File.write(Poke::Config.lru_path, all.to_json)
    end
  end
end
