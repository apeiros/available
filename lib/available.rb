# encoding: utf-8



require 'available/version'
require 'available/dependency'
require 'available/any_of_dependency'
require 'available/gem_dependency'
require 'available/definition_dsl'
require 'available/has_need_dsl'



# Available
# Query the availability of required and optional libraries and gems with a nice interface.
class Available
  attr_reader :available
  attr_reader :errors
  attr_reader :has
  attr_reader :need

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

  def missing
    @missing.values
  end

  def missing_names
    @missing.keys
  end

  def satisfied?
    @satisfied
  end

  def has?(name)
    @available[name] ? true : false
  end

  def need!(name)
    raise "Unknown library #{name}" unless @registered.has_key?(name)
    raise @missing[name].error if @missing[name]
    true
  end

  def registered?(name)
    @registered.has_key?(name)
  end

  def which(name)
    dep = @available[name]

    dep && dep.which
  end

  def add_required(dependency)
    add(dependency, @optional)
    @satisfied &&= dependency.satisfied?

    self
  end

  def add_optional(dependency)
    add(dependency, @optional)

    self
  end

  def inspect
    sprintf "#<%s:%x %s>",
            self.class,
            object_id>>1,
            @available.map { |name, dep| "#{name}: #{dep ? true : false}" }.join(", ")
  end

private
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
