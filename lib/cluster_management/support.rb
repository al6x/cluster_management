require 'logger'

module ClusterManagement
  class << self
    # 
    # Logger
    # 
    attr_writer :logger
    def logger
      unless @logger
        @logger = Logger.new STDOUT
        @logger.formatter = -> severity, datetime, progname, msg {msg}
      end
      @logger      
    end
  end  
end