module ClusterManagement
  class Service
    class << self
      def version version = nil
        if version
          @version = version
        else
          @version ||= 1
        end
      end
      
      def tag tag = nil
        if tag
          @tag = tag
        else
          @tag || raise("service :#{service_name} not tagged!")
        end
      end
      
      def marker extra_mark = nil
        %(#{service_name}:#{version}#{":#{extra_mark}" if extra_mark})
      end      
      
      def service_class name
        # dont'use constantize, it works wrong, and returns ::File instead of ::Services::File for example.
        eval("::Services::#{name.to_s.camelize}", TOPLEVEL_BINDING, __FILE__, __LINE__)
      end
      cache_method_with_params :service_class
      
      def service_name; name.split('::').last.underscore end
      cache_method_with_params :service_name
    end
    
    protected          
      def config; cluster.config end
      def logger; cluster.logger end    
      def services &b; cluster.services &b end
      
      def service_name; self.class.service_name end
    
      def apply_once key, &block
        boxes{|box| box.apply_once self.class.marker(key), &block}
      end
      
      def boxes &b
        if b
          boxes.each &b
        else
          unless @boxes
            hosts = config.tags!["#{self.class.tag}", nil] || []
            @boxes = hosts.collect{|host| cluster.boxes[host]}
          end
          @boxes
        end
      end
      
      def single_box
        boxes.size.must_be == 1
        boxes.first
      end
      
      # def require options
      #   # if args.size == 1 and args.first.is_a?(Hash)
      #   #   services = args.first
      #   # elsif args.size == 2 and args.first.is_a?(Array)
      #   #   services = {}
      #   #   args.first.each{|klass| services[klass] = args.last}
      #   # else
      #   #   raise 'invalid arguments'
      #   # end
      #   
      #   options.each do |service_name, method|
      #     key = "#{service_name}.#{method}"
      #     unless box.already_required_services.include? key
      #       klass.new(box).send method if klass.method_defined? method
      #       box.already_required_services << key
      #     end
      #   end
      # end      
      # 
      # def already_required_services
      #   
      # end
  end
end