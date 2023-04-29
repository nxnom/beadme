require 'thor'

require_relative 'template'
require_relative 'version'
require_relative '../beadme'

module Beadme
  class Runner < Thor
    class_option :output, aliases: '-o', type: :string, desc: 'Output directory (default: current directory)'

    desc 'create', 'Create a new Readme file', hide: true
    def create
      say "#{Beadme.configuration.messages[:welcome]}\n"
      puts options[:output]

      Template.new(
        # update this line to use the new configuration
        # template: custom_template,
        # questions: custom_questions,
        dir: options[:output] || Dir.pwd
      ).create
    end

    default_task :create

    desc '-v, --version', 'Show version'
    map %w[-v --version] => :version
    def version
      puts VERSION
    end

    desc '-h, --help', 'Display this help message'
    def help(*)
      say Beadme.configuration.messages[:about]
      say "\nVersion: #{VERSION}\n\n"
      super
    end

    def self.banner(command, _namespace = nil, _subcommand = false)
      "#{basename} #{command.usage}"
    end

    def self.start(args = ARGV, config = {})
      # I don't want to use commands like `beadme help` or `beadme version`
      # I want to use `beadme -h` or `beadme -v` instead
      # So I need to filter out the commands
      filter_commands = public_instance_methods(false).map(&:to_s)
      invalids = filter_commands & args
      raise UndefinedCommandError.new(invalids.first, [], nil) if invalids.any?

      super
    rescue Thor::Error => e
      warn e.message
      exit 1
    rescue Interrupt
      warn "\nAborted!"
      exit 1
    end

    def self.exit_on_failure?
      true
    end
  end
end
