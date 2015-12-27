# encoding: utf-8
require 'erb'
require 'fileutils'

module Ruboty
  # Generator Core
  class Generator
    README = 'README.md'
    RUBOTY_GENERATOR_FILE = 'Rubotygenerator'
    RUBOTY_MODULE_FILE = 'lib/ruboty'
    RUBOTY_HANDLER_FILE = 'lib/ruboty/handlers'
    RUBOTY_BASE_FILE = 'lib/ruboty'
    RUBOTY_GENERATOR_FILE_TEMPLATE = <<-EOS
user_name "user name"

gem_class_name "Gem class name"
gem_name "gem name"

description "An Ruboty Handler description"

env do |e|
  e.name "ENV1"
  e.description "ENV1 desc"
end

command do |c|
  c.name "name"
  c.pattern "pattern\\\\z"
  c.description "description"
end
    EOS

    RUBOTY_MODULE_TEMPLATE = <<-EOS
require "ruboty/<%=gem_name%>/version"
require "ruboty/handlers/<%=gem_name%>"

module Ruboty
  module <%=gem_class_name%>
    # Your code goes here...
  end
end
    EOS

    RUBOTY_HANDLER_TEMPLATE = <<-EOS
<%=action_requires%>

module Ruboty
  module Handlers
    # <%=description%>
    class <%=gem_class_name%> < Base
<%=action_macros%>
<%=envs%>

<%=action_definitions%>
    end
  end
end
    EOS

    RUBOTY_ACTION_TEMPLATE = <<-EOS
module Ruboty
  module <%=gem_class_name%>
    module Actions
      class <%=action_name.capitalize%> < Ruboty::Actions::Base
        def call
          message.reply(<%=action_name%>)
        rescue => e
          message.reply(e.message)
        end

        private
        def <%=action_name%>
          # TODO: main logic
        end
      end
    end
  end
end
    EOS

    # generate Rubotymegenfile to current directory.
    def self.init
      File.open(RUBOTY_GENERATOR_FILE, 'w') do |f|
        f.puts RUBOTY_GENERATOR_FILE_TEMPLATE
      end
    end

    # generate ruboty template.
    def self.generate(options = {})
      config = load_config
      execute_bundle_gem(config)
      module_src = generate_module(config)
      output_module(module_src, config.gem_name)
      handler_src = generate_handler(config, options[:a])
      output_handler(handler_src, config.gem_name)
      return unless options[:a]
      actions = generate_actions(config)
      output_actions(actions, config.gem_name)
    end

    def self.load_config
      src = read_dsl
      dsl = Ruboty::Dsl.new
      dsl.instance_eval(src)
      dsl.ruboty_generator
    end
    private_class_method :load_config

    def self.read_dsl
      File.open(RUBOTY_GENERATOR_FILE, &:read)
    end
    private_class_method :read_dsl

    def self.execute_bundle_gem(config)
      `bundle gem ruboty-#{config.gem_name}`
    end
    private_class_method :execute_bundle_gem

    def self.generate_module(config)
      gem_class_name = config.gem_class_name
      gem_name = config.gem_name
      erb = ERB.new(RUBOTY_MODULE_TEMPLATE)
      erb.result(binding)
    end
    private_class_method :generate_module

    def self.output_module(module_src, module_name)
      module_path = "./ruboty-#{module_name}/#{Ruboty::Generator::RUBOTY_MODULE_FILE}"
      FileUtils.mkdir_p(module_path)
      File.open("#{module_path}/#{module_name}.rb", 'w:utf-8') { |e| e.puts module_src }
    end
    private_class_method :output_module

    def self.generate_handler(config, have_actions)
      gem_class_name = config.gem_class_name
      gem_name = config.gem_name
      description = config.description
      actions = generate_action_definitions(config, gem_class_name, have_actions)
      action_requires = actions[:action_requires]
      action_definitions = actions[:action_definitions]
      action_macros = actions[:action_macros]
      envs = generate_env(config)
      erb = ERB.new(RUBOTY_HANDLER_TEMPLATE)
      erb.result(binding)
    end
    private_class_method :generate_handler

    def self.output_handler(handler_src, handler_name)
      handler_path = "./ruboty-#{handler_name}/#{Ruboty::Generator::RUBOTY_HANDLER_FILE}"
      FileUtils.mkdir_p(handler_path)
      File.open("#{handler_path}/#{handler_name}.rb", 'w:utf-8') { |e| e.puts handler_src }
    end
    private_class_method :output_handler

    def self.generate_action_definitions(config, gem_class_name, have_actions)
      if have_actions
        action_requires = config.commands.map { |e| "require \"ruboty/#{config.gem_name}/actions/#{e.read_name}\"" }.join("\n")
        action_definitions = generate_action_definitions_with_action(config, gem_class_name)
      else
        action_requires = ''
        action_definitions = generate_action_definitions_without_action(config)
      end
      action_macros = generate_action_macros(config)
      { action_requires: action_requires, action_definitions: action_definitions, action_macros: action_macros }
    end
    private_class_method :generate_action_definitions

    def self.generate_action_definitions_with_action(config, gem_class_name)
      definitions = config.commands.map do |e|
        <<-EOS
      def #{e.read_name}(message)
        Ruboty::#{gem_class_name}::Actions::#{e.read_name.capitalize}.new(message).call
      end
        EOS
      end
      definitions.join("\n")
    end
    private_class_method :generate_action_definitions_with_action

    def self.generate_action_definitions_without_action(config)
      definitions = config.commands.map do |e|
        <<-EOS
      def #{e.read_name}(message)
        # TODO: implement your action
      end
        EOS
      end
      definitions.join("\n")
    end
    private_class_method :generate_action_definitions_without_action

    def self.generate_action_macros(config)
      action_macros = config.commands.map do |e|
        "      on /#{e.read_pattern}/, name: '#{e.read_name}', description: '#{e.read_description}'"
      end
      action_macros.join("\n")
    end
    private_class_method :generate_action_macros

    def self.generate_env(config)
      config.env.map { |e| "      env :#{e.read_name}, \"#{e.read_description}\"" }.join("\n")
    end
    private_class_method :generate_env

    def self.generate_actions(config)
      gem_class_name = config.gem_class_name
      config.commands.each_with_object([]) do |e, memo|
        action_name = e.read_name
        erb = ERB.new(RUBOTY_ACTION_TEMPLATE)
        action = {}
        action[:name] = action_name
        action[:contents] = erb.result(binding)
        memo << action
      end
    end
    private_class_method :generate_actions

    def self.output_actions(actions, handler_name)
      actions.each do |action|
        actions_dir_path = "./ruboty-#{handler_name}/#{Ruboty::Generator::RUBOTY_BASE_FILE}/#{handler_name}/actions"
        FileUtils.mkdir_p(actions_dir_path)
        File.open("#{actions_dir_path}/#{action[:name]}.rb", 'w:utf-8') { |e| e.puts action[:contents] }
      end
    end
    private_class_method :output_actions
  end
end
