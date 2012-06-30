# encoding: utf-8



require 'available/dependency'



class Available
  class GemDependency < Dependency
    attr_reader :version
    attr_reader :gem_name

    def initialize(name, gem_name, require_path, gem_version=nil)
      super(name, require_path)
      @gem_name = gem_name
      @version  = gem_version
    end

    def require!
      super do
        gem @gem_name, @version if @version
      end
    end

    def type
      :gem
    end
  end
end
