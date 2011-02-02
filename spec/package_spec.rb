require 'spec_helper'
require 'cluster_management/package'

describe 'Package' do
  before :each do 
    ClusterManagement.box = :box
  end
  
  it 'should allow empty declaration' do
    package :tools
    ClusterManagement.last_task.should_not be_nil
    
    ClusterManagement.last_task = nil
    package(:tools){}
    ClusterManagement.last_task.should_not be_nil
  end
  
  it "basic" do
    check = mock()
    check.should_receive(:applied?).ordered.with(:box).and_return(false)
    check.should_receive(:apply).ordered.with(:box)
    check.should_receive(:verify).ordered.with(:box).and_return(true)
    check.should_receive(:after_applying).ordered.with(:box)
    
    the_package = nil
    package :tools, 1 do |pkg|
      the_package = pkg.package
      
      pkg.version.should == 1
      pkg.applied?{|box| check.applied?(box)}
      pkg.apply{|box| check.apply(box)}
      pkg.verify{|box| check.verify(box)}
      pkg.after_applying{|box| check.after_applying(box)}
    end
    
    the_package.version.should == 1
  end
  
  it "should not reapply package but always verify it" do
    check = mock()
    check.should_not_receive(:apply)
    check.should_receive(:verify).and_return(true)
    
    package :tools do |pkg|
      pkg.applied?{|box| true}
      pkg.apply{|box| check.apply}
      pkg.verify{|box| check.verify}
    end
  end
  
  it "should verify packages" do
    -> {
      package :tools do |pkg|
        pkg.verify{|box| false}
      end
    }.should raise_error(/invalid.*tools/)
  end
  
  it "should apply to all boxes" do
    boxes = [:a, :b]
    ClusterManagement.stub(:boxes).and_return(boxes)
    
    check = []
    package :to do |pkg|
      pkg.apply{|box| check << box}
    end
    check.should == boxes
  end
  
  describe "apply_once" do
    def build_box_for key, has_mark
      box = mock()    
      box.should_receive(:has_mark?).ordered.with(key).and_return(has_mark)
      box.should_receive(:mark).ordered.with(key)
      ClusterManagement.box = box
      box
    end
    
    it "should apply if not applied" do    
      box = build_box_for('tools', false)
    
      check = mock()
      check.should_receive(:apply_once).with(box)
    
      package :tools do |pkg|
        pkg.apply_once{|box| check.apply_once(box)}
      end
    end
    
    it "should not apply if applied" do    
      box = build_box_for('tools', true)
    
      check = mock()
      check.should_not_receive(:apply_once)
    
      package :tools do |pkg|
        pkg.apply_once{|box| check.apply_once}
      end
    end
    
    it "should support versioning" do
      box = build_box_for('tools:2', false)
    
      check = mock()
      check.should_receive(:apply_once)
    
      package :tools, 2 do |pkg|
        pkg.apply_once{|box| check.apply_once}
      end
    end
  end
end


# def version version; package.version = version end    
# def applied? &b; package.applied = b end
# def apply &b; package.apply = b end    
# def verify &b; package.verify = b end
# def after_applying &b; package.after_applying = b end    
# 
# def apply_once &b      
#   mark = package.version ? "#{package.name}:#{package.version}" : package.name
#   applied?{|box| INTEGRATION[:has_mark?].call box, mark}
#   apply &b
#   after_applying{|box| INTEGRATION[:mark].call box, mark}
# end
