%w(
  support
  package
  cluster_management
).each{|f| require "cluster_management/#{f}"}