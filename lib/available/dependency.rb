# encoding: utf-8



class Available

  # Represents a dependency (required or optional) of your system for which you can query
  # your Available instance.
  class Dependency

    # @return [Symbol]
    #   The name/identifier of the dependency. This is also used in the query interface
    #   of Available (e.g. if your dependency.name is :haml, it'll be
    #   available.has?(:haml) and available.has.haml? etc.)
    attr_reader :name

    # @return [String, nil] The path passed to Kernel#require
    attr_reader :require_path

    # @return [Exception, nil]
    #   The exception raised when trying to load the library. Nil if either the library
    #   was successfully required, or if it wasn't tried to be loaded.
    attr_reader :error

    # @param [Symbol] name
    #   The identifier to use for the Available query interface, like available.has?(name).
    # @param [String] require_path
    #   The path to use to require the library. This is passed to Kernel#require.
    #   If you don't supply it, the name is used.
    def initialize(name, require_path=nil)
      @name         = name.to_sym
      @require_path = require_path || name.to_s
      @satisfied    = false
      @error        = nil
    end

    # @return [Boolean]
    #   Whether the require could be satisfied. Note that while Available#satisfied?
    #   ignores optional dependencies, Available
    def satisfied?
      @satisfied
    end

    # Dependency#which is mostly useful for Available::AnyOfDependency.
    # For others it'll most likely just return self.
    #
    # @return [Available::Dependency] The dependency that was/is required.
    def which
      self
    end

    # Tries to require the library and updates satisfied? and error state.
    def require!
      yield if block_given?
      require @require_path
    rescue LoadError => exception
      @error      = exception
      @satisfied  = false
    else
      @error      = nil
      @satisfied  = true
    end

    # @return [Symbol] Returns :library.
    def type
      :library
    end
  end
end
