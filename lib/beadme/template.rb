require 'thor'
require 'erb'

class ::String
  def to_list
    split(',')
      .map(&:strip)
      .reject(&:empty?)
      .map(&:capitalize)
  end
end

module Beadme
  class Template
    include Thor::Shell

    attr_reader :template, :questions, :dir, :save_path

    def ask(question, color = nil)
      say question, color
      print '> '
      super ''
    ensure
      puts ''
    end

    def initialize(
      template: Beadme.configuration.template,
      questions: Beadme.configuration.questions,
      dir: Dir.pwd
    )
      @template = template
      @questions = questions
      @dir = dir
      @dir = Dir.pwd if dir == 'Current directory'
    end

    def create
      check_dir
      check_file

      erb = ERB.new(template)

      data = ask_questions
      File.write(save_path, erb.result(binding))
      print 'Successfully generate Readme.md in '
      say save_path, :green
    rescue ArgumentError => e
      say e.message
      exit 1
    end

    private

    def check_dir
      File.exist?(dir) or raise ArgumentError, "\"#{dir}\" does not exist"
      File.directory?(dir) or raise ArgumentError, "\"#{dir}\" is not a directory"
      File.writable?(dir) or raise ArgumentError, "\"#{dir}\" is not writable"
    end

    def check_file
      @save_path = File.join(dir, 'README.md')
      return unless File.exist?(save_path)

      say 'README.md already exists in this directory'
      yes? 'Do you want to overwrite it? (y/N)', :red or exit
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

  class TemplateError < StandardError; end
end
