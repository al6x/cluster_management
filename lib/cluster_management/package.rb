module Ros
  class Package < Hash
    class Dsl
      attr_reader :package

      def initialize package
        @package = package
      end

      def version version; package.version = version end    
      def applied? &b; package.applied = b end
      def apply &b; package.apply = b end    
      def verify &b; package.verify = b end
      def after_applying &b; package.after_applying = b end    
    end
    
    attr_accessor :applied, :apply, :verify, :after_applying, :name, :version
    
    def initialize name
      @name = name
    end
    
    def configure_with &b
      dsl = Dsl.new self
      b.call dsl
    end
    
    def apply_to box
      package_applied = applied && applied.call(box)
      if apply and !package_applied
        print "applying '#{name}#{version}' to '#{box}'\n"              
        apply.call box
      end
      raise "invalid '#{name}' package for '#{box}'!" if verify and !verify.call(box)
      after_applying && after_applying.call(box)
      # print "done\n" if apply and !package_applied              
    end
  end  
end