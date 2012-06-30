# encoding: utf-8



class Available
  class DefinitionDSL
    def initialize(available, &block)
      @available = available
      instance_eval(&block)
    end

    def requires(*args)
      normalize_list(args).each do |dependency|
        @available.add_required(dependency)
      end
    end
    def optional(*args)
      normalize_list(args).each do |dependency|
        @available.add_optional(dependency)
      end
    end
    def gem(*args)
      [:gem, args]
    end
    def any_of(*args)
      [:any_of, args]
    end
    def normalize_list(list)
      mapped = list.pop if list.last.is_a?(Hash)
      result = list.map { |item| normalize(item) }
      result.concat mapped.map { |k,v| normalize(v,k) } if mapped

      result
    end
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
