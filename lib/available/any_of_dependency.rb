# encoding: utf-8



require 'available/dependency'



class Available
  class AnyOfDependency < Dependency
    class LoadingAnyError < LoadError
      def initialize(message, errors)
        super(message)
        @errors = errors
      end
      attr_reader :errors
    end

    attr_reader :which
    attr_reader :list

    def initialize(name, list)
      super(name, nil)
      @list   = list
      @which  = nil
      @error  = nil
    end

    def require_path
      @which && @which.require_path
    end

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
