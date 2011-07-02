class Services::MySql < Service
  tag :db
  def started
    logger.info "ensuring mysql is running"
    box.fake_bash 'mysql start' unless box.fake_bash('ps -A') =~ /mysql/
  end
end