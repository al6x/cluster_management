class Services::Thin < Service
  tag :web
  
  def restart
    logger.info "restarting :#{service_name}"
    boxes.each{|box| box.fake_bash 'thin restart'}
  end
end