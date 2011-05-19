require 'logger'

class ClusterManagement::CustomLogger < Logger
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