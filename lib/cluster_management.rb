%w(
  support
  package
  cluster_management  
).each{|f| require "cluster_management/#{f}"}

require 'cluster_management/integration/vos' unless $cluster_management_dont_include_integration