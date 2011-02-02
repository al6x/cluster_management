require 'rspec_ext'

require 'cluster_management/support'
require 'cluster_management/cluster_management'


# 
# Boxes stub
# 
module ClusterManagement
  class << self
    attr_accessor :box
    
    def boxes
      [box]
    end
  end
end


# 
# Integration stub
# 
ClusterManagement.integration = {
  has_mark?: -> box, mark {box.has_mark? mark},
  mark: -> box, mark {box.mark mark}
}


# 
# Task stub
# 
module ClusterManagement  
  class Task
    attr_accessor :name
    def initialize name
      @name = name
    end
  end
  
  class << self
    attr_accessor :last_task
  
    def task name, &block
      task = Task.new name      
      block.call task if block
      self.last_task = task
    end
  end
end


# 
# Logger stub
# 
module ClusterManagement
  class << self
    def logger
      @logger ||= Logger.new nil
    end
  end
end