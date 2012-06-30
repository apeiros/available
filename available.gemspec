# encoding: utf-8

Gem::Specification.new do |s|
  s.name                      = "available"
  s.version                   = "0.0.1"
  s.authors                   = "Stefan Rusterholz"
  s.email                     = "stefan.rusterholz@gmail.com"

  s.description               = <<-DESCRIPTION.gsub(/^    /, '').chomp
    Query the availability of required and optional libraries and gems with a nice interface.
  DESCRIPTION
  s.summary                   = <<-SUMMARY.gsub(/^    /, '').chomp
    Query the availability of required and optional libraries and gems with a nice interface.
  SUMMARY

  s.files                     =
    Dir['bin/**/*'] +
    Dir['lib/**/*'] +
    Dir['rake/**/*'] +
    Dir['test/**/*'] +
    Dir['*.gemspec'] +
    %w[
      Rakefile
      README.markdown
    ]

  if File.directory?('bin') then
    executables = Dir.chdir('bin') { Dir.glob('**/*').select { |f| File.executable?(f) } }
    s.executables = executables unless executables.empty?
  end

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1")
  s.rubygems_version          = "1.3.1"
  s.specification_version     = 3
end
