module ClusterManagement
  class << self
    # 
    # use :integration attribute to provide integration with your tool (use integration/rsh as a sample).
    # 
    attr_writer :integration
    def integration
      unless @integration
        not_supported = -> *args {raise "you must provide your own implementation!"}
        @integration = {
          has_mark?: not_supported,
          mark: not_supported
        }
      end
      @integration
    end
    
    
    #
    # you must override this method to provide your own implementation
    #
    attr_writer :boxes
    def boxes
      unless @boxes
        warn('you must override :boxes method to provide your own behaviour')
        return []
      end
      @boxes
    end
    
    
    # 
    # Rake integration
    # 
    def rake_task *args, &block
      task *args, &block
    end        
  end  
end