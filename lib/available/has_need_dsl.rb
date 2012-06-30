# encoding: utf-8



class Available

  # HasNeedDSL is a class used internally to enable the query interface of Available,
  # namely `available.has.some_lib?` and `available.need.some_lib!`.
  class HasNeedDSL

    # @param [Available] available
    #   The associated Available instance.
    def initialize(available)
      @available = available
    end

    # @private
    # Correlates with method_missing.
    # @see Object#respond_to_missing?
    def respond_to_missing?(name, include_private=false)
      name =~ /\?$|!$/ && @available.registered?(name[0..-2])
    end

  private
    # @private
    # Responds to the some_lib? and some_lib! method calls.
    def method_missing(method_name, *args)
      case method_name
        when /(.*)\?$/
          raise ArgumentError, "Too many arguments (#{args.size} for 0)" unless args.empty?
          @available.has?($1.to_sym)
        when /(.*)!$/
          raise ArgumentError, "Too many arguments (#{args.size} for 0)" unless args.empty?
          @available.need!($1.to_sym)
        else
          super
      end
    end
  end
end
