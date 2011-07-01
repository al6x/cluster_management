require 'spec_helper'

describe "Cluster" do
  before do
    @cluster = Cluster.new
    @cluster.config = Config.new
  end
  
  it "should return service by it's name" do
    service_class = mock
    service_class.should_receive(:new).and_return('mongo_db')
    Service.stub!(:service_class).and_return(service_class)
    
    @cluster.services[:mongo_db].should == 'mongo_db'
    @cluster.services.mongo_db.should == 'mongo_db'
  end
  
  it "should return box by it's name" do
    box = mock
    box.should_receive(:open)
    Box.stub!(:new).and_return(box)
        
    @cluster.boxes['app.com'].should == box
  end
end