# encoding: utf-8



class Available
  class Dependency
    attr_reader :name
    attr_reader :require_path
    attr_reader :error

    def initialize(name, require_path)
      @name         = name
      @require_path = require_path
      @satisfied    = false
      @error        = nil
    end

    def satisfied?
      @satisfied
    end

    def which
      self
    end

    def require!
      yield if block_given?
      require @require_path
    rescue LoadError => exception
      @error      = exception
      @satisfied  = false
    else
      @satisfied  = true
    end

    def type
      :library
    end
  end
end
