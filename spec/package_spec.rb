require 'spec_helper'
require 'cluster_management/package'

describe 'Package' do
  before :each do
    ClusterManagement.box = :box
  end
  
  it 'should allow empty declaration' do
    packager :tools
    ClusterManagement.last_task.should_not be_nil
    
    ClusterManagement.last_task = nil
    packager(:tools){}
    ClusterManagement.last_task.should_not be_nil
  end
  
  it "basic" do
    check = mock()
    check.should_receive(:applied?).ordered.and_return(false)
    check.should_receive(:apply).ordered
    check.should_receive(:verify).ordered.and_return(true)
    check.should_receive(:after_applying).ordered
    
    the_package, the_box = nil, nil
    packager :tools, 1 do
      package.is_a?(ClusterManagement::Package).should == true
      version.should == 1
      box.should == :box
      
      
      applied?{check.applied?(box)}
      apply{check.apply(box)}
      verify{check.verify(box)}
      after_applying{check.after_applying(box)}
    end
  end
  
  it "should not reapply package or verify it after it has been appied" do
    check = mock()
    check.should_not_receive(:apply)
    check.should_not_receive(:verify)
    
    packager :tools do
      applied?{true}
      apply{check.apply}
      verify{check.verify}
    end
  end
  
  it "should always verify packages if there's :verify without :apply" do
    -> {
      packager :tools do
        verify{false}
      end
    }.should raise_error(/invalid.*tools/)
  end
  
  it "should apply to all boxes" do
    boxes = [:a, :b]
    ClusterManagement.stub(:boxes).and_return(boxes)
    
    check = []
    packager :tools do
      apply{check << box}
    end
    check.should == boxes
  end
  
  it 'should support version attribute' do
    packager :tools, 2 do
      version.should == 2
    end
    
    packager tools: :os, version: 2 do
      version.should == 2
    end
  end
  
  describe "apply_once" do
    def build_box_for key, has_mark
      box = mock()    
      box.should_receive(:has_mark?).ordered.with(key).and_return(has_mark)
      box.should_receive(:mark).ordered.with(key) unless has_mark
      ClusterManagement.box = box
      box
    end
    
    it "should apply if not applied" do    
      box = build_box_for('tools', false)
    
      check = mock()
      check.should_receive(:apply_once).with(box)
    
      packager :tools do
        apply_once{check.apply_once(box)}
      end
    end
    
    it "should not apply if applied" do    
      box = build_box_for('tools', true)
    
      check = mock()
      check.should_not_receive(:apply_once)
    
      packager :tools do
        apply_once{check.apply_once}
      end
    end
    
    it "should support versioning" do
      box = build_box_for('tools:2', false)
    
      check = mock()
      check.should_receive(:apply_once)
    
      packager :tools, 2 do
        apply_once{check.apply_once}
      end
    end
  end
end