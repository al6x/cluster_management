class ClusterManagement::Config < Hash
  def load_config! runtime_path    
    merge! runtime_path: runtime_path, config_path: "#{runtime_path}/config"
    
    path = "#{runtime_path}/config/config.yml"
    raise("config file must have .yml extension (#{path})!") unless path.end_with? '.yml'

    data = ::YAML.load_file path
    if data
      raise 'not a Hash' if data.class != ::Hash
      data.each{|k, v| self[k.to_sym] = v}
    end

    # converting :handy_scheme to :scheme
    if include? :handy_scheme
      raise "You can't use both :handy_scheme and :scheme!" if include?(:scheme)
      self.scheme = {}
      handy_scheme.each do |box, tags|
        tags.each do |tag|
          (self.scheme[tag.to_sym] ||= []) << box
        end
      end
    end
  end
  
  def self.attr_required *attrs
    attrs.each do |m|
      define_method(m){self[m] || raise("key :#{m} not defined!")}
    end
  end
  attr_required :scheme, :config_path, :runtime_path
  
  protected
    def method_missing m, *args
      if m =~ /=$/
        self[m[0..-2].to_sym] = args.first
      else
        self[m]
      end
    end
end
