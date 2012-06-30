# encoding: utf-8



require 'available/dependency'



class Available

  # AnyOfDependency
  #
  # Represents a dependency which can be satisfied by any of a list of possible
  # dependencies. An example use-case are markdown libraries. Your requirement for a
  # markdown processor could possibly be satisfied by any of all the available markdown
  # processors.
  #
  # @see Available::DefinitionDSL#any_of
  class AnyOfDependency < Dependency

    # A custom LoadError, since it's only considered a load error if all candidates fail
    # to load.
    class LoadingAnyError < LoadError
      def initialize(message, errors)
        super(message)
        @errors = errors
      end

      # @return [Array<LoadError>]
      #   A list of all the original LoadErrors that occurred while trying to load the
      #   candidates.
      attr_reader :errors
    end

    # @return [nil, Available::Dependeny]
    #   Which dependency was successfully loaded. Nil if none.
    attr_reader :which

    # @return [Array<Available::Dependeny>]
    #   A list of all dependency candidates.
    attr_reader :list

    # @param [Symbol] name
    #   The name of this dependency.
    #   See {Available::Dependency#name}
    #
    # @param [Array<Available::Dependeny>] list
    #   A list of all dependency candidates. The candidates are tried in the order in
    #   which they've been passed.
    def initialize(name, list)
      super(name, nil)
      @list   = list
      @which  = nil
    end

    # @see Available::Dependeny#require_path
    # This method is simply adapted to the fact that an AnyOfDependency's require_path
    # depends upon which dependency has actually been loaded.
    def require_path
      @which && @which.require_path
    end

    # @see Available::Dependeny#require
    # This method is simply adapted to the fact that an AnyOfDependency has to try loading
    # any of the dependencies found in Available::AnyOfDependency#list.
    def require!
      @which = @list.find { |dependency|
        dependency.require!
        dependency.satisfied?
      }
      if @which
        @satisfied  = true
      else
        @satisfied  = false
        @error      = LoadingAnyError.new("Loading any of #{@list.map(&:name).join(', ')} failed.", @list.map(&:error))
      end
    end
  end
end
