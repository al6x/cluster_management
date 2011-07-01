class Vos::Box
  include Vos::Helpers::Ubuntu
  
  def apply_once key, &block
    unless has_mark? key
      block.call self
      mark! key
    end
  end      
  
end