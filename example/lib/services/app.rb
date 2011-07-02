class Services::App < Service
  tag :web

  def install      
    services.ruby.install        
    apply_once :install do |box| 
      logger.info "installing :#{service_name}"
      box.fake_bash "cd #{config.app_path} && git clone app"
    end
  end

  def update
    install        
    logger.info "updating :#{service_name}"
    boxes.each{|box| box.fake_bash "cd #{config.app_path} && git pull app"}
  end

  def deploy    
    update
    logger.info "deploying :#{service_name}"  
    services.my_sql.started
    services.thin.restart
  end    
end