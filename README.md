# Ruboty::Gen::Readme

Generate Ruboty Handler + Actions plugin.

[![Gem Version](https://badge.fury.io/rb/ruboty-megen.svg)](http://badge.fury.io/rb/ruboty-generator)
[![Build Status](https://travis-ci.org/tbpgr/ruboty-generator.png?branch=master)](https://travis-ci.org/tbpgr/ruboty-generator)

[Ruboty](https://github.com/r7kamura/ruboty) is Chat bot framework. Ruby + Bot = Ruboty

## :arrow_down: Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruboty-generator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruboty-generator

## :blue_book: Rubotygenerator
### Setting File Parameters

|key|value|example|
|:--|:--|:--|
|user_name|github user name|tbpgr|
|gem_class_name|gem class name|Hoge|
|gem_name|gem name|hoge|
|description|description|An Ruboty Handler + Actions to output hige.|
|env/name|ENV variable name|DEFAULT_HOGE_TEXT|
|env/description|ENV description|default hoge text|
|commands/command name|Ruboty::Handler.on name|hoge|
|commands/command pattern|Ruboty::Handler.on pattern|/hoge\z/  |
|commands/command description|Ruboty::Handler.on description|output hige|

## :scroll: Usage
### init
generate Rubotygenerator template file.

~~~bash
$ ruboty-generator init
$ ls -1 | grep Rubotygenerator
Rubotygenerator
~~~

### generate
generate Ruboty Handler + Action template

* edit Rubotygenerator file

~~~ruby
# encoding: utf-8
user_name "tbpgr"

gem_class_name "Hoge"
gem_name "hoge"

description "An Ruboty Handler + Actions to hoge-hige"

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
  c.pattern "hoge\\z"
  c.description "output hige"
end

command do |c|
  c.name "hige"
  c.pattern "hige\\z"
  c.description "output hige"
end
~~~

#### generate plugin with action

~~~bash
$ ruboty-generator generate -a
~~~

* output

```bash
.
└── ruboty-hoge
    ├── Gemfile
    ├── LICENSE.txt
    ├── README.md
    ├── Rakefile
    ├── bin
    │   ├── console
    │   └── setup
    ├── lib
    │   └── ruboty
    │       ├── handlers
    │       │   └── hoge.rb
    │       ├── hoge
    │       │   ├── actions
    │       │   │   ├── hige.rb
    │       │   │   └── hoge.rb
    │       │   └── version.rb
    │       └── hoge.rb
    └── ruboty-hoge.gemspec
```

* check generated handler

~~~ruby
require "ruboty/hoge/actions/hoge"
require "ruboty/hoge/actions/hige"

module Ruboty
  module Handlers
    # An Ruboty Handler + Actions to hoge-hige
    class Hoge < Base
      on /hoge\z/, name: 'hoge', description: 'output hige'
      on /hige\z/, name: 'hige', description: 'output hige'
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
~~~

* check generated action

hoge.rb

```ruby
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
```

hige.rb

```ruby
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
```

#### generate plugin without action

~~~bash
$ ruboty-generator generate
~~~

* output

```bash
.
└── ruboty-hoge
    ├── Gemfile
    ├── README.md
    ├── Rakefile
    ├── bin
    │   ├── console
    │   └── setup
    ├── lib
    │   └── ruboty
    │       ├── handlers
    │       │   └── hoge.rb
    │       ├── hoge
    │       │   └── version.rb
    │       └── hoge.rb
    └── ruboty-hoge.gemspec
```

* check generated handler

```ruby


module Ruboty
  module Handlers
    # An Ruboty Handler + Actions to hoge-hige
    class Hoge < Base
      on /hoge\z/, name: 'hoge', description: 'output hige'
      on /hige\z/, name: 'hige', description: 'output hige'
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
```

## :two_men_holding_hands: Contributing :two_women_holding_hands:

1. Fork it ( https://github.com/tbpgr/ruboty-generator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
