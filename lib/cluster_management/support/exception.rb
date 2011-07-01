# warn 'stack trace filtering enabled'

Exception.metaclass_eval do
  attr_accessor :filters
end
Exception.filters = [
  "/gems/haml",
  "/gems/tilt",
  "/gems/facets",
  "/gems/rspec",
  
  "/timeout.rb",
    
  'lib/fake_gem',
  'rubygems/custom_require',
  
  'lib/ruby_ext',
  
  'lib/cluster_management',
  
  'bin/rake',
  'lib/rake',
  
  "/monitor",
  "/synchronize",
  "/class_loader",
  "/micon"
]
Exception.filters = []

Exception.class_eval do
  alias_method :set_backtrace_without_filter, :set_backtrace
  def set_backtrace array
    set_backtrace_without_filter array.sfilter(::Exception.filters)
  end
end