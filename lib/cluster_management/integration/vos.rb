module Vos
  class ServicesHelper < BasicObject
    def initialize box, class_namespace
      @box, @class_namespace = box, class_namespace
    end
    
    class ServiceCallback < BasicObject
      def initialize box, class_namespace, class_name
        @box, @class_namespace, @class_name = box, class_namespace, class_name
      end
      
      protected
        def method_missing m, *a, &b
          klass = "::#{@class_namespace.to_s.camelize}::#{@class_name.to_s.camelize}".constantize
          klass.new(@box).send m, *a, &b
        end
    end
    
    protected
      def method_missing class_name
        ServiceCallback.new(@box, @class_namespace, class_name)
      end
  end
  
  class Box
    def self.define_service_namespace class_namespace
      define_method class_namespace do
        ServicesHelper.new self, class_namespace
      end
    end
    define_service_namespace :services
    define_service_namespace :projects
    
    def already_required_services
      @already_required_services ||= Set.new
    end
  end
end