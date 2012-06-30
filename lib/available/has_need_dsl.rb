# encoding: utf-8



class Available
  class HasNeedDSL
    def initialize(available)
      @available = available
    end

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
  
    def respond_to_missing?(name, include_private=false)
      name =~ /\?$|!$/ && @available.registered?(name[0..-2])
    end
  end
end
