class Services::Ruby < Service
  tag :web
  version 4
  
  def install
    # it will be called only once, it will be called next time only if You change the version
    apply_once :install do |box|            
      logger.info "installing :#{service_name}"
      box.fake_bash "apt-get install ruby"
    end
  end
end