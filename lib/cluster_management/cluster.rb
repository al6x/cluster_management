class ClusterManagement::Cluster
  attr_accessor :config, :logger  
  attr_reader :boxes
  
  def services &b
    b ? @services.instance_eval(&b) : @services
  end
  
  class Services < BasicObject
    def initialize
      @h = ::Hash.new do |h, service_name|          
        h[service_name] = ::ClusterManagement::Service.service_class(service_name).new
      end
    end
    
    def [] service_name
      service_name.must_be.a ::Symbol
      @h[service_name.to_sym]
    end        
    
    protected
      def p msg
        ::Object.send :p, msg
      end
      
      def method_missing m, *a, &b          
        super unless a.blank? and b.blank?
        @h[m]
      end
  end

  def initialize 
    @services = Services.new
    
    @boxes = Hash.new do |h, host|
      box = config.ssh? ? Box.new(host.to_s, config.ssh.to_h) : Box.new(host.to_s)  
      box.open
      h[host] = box
    end
  end

  def configure runtime_dir            
    config.merge_file! "#{runtime_dir}/config/config.yml"
    config.set! :config_path, "#{runtime_dir}/config"
    
    r = {}
    config.boxes!.to_h.each do |box, tags|
      tags.each do |tag|
        (r[tag.to_sym] ||= []) << box
      end
    end      
    config.set! :tags, r
  end  
end