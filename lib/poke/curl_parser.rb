# frozen_string_literal: true

require 'json'

module Poke
  class CurlParser
    attr_reader :comments, :arguments, :url

    def initialize(content)
      @content = content
      @comments = []
      @arguments = []
      @tokens = []
      @url = nil
      parse
    end

    def to_command
      ['curl', *@tokens].join(' ')
    end

    def to_command_with_line_continuation
      ['curl', *@tokens].join(" \\\n  ")
    end

    # Fill in environment variables and shell-quote the result so it can be copied and run without poke.
    # Single-quoted text is left as-is, matching shell expansion rules.
    def to_resolved_command(variables, multiline: false)
      variables = variables.to_h.transform_keys(&:to_s)
      tokens = @tokens.map { |token| expand_shell_word(token, variables) }
      return ['curl', *tokens].join(' ') unless multiline

      multiline_command(tokens)
    end

    def add_argument(arg)
      @arguments << arg
      @tokens << arg
    end

    def remove_argument(pattern)
      @arguments.reject! { |arg| arg.match?(pattern) }
      @tokens.reject! { |arg| arg.match?(pattern) }
    end

    def replace_argument(pattern, replacement)
      @arguments.map! { |arg| arg.match?(pattern) ? replacement : arg }
      @tokens.map! { |arg| arg.match?(pattern) ? replacement : arg }
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
        @tokens << arg
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

    def multiline_command(tokens)
      lines = []
      index = 0

      while index < tokens.length
        token = tokens[index]
        nxt = tokens[index + 1]
        if (body = json_body_line(token, nxt))
          lines << body[:text]
          index += body[:consumed]
        elsif token.start_with?('-') && nxt && !nxt.start_with?('-')
          lines << "#{token} #{nxt}"
          index += 2
        else
          lines << token
          index += 1
        end
      end

      ['curl', *lines].join(" \\\n  ")
    end

    def json_body_line(token, nxt)
      flag, value, consumed = split_body_flag(token, nxt)
      return nil unless flag

      pretty = pretty_json_value(value)
      return nil unless pretty

      { text: "#{flag} #{pretty}", consumed: consumed }
    end

    def split_body_flag(token, nxt)
      JSON_BODY_FLAGS.each do |flag|
        return [flag, nxt, 2] if token == flag && nxt && !nxt.start_with?('-')

        if flag.start_with?('--') && token.start_with?("#{flag}=") && token.length > flag.length + 1
          return [flag, token[(flag.length + 1)..], 1]
        end

        if flag == '-d' && token.start_with?('-d') && !token.start_with?('--') && token.length > 2
          return ['-d', token[2..], 1]
        end
      end
      nil
    end

    def pretty_json_value(value)
      raw = unquote_shell(value)
      return nil if raw.nil?

      parsed = JSON.parse(raw)
      return nil unless parsed.is_a?(Hash) || parsed.is_a?(Array)

      pretty = JSON.pretty_generate(parsed)
      return nil unless pretty.include?("\n")

      quote_single(indent_json_block(pretty))
    rescue JSON::ParserError
      nil
    end

    def indent_json_block(pretty)
      pretty.lines.map.with_index { |line, index| index.zero? ? line : "  #{line}" }.join
    end

    def quote_single(value)
      "'#{value.gsub("'") { "'\\''" }}'"
    end

    def unquote_shell(word)
      if word.start_with?("'")
        decode_single_quoted(word)
      elsif word.start_with?('"') && word.end_with?('"') && word.length >= 2
        decode_double_quoted(word)
      else
        word
      end
    end

    def decode_single_quoted(word)
      result = +''
      index = 1
      return nil unless word[0] == "'"

      while index < word.length
        if word[index] == "'"
          index += 1
          return result if index == word.length
          return nil unless word[index, 2] == "\\'" && word[index + 2] == "'"

          result << "'"
          index += 3
        else
          result << word[index]
          index += 1
        end
      end

      nil
    end

    def decode_double_quoted(word)
      inner = word[1..-2]
      result = +''
      index = 0

      while index < inner.length
        if inner[index] == '\\' && index + 1 < inner.length
          result << inner[index + 1]
          index += 2
        else
          result << inner[index]
          index += 1
        end
      end

      result
    end

    def split_arguments(line)
      args = []
      current_arg = ""
      in_quotes = false
      quote_char = nil
      i = 0
      
      while i < line.length
        char = line[i]
        
        if !in_quotes && char == '\\' && i + 1 < line.length
          current_arg += char + line[i + 1]
          i += 2
          next
        elsif in_quotes && quote_char == '"' && char == '\\' && i + 1 < line.length
          current_arg += char + line[i + 1]
          i += 2
          next
        elsif !in_quotes && char.match?(/\s/)
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

    def expand_shell_word(word, variables)
      result = +''
      index = 0
      quote = nil

      while index < word.length
        char = word[index]

        if char == '\\' && quote != "'" && index + 1 < word.length
          result << char << word[index + 1]
          index += 2
          next
        end

        if quote.nil? && (char == "'" || char == '"')
          quote = char
          result << char
          index += 1
          next
        end

        if quote == char
          quote = nil
          result << char
          index += 1
          next
        end

        if quote != "'" && char == '$'
          name, consumed = read_variable(word, index)
          if name && variables.key?(name)
            result << substitute_value(variables[name].to_s, quote)
            index += consumed
            next
          end
        end

        result << char
        index += 1
      end

      result
    end

    def read_variable(word, index)
      suffix = word[index..]
      if (match = suffix.match(/\A\$\{([A-Za-z_][A-Za-z0-9_]*)\}/))
        [match[1], match[0].length]
      elsif (match = suffix.match(/\A\$([A-Za-z_][A-Za-z0-9_]*)/))
        [match[1], match[0].length]
      end
    end

    def substitute_value(value, quote)
      return escape_double_quoted(value) if quote == '"'
      return value if value.match?(UNQUOTED_SAFE)

      "'#{value.gsub("'") { "'\\''" }}'"
    end

    def escape_double_quoted(value)
      value.gsub(/[\\$"`]/) { |char| "\\#{char}" }
    end

    UNQUOTED_SAFE = /\A[A-Za-z0-9_\-.,:@%+\/=]+\z/.freeze
    JSON_BODY_FLAGS = %w[--data-ascii --data-binary --data-raw --data --json -d].freeze
    private_constant :UNQUOTED_SAFE, :JSON_BODY_FLAGS
  end
end 
