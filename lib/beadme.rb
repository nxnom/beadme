require 'yaml'

module Beadme
  module Utils
    # Find a file or directory in the project
    # Raises an error if the file or directory does not exist
    def self.get_path(*path_parts, root: File.join(__dir__, '..'))
      path = File.join(root, *path_parts)
      unless File.exist?(path)
        raise ArgumentError,
              "File or directory does not exist: #{path}"
      end
      path
    end

    # Load a YAML file and convert all keys to symbols
    def self.load_yaml(file)
      YAML.load_file(file).transform_keys(&:to_sym)
    end
  end

  class Defaults
    TEMPLATE_FILE = Utils.get_path('templates', 'microverse.md.erb')
    QUESTIONS_FILE = Utils.get_path('config', 'questions.yml')
    MESSAGES_FILE = Utils.get_path('config', 'messages.yml')
  end

  class Configuration
    def default_template
      File.read(Defaults::TEMPLATE_FILE)
    end

    def default_questions
      Utils.load_yaml(Defaults::QUESTIONS_FILE)
    end

    # Get messages like welcome, help, etc.
    # To display them in the terminal
    def messages
      Utils.load_yaml(Defaults::MESSAGES_FILE)
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
