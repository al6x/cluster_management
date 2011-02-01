def package *a, &b
  task *a do |task, *args|
    if b
      boxes.each do |box|
        package = Ros::Package.new task.name
        package.configure_with &b
        package.apply_to box
      end    
    end
  end  
end