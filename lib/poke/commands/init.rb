# frozen_string_literal: true

require_relative '../command'
require_relative '../config'

module Poke
  module Commands
    class Init < Poke::Command
      EXAMPLE_CONFIG = {
        "envs": {
          "development": {
            "BASE_URL": 'https://httpbin.org'
          },
          "production": {
            "BASE_URL": 'https://httpbin.org'
          }
        },
        "default_env": 'development'
      }.freeze

      private

      def run
        return if ::Poke::Config.valid?

        Dir.mkdir("#{Dir.home}/.poke")

        create_config_files
        create_example_api
      end

      def create_config_files
        File.write(Config.aliases_path, {}.to_json)
        File.write(Config.lru_path, {}.to_json)
        File.write(Config.response_path, {}.to_json)
      end

      def create_example_api
        Dir.mkdir("#{Dir.home}/.poke/example_api")
        File.write("#{Dir.home}/.poke/example_api/config.json", EXAMPLE_CONFIG.to_json)
        File.write("#{Dir.home}/.poke/example_api/example_get.curl", 'curl $BASE_URL/get -G -d foo=bar')
      end
    end
  end
end
