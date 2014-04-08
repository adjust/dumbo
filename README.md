# Dumbo

postgres extension with fun

![](http://img1.wikia.nocookie.net/__cb20091210033559/disney/images/7/76/Dumbo-HQ.JPG)

## Installation

Add this line to your application's Gemfile:

    gem 'dumbo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dumbo

## Getting Started

At the command prompt, create a new extension:

  dumbo new myextention

where "myextention" is the extension name.

Change directory to myextention to start hacking:

    cd myapp

As a stating point take a look at the sample function in

    sql/sample.sql

and the corresponding test file

    spec/sample_spec.rb

build the extension and run the specs

    rake

if you start working on a new version run

    rake dumbo:new_version [level]

where level is new version level (major, minor patch)

when you are done you can create the migration files with

    rake dumbo:migrations

## Contributing

1. Fork it ( http://github.com/adeven/dumbo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
