# frozen_string_literal: true

require_relative '../command'
require_relative '../config'

require 'fileutils'
require 'pathname'
require 'tty-editor'
require 'tty-prompt'

module Poke
  module Commands
    class New < Poke::Command
      CREATE_NEW_DIR = :create_new_dir
      TEMPLATE = "curl $BASE_URL/get -G -d foo=bar\n".freeze

      private

      def run(output: $stdout, errors: $stderr)
        unless Config.valid?
          errors << "Config not initialized. Run `poke init` first.\n"
          return
        end

        prompt = TTY::Prompt.new(interrupt: :exit)
        directory = choose_directory(prompt)
        filename = choose_filename(prompt)
        request_path = build_request_path(directory, filename)

        if File.exist?(request_path) && !prompt.yes?('Request exists. Overwrite?')
          output << "Canceled.\n"
          return
        end

        File.write(request_path, TEMPLATE)
        TTY::Editor.open(request_path)
        output << "Created request: #{request_path}\n"
      rescue ArgumentError => e
        errors << "#{e.message}\n"
      end

      def choose_directory(prompt)
        choices = discover_directories
        labeled_choices = choices.map { |path| { name: relative_path(path), value: path } }
        labeled_choices << { name: '[Create new directory]', value: CREATE_NEW_DIR }

        selection = prompt.select(
          'Select directory under ~/.poke',
          labeled_choices,
          filter: true,
          quiet: true
        )

        return selection unless selection == CREATE_NEW_DIR

        input = prompt.ask('New directory path under ~/.poke', required: true)
        target = build_target_path(input)
        FileUtils.mkdir_p(target)
        target
      end

      def choose_filename(prompt)
        input = prompt.ask('Request name', required: true)&.strip
        raise ArgumentError, 'Request name cannot be empty' if input.nil? || input.empty?
        raise ArgumentError, 'Request name must not include path separators' if input.include?('/')

        name = input.gsub(/\.curl\z/, '')
        "#{name}.curl"
      end

      def discover_directories
        root = File.expand_path(Config.root_path)

        Dir.glob("#{root}/**/")
          .map { |path| File.expand_path(path).sub(%r{/\z}, '') }
          .uniq
          .reject { |path| path == root }
          .sort
      end

      def build_request_path(directory, filename)
        target = Pathname.new(File.join(directory, filename)).cleanpath.to_s
        ensure_inside_root!(target)
        target
      end

      def build_target_path(relative_input)
        target = Pathname.new(File.expand_path(File.join(Config.root_path, relative_input.to_s))).cleanpath.to_s

        raise ArgumentError, 'Directory must be a subdirectory of ~/.poke' if target == File.expand_path(Config.root_path)

        ensure_inside_root!(target)
        target
      end

      def ensure_inside_root!(path)
        root = File.expand_path(Config.root_path)
        root_prefix = "#{root}/"
        return if path.start_with?(root_prefix)

        raise ArgumentError, 'Path must stay inside ~/.poke'
      end

      def relative_path(path)
        Pathname.new(path).relative_path_from(Pathname.new(File.expand_path(Config.root_path))).to_s
      end
    end
  end
end
