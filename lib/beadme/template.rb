require 'erb'
require 'thor/shell'

class ::String
  def to_list
    split(',').map(&:strip).reject(&:empty?).map(&:capitalize)
  end
end

module Beadme
  # This class is responsible for generating the README.md file
  class Template
    include Thor::Shell

    attr_reader :template, :questions, :dir, :save_path

    def ask(question, color = nil)
      say question, color
      print '> '
      super ''
    ensure
      print "\e[2J\e[f"
    end

    def initialize(
      template: Beadme.configuration.default_template,
      questions: Beadme.configuration.default_questions,
      dir: Dir.pwd
    )
      @template = template
      @questions = questions
      @dir = dir
      @save_path = File.join(dir, 'README.md')
    end

    # Create the README.md file
    def create
      check_dir
      check_file

      erb = ERB.new(template)

      # ERB template will use this variable to populate the content
      data = ask_questions
      File.write(save_path, erb.result(binding))

      print 'Successfully generate Readme.md in '
      say save_path, :green
    rescue ArgumentError => e
      say e.message
      exit 1
    rescue StandardError => e
      say "An error occurred while generating the README.md \n file: #{e.message}"
      exit 1
    end

    private

    def check_dir
      raise ArgumentError, "#{dir} does not exist" unless File.exist?(dir)
      raise ArgumentError, "#{dir} is not a directory" unless File.directory?(dir)
      raise ArgumentError, "#{dir} is not writable" unless File.writable?(dir)
    end

    def check_file
      return unless File.exist?(save_path)

      say 'README.md already exists in this directory'
      exit(1) unless yes?('Do you want to overwrite it? (y/N)', :red)
    end

    def ask_questions
      data = {}
      questions.each_with_index do |value, i|
        key, question = value
        answer = ask "#{i + 1}. #{question}", :blue
        answer = answer.to_list if key.to_s.include?('stack') or key.to_s.include?('features')

        data[key] = answer
      end
      data
    end
  end
end
