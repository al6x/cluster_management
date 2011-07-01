require 'spec_helper'

describe 'Dependency' do
  before :all do    
    module Services; end
    
    class ServiceStub < Service
      def apply_once key, &b
        boxes.each &b
      end
      
      def boxes
        [ServiceStub.box]
      end
      
      class << self
        attr_accessor :box
      end
    end        
    
    class BoxStub < Array
      alias_method :bash, :push
    end
  end
  after(:all){remove_constants :Services, :ServiceStub, :BoxStub}
  
  it "dependency resolving" do        
    class Services::Ruby < ServiceStub
      def install
        apply_once(:install){|box| box.bash 'install ruby'}
      end
    end
    
    class Services::Server < ServiceStub
      def restart
        boxes.each{|box| box.bash 'restart server'}
      end
    end
      
    class Services::App < ServiceStub
      def install          
        services.ruby.install        
        apply_once(:install){|box| box.bash 'install app'}
      end
      
      def update
        install        
        boxes.each{|box| box.bash 'update app'}
      end
      
      def deploy
        update
        services.server.restart
      end
    end
   
    ServiceStub.box = BoxStub.new
    
    Services::App.new.deploy
    ServiceStub.box.should == [
      'install ruby',
      'install app',
      'update app',
      'restart server'
    ]
  end
end