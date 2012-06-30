# encoding: utf-8



require 'available/dependency'



class Available

  # A dependency that is specifically a ruby gem.
  # This is useful if you have a version requirement.
  #
  # @note
  #   You should only use a GemDependency if you have to specify the version.
  #   Otherwise you're needlessly enforcing the dependency being a gem, which is not nice.
  class GemDependency < Dependency

    # @return [String] The gem version specification
    attr_reader :version

    # @return [String] The gem name
    attr_reader :gem_name

    # @param [Symbol] name
    #   The identifier to use for the Available query interface, like available.has?(name).
    # @param [String] gem_name
    #   The gem name. It must be what you'd supply to `gem install`. Available will use
    #   this to generate installation instructions.
    # @param [String] require_path
    #   The path to use to require the library. This is passed to Kernel#require.
    #   If you don't supply it, the name is used.
    # @param [String] gem_version
    #   The gem version specification.
    #
    #   See {Gem::Version} and {Gem::Requirement} for more information on gem version
    #   specs.
    #
    #   A list of specifications and what they mean (from Gem::Version, v 1.8.24)
    #
    #       Specification From  ... To (exclusive)
    #       ">= 3.0"      3.0   ... ∞
    #       "~> 3.0"      3.0   ... 4.0
    #       "~> 3.0.0"    3.0.0 ... 3.1
    #       "~> 3.5"      3.5   ... 4.0
    #       "~> 3.5.0"    3.5.0 ... 3.6
    def initialize(name, gem_name, require_path=nil, gem_version=nil)
      super(name, require_path)
      @gem_name = gem_name
      @version  = gem_version
    end

    # Just like Available::Dependency#require!, but also activates the correct gem version
    # if a gem version was given.
    def require!
      super do
        gem @gem_name, @version if @version
      end
    end

    # @return [Symbol] Returns :gem.
    def type
      :gem
    end
  end
end
