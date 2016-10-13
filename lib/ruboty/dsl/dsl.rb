# encoding: utf-8
require 'ruboty/dsl/dsl_model'
require 'ruboty/models/env'
require 'ruboty/models/command'

module Ruboty
  # Dsl
  class Dsl
    attr_accessor :ruboty_generator

    [:user_name, :gem_class_name, :gem_name, :description].each do |f|
      define_method f do |value|
        @ruboty_generator.send("#{f}=", value)
      end
    end

    def env
      e = Ruboty::Models::Env.new
      yield(e)
      @ruboty_generator.env << e
    end

    def command
      c = Ruboty::Models::Command.new
      yield(c)
      @ruboty_generator.commands << c
    end

    def initialize
      @ruboty_generator = Ruboty::DslModel.new
      @ruboty_generator.user_name = 'your github username'
      @ruboty_generator.gem_class_name = 'your_gem_class_name'
      @ruboty_generator.gem_name = 'your_gem_name'
      @ruboty_generator.description = 'description'
      @ruboty_generator.env = []
      @ruboty_generator.commands = []
    end

    def to_s
      <<-EOS
user_name = #{@ruboty_generator.user_name}
gem_class_name = #{@ruboty_generator.gem_class_name}
gem_name = #{@ruboty_generator.gem_name}
description = #{@ruboty_generator.description}
env = #{@ruboty_generator.env}
commands = #{@ruboty_generator.commands}
      EOS
    end
  end
end
