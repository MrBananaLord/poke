# frozen_string_literal: true

require_relative 'lib/poke/version'

Gem::Specification.new do |spec|
  spec.name = 'poke'
  spec.license = 'MIT'
  spec.version = Poke::VERSION
  spec.authors = ['Jan Bator']
  spec.email = ['jan@bloomandwild.com']

  spec.summary = 'manage curl requests'
  spec.homepage = 'https://github.com/MrBananaLord/poke'
  spec.required_ruby_version = '>= 2.6.0'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/MrBananaLord/poke'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions = ['ext/poke/extconf.rb']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_dependency 'pastel', '~> 0.8'
  spec.add_dependency 'thor', '~> 1.0'

  # Draw various frames and boxes in terminal window.
  spec.add_dependency 'tty-box', '~> 0.7'

  # Terminal color capabilities detection.
  # spec.add_dependency "tty-color", "~> 0.6"

  # Execute shell commands with pretty logging.
  spec.add_dependency 'tty-command', '~> 0.10'

  # Define, read and write app configurations.
  # spec.add_dependency "tty-config", "~> 0.4"

  # Terminal cursor positioning, visibility and text manipulation.
  spec.add_dependency 'tty-cursor', '~> 0.7'

  # Open a file or text in a terminal text editor.
  spec.add_dependency 'tty-editor', '~> 0.6'

  # Terminal exit codes for humans and machines.
  # spec.add_dependency "tty-exit", "~> 0.1"

  # File and directory manipulation utility methods.
  # spec.add_dependency "tty-file", "~> 0.10"

  # Write text out to terminal in large stylized characters.
  # spec.add_dependency "tty-font", "~> 0.5"

  # Hyperlinks in terminal.
  # spec.add_dependency "tty-link", "~> 0.1"

  # A readable, structured and beautiful logging for the terminal.
  # spec.add_dependency "tty-logger", "~> 0.6"

  # Convert a markdown document or text into a terminal friendly output.
  # spec.add_dependency "tty-markdown", "~> 0.7"

  # Parser for command line arguments, keywords and options.
  # spec.add_dependency "tty-option", "~> 0.1"

  # A cross-platform terminal pager.
  # spec.add_dependency "tty-pager", "~> 0.14"

  # Draw pie charts in your terminal window.
  # spec.add_dependency "tty-pie", "~> 0.4"

  # Detect different operating systems.
  # spec.add_dependency "tty-platform", "~> 0.3"

  # A flexible and extensible progress bar for terminal applications.
  # spec.add_dependency "tty-progressbar", "~> 0.18"

  # A beautiful and powerful interactive command line prompt.
  # spec.add_dependency "tty-prompt", "~> 0.23"

  # Terminal screen properties detection.
  # spec.add_dependency "tty-screen", "~> 0.8"

  # A terminal spinner for tasks with non-deterministic time.
  # spec.add_dependency "tty-spinner", "~> 0.9"

  # A flexible and intuitive table output generator.
  spec.add_dependency 'tty-table', '~> 0.12'

  # Print directory or structured data in a tree like format.
  # spec.add_dependency "tty-tree", "~> 0.4"

  # Platform independent implementation of Unix which command.
  # spec.add_dependency "tty-which", "~> 0.4"
end
