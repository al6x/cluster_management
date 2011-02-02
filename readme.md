# Simple cluster management tools

It may be **usefull if Your claster has about 1-10 boxes**, and tools like Chef, Puppet, Capistrano are too complex and proprietary for your needs.
**It's extremely easy**, there are only 3 methods.

Define your packages, they are just rake tasks, so you probably know how to work with them:

    namespace :os do
      package :ruby do
        applied?{|box| box.has_mark? :ruby}
        apply do |box| 
          box.bash 'apt-get install ruby'
          box.mark :ruby
        end
      end

      package :rails => :ruby do
        applied?{|box| box.has_mark? :rails}
        apply do |box| 
          box.bash 'gem install rails'
          box.mark :rails
        end
      end
    end
    
Define to what it should be applied:

    def each_box &b
      host = ENV['host'] || raise(":host not defined!")
      box = Rsh::Box.new host: host, ssh: {user: 'root', password: 'secret'}
      b.call box
    end
    
Run it:

    $ rake os:rails host=webapp.com
    
**You can use it also for deployment**, exactly the same way, configure it the way you like, it's just rake 
tasks. And by the way, the *box.mark ...* is just an example check, you can use anything there.

It checks if the package already has been applied to box, so you can evolve your configuration and apply 
it multiple times, it will apply only missing packages (or drop the *applied?* clause and it will be applied every run).

- small
- uses well known tools (rake and anytingh ssh-enabled)
- support iterative development


$ rake app_server host=universal.xxx.com
applying 'basic:os:5' to '<Box: universal.xxx.com>'
applying 'basic:apt' to '<Box: universal.xxx.com>'
applying 'basic:system_tools' to '<Box: universal.xxx.com>'
applying 'basic:ruby' to '<Box: universal.xxx.com>'
  building ... done
  updating path ... done
applying 'basic:git' to '<Box: universal.xxx.com>'
applying 'basic:security:6' to '<Box: universal.xxx.com>'
applying 'basic:manual_management:2' to '<Box: universal.xxx.com>'
applying 'app_server:fake_gem:2' to '<Box: universal.xxx.com>'
applying 'app_server:custom_ruby:3' to '<Box: universal.xxx.com>'

$ rake -T
rake app_server               # app server
rake app_server:custom_ruby   # custom ruby (with encoding globally set to unicode and enabled fake_gem hack)
rake app_server:fake_gem      # fake_gem
rake basic                    # Box with basic packages installed
rake basic:apt                # apt
rake basic:git                # git
rake basic:manual_management  # Makes box handy for manual management
rake basic:os                 # Checks OS version and add some very basic stuff
rake basic:ruby               # ruby
rake basic:security           # security
rake basic:system_tools       # System tools, mainly for build support
rake db                       # db
rake db:mongodb               # MongoDB
