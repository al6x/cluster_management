require 'ruby_ext'
require 'vos'
require 'yaml'
require 'tilt'
require 'class_loader'
# require 'micon'
# require 'micon/rad'


# 
# Classes
# 
%w(
  support/exception
  config
  logger
  service
  integration/vfs
  integration/vos
  cluster
).each{|f| require "cluster_management/#{f}"}


# 
# Cluster
# 
CLUSTER = ClusterManagement::Cluster.new
def cluster; ::CLUSTER end


# 
# Config & Logger
# 
cluster.logger = ClusterManagement::CustomLogger.new STDOUT
cluster.logger.formatter = -> severity, datetime, progname, msg {msg}

cluster.config = ClusterManagement::Config.new