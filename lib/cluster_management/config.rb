module ClusterManagement
  class Config < SafeHash
    def merge_config! file_path      
      raise("config file must have .yml extension (#{file_path})!") unless file_path.end_with? '.yml'
      data = ::YAML.load_file file_path
      if data
        data.must_be.a ::Hash
        self.deep_merge! data            
      end
    end
  end

  def self.load_config file    
    @config = Config.new
    @config.merge_config! file
  end

  def self.config    
    @config || raise("config nod defined (use ClusterManagement.load_config to use config)!")
  end
end