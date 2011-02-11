module ClusterManagement
  class Package < Hash
    class Dsl
      attr_reader :package, :box

      def initialize package, box
        @package, @box = package, box
      end

      def version; package.version end    
        
      def applied? &b; package.applied = b end
      def apply &b; package.apply = b end    
      def verify &b; package.verify = b end
      def after_applying &b; package.after_applying = b end    
      
      def apply_once &b      
        mark = package.version ? "#{package.name}:#{package.version}" : package.name.to_s
        applied?{ClusterManagement.integration[:has_mark?].call box, mark}
        apply &b
        after_applying{ClusterManagement.integration[:mark].call box, mark}
      end
    end
    
    attr_accessor :applied, :apply, :verify, :after_applying, :name, :version
    
    def initialize name, version
      @name, @version = name, version
    end
    
    def configure box, &b
      dsl = Dsl.new self, box
      dsl.instance_eval &b

      if applied
        package_applied = applied.call box
      else
        package_applied = false
      end
      
      if apply
        unless package_applied
          ClusterManagement.logger.info %(applying '#{name}#{version ? ":#{version}" : ''}' to '#{box}'\n)
          apply.call box
        
          if verify
            verified = verify.call box
            raise "invalid '#{name}' package for '#{box}'!" unless verified
          end
        
          after_applying && after_applying.call(box)
        end
      else
        if verify
          verified = verify.call box
          raise "invalid '#{name}' package for '#{box}'!" unless verified
        end
      end
    end
  end  
end

def packager name_or_options, version = nil, &block
  version ||= name_or_options.delete :version if name_or_options.is_a? Hash
  ClusterManagement.rake_task name_or_options do |task, *args|
    if block
      ClusterManagement.boxes.each do |box|
        package = ClusterManagement::Package.new task.name, version
        package.configure box, &block
      end
    end
  end  
end