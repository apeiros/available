# encoding: utf-8

lib_dir = File.expand_path('../../lib', __FILE__)
$LOAD_PATH << lib_dir if File.directory?(lib_dir)

require 'available'



Capa = Available.new do
  #message "MyAwesomeProject needs %{library} to work. Please install %{library}: %{installation}"

  # requires :haml is short for: requires haml: gem('haml', 'haml')
  # requires foo: 'bar' is short for: requires foo: gem('bar', 'bar')
  # the gem method is gem(gemname, requirename)
  requires :nokogiri, :haml, sqlite: gem('sqlite3-ruby', 'sqlite3')

  # works the same as requires with regards to its arguments
  optional :bar, markdown: any_of(:maruku, :rdiscount, :bluecloth)
end