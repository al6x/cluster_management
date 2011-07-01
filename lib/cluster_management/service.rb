class ClusterManagement::Service
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
        tag.must_be.a Symbol
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
    
    def service_name; name.split('::').last.underscore.to_sym end
    cache_method_with_params :service_name
  end
  
  protected          
    def config; cluster.config end
    def logger; cluster.logger end    
    def services &b; cluster.services &b end
    
    def service_name; self.class.service_name end
  
    def apply_once key, &block
      boxes.each{|box| box.apply_once self.class.marker(key), &block}
    end
    
    def boxes
      @boxes ||= begin
        hosts = config.scheme[self.class.tag] || []
        @boxes = hosts.collect{|host| cluster.boxes[host]}
      end
    end
    
    def box
      boxes.size.must_be == 1
      boxes.first
    end
end