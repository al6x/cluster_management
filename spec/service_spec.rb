require 'spec_helper'

describe "Service" do
  before{module Services; end}
  after{remove_constants :Services}
  
  it "should return service class by service name" do
    class Services::App; end
    Service.service_class(:app).should == Services::App    
  end
  
  it "version, tag, marker" do
    class Services::Db < Service
      service_name.should == :db
    end
    
    -> {Services::Db.tag}.should raise_error(/not tagged/)
    Services::Db.version.should == 1
      
    class Services::Db
      tag :db
      version 2
      
      tag.should == :db
      version.should == 2
      marker.should == 'db:2'
    end         
  end

  it "shold return only boxes this service should be deployed" do
    cluster = Cluster.new
    cluster.stub!(:boxes).and_return(
      'web1.app.com' => :web1, 'web2.app.com' => :web2, 'db.app.com' => :db
    )
    cluster.config = Config.new    
    cluster.config.scheme = {
      app:  ['web1.app.com', 'web2.app.com'],
      db:   ['db.app.com']
    }
    
    class Services::App < Service
      tag :app
    end
    app = Services::App.new
    app.stub!(:cluster).and_return(cluster)
    
    app.send(:boxes).sort.should == [:web1, :web2]
  end
  
  it "single box" do
    class Services::App < Service; end
    app = Services::App.new
    app.stub!(:boxes).and_return([:a, :b])
    -> {app.send(:box)}.should raise_error(AssertionError)
    app.stub!(:boxes).and_return([:a])
    app.send(:box).should == :a
  end
  
  it "should be applied only once if required" do    
    box = mock
    box.should_receive :apply_once do |key, &b| 
      key.should == 'app:2:install'
      b.call box
    end
    box.should_receive(:install_app)
    
    class Services::App < Service
      version 2
      
      def install
        apply_once :install do |box|
          box.install_app
        end
      end
    end
    app = Services::App.new
    app.stub!(:boxes).and_return([box])
    app.install
  end
end