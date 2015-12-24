# encoding: utf-8
require 'spec_helper'
require 'ruboty/generator'

describe Ruboty::Generator do
  context :init do
    let(:tmp) { 'tmp' }

    cases = [
      {
        case_no: 1,
        case_title: 'valid case',
        expected: Ruboty::Generator::RUBOTY_GENERATOR_FILE_TEMPLATE
      }
    ]

    cases.each do |c|
      it "|case_no=#{c[:case_no]}|case_title=#{c[:case_title]}" do
        begin
          case_before c

          # -- given --
          # nothing

          # -- when --
          Ruboty::Generator.init
          actual = File.open(Ruboty::Generator::RUBOTY_GENERATOR_FILE, 'r:utf-8', &:read)

          # -- then --
          expect(actual).to eq(c[:expected])
        ensure
          case_after c
        end
      end

      def case_before(_c)
        FileUtils.mkdir_p(tmp) unless Dir.exist? tmp
        Dir.chdir(tmp)
      end

      def case_after(_c)
        Dir.chdir('../')
        FileUtils.rm_rf(tmp) if Dir.exist? tmp
      end
    end
  end

  context :generate do
    let(:tmp) { 'tmp_generate' }
    let(:template) do
      template = <<-EOS
user_name "tbpgr"

gem_class_name "Hoge"
gem_name "hoge"

description "An Ruboty Handler + Actions to output hige."

env do |e|
  e.name "DEFAULT_HOGE_TEXT1"
  e.description "DEFAULT_HOGE_TEXT1 desc"
end

env do |e|
  e.name "DEFAULT_HOGE_TEXT2"
  e.description "DEFAULT_HOGE_TEXT2 desc"
end

command do |c|
  c.name "hoge"
  c.pattern "hoge\\\\z"
  c.description "output hige"
end

command do |c|
  c.name "hige"
  c.pattern "hige\\\\z"
  c.description "output hige"
end
      EOS
      template
    end

    cases = [
      {
        case_no: 1,
        case_title: 'valid case with actions',
        options: { a: true },
        handler: 'hoge',
        actions: %w(hoge hige),
        expected_handler: <<-EOS,
require "ruboty/hoge/actions/hoge"
require "ruboty/hoge/actions/hige"

module Ruboty
  module Handlers
    # An Ruboty Handler + Actions to output hige.
    class Hoge < Base
      on /hoge\\z/, name: 'hoge', description: 'output hige'
      on /hige\\z/, name: 'hige', description: 'output hige'
      env :DEFAULT_HOGE_TEXT1, "DEFAULT_HOGE_TEXT1 desc"
      env :DEFAULT_HOGE_TEXT2, "DEFAULT_HOGE_TEXT2 desc"

      def hoge(message)
        Ruboty::Hoge::Actions::Hoge.new(message).call
      end

      def hige(message)
        Ruboty::Hoge::Actions::Hige.new(message).call
      end

    end
  end
end
        EOS
        expected_action_hoge: <<-EOS,
module Ruboty
  module Hoge
    module Actions
      class Hoge < Ruboty::Actions::Base
        def call
          message.reply(hoge)
        rescue => e
          message.reply(e.message)
        end

        private
        def hoge
          # TODO: main logic
        end
      end
    end
  end
end
        EOS
        expected_action_hige: <<-EOS,
module Ruboty
  module Hoge
    module Actions
      class Hige < Ruboty::Actions::Base
        def call
          message.reply(hige)
        rescue => e
          message.reply(e.message)
        end

        private
        def hige
          # TODO: main logic
        end
      end
    end
  end
end
        EOS
      },
      {
        case_no: 2,
        case_title: 'valid case without actions',
        options: { a: false },
        handler: 'hoge',
        actions: [],
        expected_handler: <<-EOS,


module Ruboty
  module Handlers
    # An Ruboty Handler + Actions to output hige.
    class Hoge < Base
      on /hoge\\z/, name: 'hoge', description: 'output hige'
      on /hige\\z/, name: 'hige', description: 'output hige'
      env :DEFAULT_HOGE_TEXT1, "DEFAULT_HOGE_TEXT1 desc"
      env :DEFAULT_HOGE_TEXT2, "DEFAULT_HOGE_TEXT2 desc"

      def hoge(message)
        # TODO: implement your action
      end

      def hige(message)
        # TODO: implement your action
      end

    end
  end
end
              EOS
      }
    ]

    cases.each do |c|
      it "|case_no=#{c[:case_no]}|case_title=#{c[:case_title]}" do
        begin
          case_before c

          # -- given --
          # nothing

          # -- when --
          Ruboty::Generator.generate(c[:options])
          actual_handler = File.open("./ruboty-#{c[:handler]}/#{Ruboty::Generator::RUBOTY_HANDLER_FILE}/#{c[:handler]}.rb", 'r:utf-8', &:read)

          # -- then --
          expect(actual_handler).to eq(c[:expected_handler])

          c[:actions].each do |action|
            actuals_action = File.open("./ruboty-#{c[:handler]}/#{Ruboty::Generator::RUBOTY_BASE_FILE}/#{c[:handler]}/actions/#{action}.rb", 'r:utf-8', &:read)
            puts "expected_action_#{action}"
            expect(actuals_action).to eq(c[:"expected_action_#{action}"])
          end
        ensure
          case_after c
        end
      end

      def case_before(_c)
        FileUtils.mkdir_p(tmp) unless Dir.exist? tmp
        Dir.chdir(tmp)
        File.open(Ruboty::Generator::RUBOTY_GENERATOR_FILE, 'w:utf-8') do |file|
          file.puts template
        end
      end

      def case_after(_c)
        Dir.chdir('../')
        FileUtils.rm_rf(tmp) if Dir.exist? tmp
      end
    end
  end
end
