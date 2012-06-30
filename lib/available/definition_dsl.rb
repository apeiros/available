# encoding: utf-8



class Available

  # The block passed to Available#initialize is instance evaluated in the context of a
  # DefinitionDSL instance.
  class DefinitionDSL

    # @private
    #
    # @param [Available] available
    #   The Available instance this definition is linked to.
    def initialize(available, &block)
      @available = available
      instance_eval(&block)
    end

    # A list of required libraries.
    #
    # The common way to specify a library is by a Symbol. If you do `requires :haml`, that
    # will try to `require 'haml'` and make the `available.has.haml?` method available.
    # Upon failure it will state "You must install the 'haml' library."
    #
    # You can also pass a hash, if the require and the name under which you want to query
    # your Available instance differ. If you do `requires template_engine: 'haml'`, it
    # will try to `require 'haml'` and make the `available.has.template_engine?` method
    # available. Upon failure it will state "You must install the 'haml' library."
    #
    # When any of the required libraries failed to load, Available#satisfy? of the
    # associated Available instance will be false.
    def requires(*args)
      normalize_list(args).each do |dependency|
        @available.add_required(dependency)
      end
    end

    # Works like #requires, but libraries passed to #optional will not influence the
    # associated Available instance's #satisfied? state. That is, it will try to load them,
    # make the query methods available, but if it could not be loaded, it doesn't matter
    # to Available#satisfy?.
    def optional(*args)
      normalize_list(args).each do |dependency|
        @available.add_optional(dependency)
      end
    end

    # Used as part of a hash argument to either #requires or #optional.
    # Used when the gem name and the require differ.
    # The parameters passed to it are the same as those for
    # Available::GemDependency#initialize, except that the `name` param is left out (since
    # that's given by the key of the hash already).
    #
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
    def gem(gem_name, require_path=nil, gem_version=nil)
      [:gem, [gem_name, require_path, gem_version]]
    end

    # Used as part of a hash argument to either #requires or #optional.
    # Specifies a list of dependencies, which are tried in order, first successfully
    # loading will be used.
    # It accepts the same arguments as Available::DefinitionDSL#requires.
    #
    # An example use-case are markdown libraries. Your requirement for a
    # markdown processor could possibly be satisfied by any of all the available markdown
    # processors.
    #
    # @see Available::AnyOfDependency
    def any_of(*args)
      [:any_of, args]
    end

    # @private
    #
    # Normalizes the multitude of accepted arguments to #requires and #optional to an
    # array of Available::Dependency
    #
    # @return [Array<Available::Dependency>] The normalized list of dependencies.
    def normalize_list(list)
      mapped = list.pop if list.last.is_a?(Hash)
      result = list.map { |item| normalize(item) }
      result.concat mapped.map { |k,v| normalize(v,k) } if mapped

      result
    end

    # @private
    #
    # Normalizes a single item in the list of arguments to #requires and #optional to an
    # instance of Available::Dependency
    #
    # @return [Available::Dependency] The normalized dependency.
    def normalize(item, name=nil)
      case item
        when Symbol     then Dependency.new(name || item, item.to_s)
        when String     then Dependency.new(name || item.to_sym, item)
        when Dependency then item
        when Array      then
          case item.first
            when :gem then
              args = item.last
              args.unshift name if name
              GemDependency.new(*args)
            when :any_of
              raise "any_of must be used in hash form: name: any_of(a,b,c)" unless name
              AnyOfDependency.new(name, normalize_list(item.last))
            else
              raise "Can't normalize #{item.inspect}"
          end
      end
    end
  end
end
