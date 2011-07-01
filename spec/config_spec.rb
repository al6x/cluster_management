require 'spec_helper'

describe "Config" do
  it "should load and parse config file" do
    config = Config.new
    config.load_config! "#{spec_dir}/app"
    
    {      
      config_path:  "#{spec_dir}/app/config",
      runtime_path: "#{spec_dir}/app",
      
      scheme: {
        app:  ['web1.app.com', 'web2.app.com'],
        ruby: ['web1.app.com', 'web2.app.com'],
        db:   ['db.app.com']
      },
      
      nginx: {'port' => 80}
    }.each do |k, v|
      config[k].should == v
    end
  end
end