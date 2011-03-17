require 'logger'

module ClusterManagement
  class CustomLogger < Logger
    def info msg
      super "#{msg}\n"
    end
    
    def warn msg
      super "#{msg}\n"
    end
    
    def error msg
      super "#{msg}\n"
    end
  end
  
  # attr_writer :logger
  # def self.logger
  #   unless @logger
  #     @logger = CustomLogger.new STDOUT
  #     @logger.formatter = -> severity, datetime, progname, msg {msg}
  #   end
  #   @logger      
  # end
end