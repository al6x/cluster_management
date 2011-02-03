# Simple cluster management tools

It may be **usefull if Your claster has about 1-10 boxes**, and tools like Chef, Puppet, Capistrano are too complex and proprietary for your needs.
**It's extremely easy**, there are only 3 methods.

## Package management

Define your packages, they are just rake tasks, so you probably know how to work with them:

    namespace :basic do
      package :ruby do
        applied?{box.has_mark? :ruby}
        apply do
          box.bash 'apt-get install ruby'          
        end
        after_applying{box.mark :ruby}
      end
    end
      
or you can use a little shorter notation (it's equivalent to the previous):

    namespace :app_server, 3 do
      package rails: :ruby do
        apply_once do
          box.bash 'gem install rails'
        end
      end
    end
    
And it's understands dependencies, so the :rails package will apply :ruby before applying itself. 
It also support iterative development, so you don't need to write all the config at once, do it by small steps, adding one package after another. 
And you can use versioning to update already installed packages - if you change version of some package it will be reapplied next run.
    
And, last step - define (I intentionally leave implementation of this method to You, it's very specific to Your environment) 
to what machines it should be applied:

    module ClusterManagement
      def self.boxes
        unless @boxes    
          host = ENV['host'] || raise(":host not defined!")
          box = Rsh::Box.new host: host, ssh: config.ssh!.to_h
          box.open

          @boxes = [box]
        end
        @boxes
      end
    end
    
Now, you can press the enter:

    $ rake os:rails host=webapp.com
    
and packager will do all the job of installing and configuring your cluster boxes, and prints you something like that 
(it's a sample output of some of my own box, you can see config details here [my_cluster][my_cluster]):
    
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
    
You can also use standard Rake -T command to see docs (it's also from my config, details are here [my_cluster][my_cluster]):

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

## Runtime services

[add details here]
    
## Deployment

[add more details here]
    
**You can use it also for deployment**, exactly the same way, configure it the way you like, it's just rake 
tasks. And by the way, the *box.mark ...* is just an example check, you can use anything there.

It checks if the package already has been applied to box, so you can evolve your configuration and apply 
it multiple times, it will apply only missing packages (or drop the *applied?* clause and it will be applied every run).

# Old stuff, don't bother to reed it

- small
- uses well known tools (rake and anytingh ssh-enabled)
- support iterative development




[my_cluster]: https://github.com/alexeypetrushin/my_cluster/tree/master/lib/packages