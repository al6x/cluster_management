module ClusterManagement
  class Service
    inject logger: :logger, config: :config
    
    
    
    
    
    
    
    
    attr_reader :box    
    
    # 
    # Business Logic
    # 
    def initialize box
      @box = box
    end
  
    def mark! extra_mark = nil
      box.mark! self.class.marker(extra_mark)
    end
  
    def has_mark? extra_mark = nil
      box.has_mark? self.class.marker(extra_mark)
    end
  
    def apply_once extra_mark = nil, &block
      unless has_mark? extra_mark
        block.call
        mark! extra_mark
      end
    end
  
    def require *args
      if args.size == 1 and args.first.is_a?(Hash)
        services = args.first
      elsif args.size == 2 and args.first.is_a?(Array)
        services = {}
        args.first.each{|klass| services[klass] = args.last}
      else
        raise 'invalid arguments'
      end
      
      services.each do |klass, method|
        key = "#{klass}.#{method}"
        unless box.already_required_services.include? key
          klass.new(box).send method if klass.method_defined? method
          box.already_required_services << key
        end
      end
    end
  
    class << self
      def version version = nil
        if version
          @version = version
        else
          @version ||= 1
        end
      end

      def marker extra_mark = nil
        %(#{name}:#{version}#{":#{extra_mark}" if extra_mark})
      end
    end
  end
end