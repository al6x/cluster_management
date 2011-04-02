module ClusterManagement
  class Config < SafeHash
    def merge_file! file_path      
      raise("config file must have .yml extension (#{file_path})!") unless file_path.end_with? '.yml'
      data = ::YAML.load_file file_path      
      if data
        data.must_be.a ::Hash        
        self.deep_merge! data            
      end
    end
    
    # def self.load file  
    #   @config = Config.new
    #   @config.merge_file! file
    # end
  end  
end