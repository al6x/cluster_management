%w(
  rake
  package
).each{|f| require "cluster_management/#{f}"}

#
# you must override this method to provide your own implementation
#
def boxes
  warn 'you must override :boxes method to provide your own behaviour'
  []
end