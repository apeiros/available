README
======


Summary
-------
Query the availability of required and optional libraries and gems with a nice interface.


Features
--------

* A nice API


Installation
------------
`gem install available`


Usage
-----

A simple example

    source = Available.new do
      requires :nokogiri, :haml
      optional :textile
    end
    source.satisfied?       # => true/false - whether all required dependencies could be loaded
    source.has.nokogiri?    # => true/false
    source.has?(:nokogiri)  # => same as above
    source.need.nokogiri!   # either returns true, or raises a LoadError
    source.missing          # => [#<Available::Dependency…>, …] - an array of missing dependencies
    source.error(:nokogiri) # => nil/LoadError - the exception that occurred while loading nokogiri
    source.errors           # => [#<LoadError…>, …] an array of all errors that occurred while trying to require dependencies

A more complex example

    source = Available.new do
      requires rack_ssl: 'rack/ssl' # require differs from name
      requires sqlite: gem('sqlite3-ruby', 'sqlite') # explicitely a gem, giving its name and the proper require
      requires markdown: any_of(:maruku, :rdiscount, :bluecloth)
    end
    source.which(:markdown)       # => an Available::Depencency
    source.which(:markdown).name  # => either :maruku, :rdiscount or :bluecloth

Of course you can combine those requires

    source = Available.new do
      requires :nokogiri,
               :haml,
               rack_ssl: 'rack/ssl',
              sqlite: gem('sqlite3-ruby', 'sqlite'),
              markdown: any_of(:maruku, :rdiscount, :bluecloth)

      optional :textile
    end


Links
-----

* [Online API Documentation](http://rdoc.info/github/apeiros/available/)
* [Public Repository](https://github.com/apeiros/available)
* [Bug Reporting](https://github.com/apeiros/available/issues)
* [RubyGems Site](https://rubygems.org/gems/available)


Running the Tests
-----------------

You can run the tests using `ruby test/runner.rb` (I prefer `ruby -rturn test/runner.rb`,
but that's your call). Using test/runner is not a requirement. but it makes things easier.


License
-------

You can use this code under the {file:LICENSE.txt BSD-2-Clause License}, free of charge.
If you need a different license, please ask the author.
