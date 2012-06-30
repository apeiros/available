# encoding: utf-8



require 'available/version'
require 'available/dependency'
require 'available/any_of_dependency'
require 'available/gem_dependency'
require 'available/definition_dsl'
require 'available/has_need_dsl'



# Available
# Query the availability of required and optional libraries and gems with a nice interface.
#
# @example A simple example
#     source = Available.new do
#       requires :nokogiri, :haml
#       optional :textile
#     end
#     source.satisfied?       # => true/false - whether all required dependencies could be loaded
#     source.has.nokogiri?    # => true/false
#     source.has?(:nokogiri)  # => same as above
#     source.need.nokogiri!   # either returns true, or raises a LoadError
#     source.missing          # => [#<Available::Dependency…>, …] - an array of missing dependencies
#     source.error(:nokogiri) # => nil/LoadError - the exception that occurred while loading nokogiri
#     source.errors           # => [#<LoadError…>, …] an array of all errors that occurred while trying to require dependencies
#
# @example A more complex example
#     source = Available.new do
#       requires rack_ssl: 'rack/ssl' # require differs from name
#       requires sqlite: gem('sqlite3-ruby', 'sqlite') # explicitely a gem, giving its name and the proper require
#       requires markdown: any_of(:maruku, :rdiscount, :bluecloth)
#     end
#     source.which(:markdown)       # => an Available::Depencency
#     source.which(:markdown).name  # => either :maruku, :rdiscount or :bluecloth
#
# @example Of course you can combine those requires
#     source = Available.new do
#       requires :nokogiri,
#                :haml,
#                rack_ssl: 'rack/ssl',
#               sqlite: gem('sqlite3-ruby', 'sqlite'),
#               markdown: any_of(:maruku, :rdiscount, :bluecloth)
#
#       optional :textile
#     end
#
class Available

  # @return [Exception]
  #   A list of all exceptions that occurred while trying to load libraries.
  attr_reader :errors

  # @return [Available::HasNeedDSL]
  #   Used as part of the convenience querying system.
  #   Delegates to Available#has?. That is, `available.has.some_library?` works just
  #   the same as `available.has?(:some_library)`.
  #
  #   @example
  #       available.has.some_library?
  attr_reader :has

  # @return [Available::HasNeedDSL]
  #   Used as part of the convenience querying system.
  #   Delegates to Available#need!. That is, `available.need.some_library!` works just
  #   the same as `available.need!(:some_library)`.
  #
  #   @example
  #       available.need.some_library!
  attr_reader :need

  # Create a new Available instance.
  # @see Available Look at Available's docs for some examples.
  def initialize(&block)
    @required   = []
    @optional   = []
    @registered = {}
    @available  = {}
    @missing    = {}
    @errors     = {}
    @satisfied  = true
    @has        = HasNeedDSL.new(self)
    @need       = @has

    DefinitionDSL.new(self, &block) if block
  end

  # @return [Array<Available::Dependency>]
  #   A list of all the dependencies that failed to load.
  def missing
    @missing.values
  end

  # @return [Array<Symbol>]
  #   A list of the names of all the dependencies that failed to load.
  def missing_names
    @missing.keys
  end

  # @return [Boolean]
  #   Whether all required libraries have been successfully loaded.
  def satisfied?
    @satisfied
  end

  # @return [Boolean]
  #   Whether the given library has been successfully loaded.
  def has?(name)
    @available[name] ? true : false
  end

  # @return [Boolean]
  #   Whether the given library has been successfully loaded.
  #   If it hasn't, #need! will raise the exception which was raised while loading the
  #   library.
  #
  # @raise [LoadError]
  #   If the needed library couldn't be loaded successfully, #need! raises the exception
  #   which was raised while loading the library.
  def need!(name)
    raise "Unknown library #{name}" unless @registered.has_key?(name)
    raise @missing[name].error if @missing[name]
    true
  end

  # @return [Boolean]
  #   Whether the given library was listed in the available declaration, either as
  #   required or as optional.
  #
  # @note This method might be renamed.
  def registered?(name)
    @registered.has_key?(name)
  end

  # @return [Available::Dependency]
  #   Returns the dependency that was actually loaded for a given name. Useful for
  #   any_of-dependencies.
  #
  # @see Available::DeclarationDSL#any_of
  # @see Available::AnyOfDependency
  def which(name)
    dep = @available[name]

    dep && dep.which
  end

  # @private
  #
  # Adds a required dependency
  #
  # @param [Available::Dependency] dependency
  #   The dependency to add.
  def add_required(dependency)
    add(dependency, @optional)
    @satisfied &&= dependency.satisfied?

    self
  end

  # @private
  #
  # Adds an optional dependency
  #
  # @param [Available::Dependency] dependency
  #   The dependency to add.
  def add_optional(dependency)
    add(dependency, @optional)

    self
  end

  # A more digestable inspect.
  #
  # @see Object#inspect
  def inspect
    sprintf "#<%s:%x %s>",
            self.class,
            object_id>>1,
            @available.map { |name, dep| "#{name}: #{dep ? true : false}" }.join(", ")
  end

private
  # Add a dependency to the given list. Require it, and register all relevant
  # information along (like errors, satisfied?, available and missing).
  def add(dependency, list)
    dependency.require!
    list << dependency
    @registered[dependency.name] = dependency
    @errors[dependency.name]     = dependency.error if dependency.error
    if dependency.satisfied? then
      @available[dependency.name] = dependency
    else
      @available[dependency.name] = nil
      @missing[dependency.name]   = dependency
    end
  end
end
