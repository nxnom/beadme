require 'thor'
require 'erb'

require_relative '../beadme'

class ::String
  def to_list
    split(',')
      .map(&:strip)
      .reject(&:empty?)
      .map(&:capitalize)
  end
end

module Beadme
  class Runner < Thor
    class_option :output, aliases: '-o', type: :string, default: 'Current directory', desc: 'Output directory'

    no_commands do
      def ask(question, color = nil)
        say question, color
        print '> '
        super ''
      ensure
        say ''
      end
    end

    desc 'create', 'Create a new beadme project', hide: true
    def create
      say "#{Beadme.configuration.messages[:welcome]}\n"
      save_dir = options[:output]
      save_dir = Dir.pwd if options[:output] == 'Current directory'
      path = File.join(save_dir, 'README.md')

      template = ERB.new(Beadme.configuration.template)

      data = {}
      questions = Beadme.configuration.questions
      questions.each_with_index do |value, i|
        key, question = value
        answer = ask "#{i + 1}. #{question}", :blue
        answer = answer.to_list if key.to_s.include?('stack') or key.to_s.include?('features')

        data[key] = answer
      end

      if File.exist?(path)
        say 'README.md already exists in this directory', :red
        yes? 'Do you want to overwrite it? (y/N)', :red or exit
      end

      File.write(path, template.result(binding))

      print 'Successfully generate Readme.md in '
      say path, :green
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
