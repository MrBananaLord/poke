# frozen_string_literal: true

require 'json'

module Poke
  class CurlParser
    attr_reader :comments, :arguments, :url

    def initialize(content)
      @content = content
      @comments = []
      @arguments = []
      @url = nil
      parse
    end

    def to_command
      parts = ['curl']
      parts.concat(@arguments)
      parts << @url if @url
      parts.join(' ')
    end

    def to_command_with_line_continuation
      parts = ['curl']
      parts.concat(@arguments)
      parts << @url if @url
      
      # Join with line continuation for better readability
      parts.join(" \\\n  ")
    end

    def add_argument(arg)
      @arguments << arg
    end

    def remove_argument(pattern)
      @arguments.reject! { |arg| arg.match?(pattern) }
    end

    def replace_argument(pattern, replacement)
      @arguments.map! do |arg|
        arg.match?(pattern) ? replacement : arg
      end
    end

    private

    def parse
      # Normalize line endings and ensure content ends with newline
      content = @content.gsub(/\r\n/, "\n").gsub(/\r/, "\n")
      content += "\n" unless content.end_with?("\n")

      # First, extract comments
      extract_comments(content)
      
      # Then parse the curl command
      parse_curl_content(content)
    end

    def extract_comments(content)
      content.each_line do |line|
        stripped = line.strip
        @comments << stripped if stripped.start_with?('#')
      end
    end

    def parse_curl_content(content)
      # Remove comments and empty lines
      curl_lines = content.lines.reject do |line|
        line.strip.empty? || line.strip.start_with?('#')
      end
      
      return if curl_lines.empty?
      
      # Join lines with continuations
      curl_content = join_continuations(curl_lines)
      
      # Parse the curl command
      parse_curl_command(curl_content)
    end

    def join_continuations(lines)
      result = ""
      i = 0
      
      while i < lines.length
        line = lines[i].chomp
        
        # Check if this line ends with continuation
        if line.end_with?('\\')
          result += line[0...-1] + " "
          i += 1
        else
          result += line + " "
          i += 1
        end
      end
      
      result.strip
    end

    def parse_curl_command(content)
      # Remove 'curl' command if present
      content = content.sub(/^\s*curl\s+/, '')
      
      # Split arguments while preserving quoted strings
      args = split_arguments(content)
      
      args.each do |arg|
        if arg.start_with?('-')
          @arguments << arg
        elsif @url.nil?
          @url = arg
        else
          # Additional arguments after URL
          @arguments << arg
        end
      end
    end

    def split_arguments(line)
      args = []
      current_arg = ""
      in_quotes = false
      quote_char = nil
      i = 0
      
      while i < line.length
        char = line[i]
        
        if !in_quotes && char.match?(/\s/)
          if !current_arg.empty?
            args << current_arg
            current_arg = ""
          end
        elsif !in_quotes && (char == '"' || char == "'")
          in_quotes = true
          quote_char = char
          current_arg += char
        elsif in_quotes && char == quote_char
          in_quotes = false
          quote_char = nil
          current_arg += char
        else
          current_arg += char
        end
        
        i += 1
      end
      
      args << current_arg unless current_arg.empty?
      args
    end
  end
end 
