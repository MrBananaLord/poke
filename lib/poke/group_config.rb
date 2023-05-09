# frozen_string_literal: true

require 'json'

module Poke
  class GroupConfig
    class InvalidEnv < StandardError; end

    def self.from_path(path)
      new(JSON.parse(File.read(path)))
    end

    def initialize(values = {})
      @values = values
    end

    def save_to(path)
      File.write(path, @values.to_json)
    end

    def valid_env?(env)
      @values['envs'].key?(env)
    end

    def default_env
      @values.fetch('default_env', @values['envs'].keys.first)
    end

    def default_env=(value)
      raise InvalidEnv unless valid_env?(value)

      @values['default_env'] = value
    end

    def envs
      @values['envs'].keys
    end

    def variables(env)
      @values['envs'][env]
    end
  end
end
