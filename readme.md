# Simple cluster management tools

It may be **usefull if Your claster has about 1-10 boxes**, and tools like Chef, Puppet, Capistrano are too complex and proprietary for your needs.
**It's extremely easy**, there are only 3 methods. 

You probably already familiar with Rake and have it in Your project, and because ClusterManagement is just a **small Rake 
addon** it should be **easy** to add and **get started** with it.

It's ssh-agnostic and has no extra dependencies. You can use whatever ssh-tool you like (even pure Net::SSH / Net::SFTP), 
samples below done by using [Virtual Operating System][vos] and [Virtual File System][vfs] tools.

## Package Management

Define your packages, they are just rake tasks, so you probably know how to work with them:

    desc 'ruby 1.9.2'
    package ruby: :system_tools do        
      apply_once do
        installation_dir = '/usr/local/ruby'
        ruby_name = "ruby-1.9.2-p136"

        box.tmp do |tmp|
          tmp.bash "wget ftp://ftp.ruby-lang.org//pub/ruby/1.9/#{ruby_name}.tar.gz"
          tmp.bash "tar -xvzf #{ruby_name}.tar.gz"

          src_dir = tmp[ruby_name]
          src_dir.bash "./configure --prefix=#{installation_dir}"
          src_dir.bash 'make && make install'
        end

        box.home('.gemrc').write! "gem: --no-ri --no-rdoc\n"

        bindir = "#{installation_dir}/bin"
        unless box.env_file.content =~ /PATH.*#{bindir}/
          box.env_file.append %(\nexport PATH="$PATH:#{bindir}"\n)
          box.reload_env
        end
      end    
      verify{box.bash('ruby -v') =~ /ruby 1.9.2/}
    end
      
Or you can use a little more explicit notation with custom :applied? logic (:apply_once is a shortcut for :applied? & :after_applying):

    package :ruby do
      applied?{box.has_mark? :ruby}
      apply do
        ...
      end
      after_applying{box.mark :ruby}
    end
    
Let's define another package:
    
    package rails: :ruby, version: 3 do
      apply_once do
        box.bash 'gem install rails'
      end
    end
    
It's understands dependencies, so the :rails package will apply :ruby before applying itself. 

It checks if the package already has been applied to box, so you can evolve your configuration and apply it multiple times, 
it will apply only missing packages (or drop the applied? clause and it will be applied every run). It allows you
to use **iterative development**, you don't need to write all the config at once, do it by small steps, adding one package after another. 

You can also use versioning to update already installed packages - if You change version it will be reapplied next run.
And by the way, the box.mark ... is just an example check, you can use anything there.
    
And, last step - define (I intentionally leave implementation of this method to You, it's very specific to Your environment) 
to what machines it should be applied:

    module ClusterManagement
      def self.boxes
        unless @boxes    
          host = ENV['host'] || raise(":host not defined!")
          box = Vos::Box.new host: host, ssh: config.ssh!.to_h
          box.open

          @boxes = [box]
        end
        @boxes
      end
    end
    
Now, you can press the enter:

    $ rake os:rails host=myapp.com
    
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

## Service Management

[add details here]
    
## Deployment

[add more details here]
    
**You can use it also for deployment**, exactly the same way, configure it the way you like, it's just rake 
tasks.

# Temporarry stuff, don't bother to read it

- small
- uses well known tools (rake and anytingh ssh-enabled)
- support iterative development

[my_cluster]: http://github.com/alexeypetrushin/my_cluster/tree/master/lib/packages
[vos]: http://github.com/alexeypetrushin/vos
[vfs]: http://github.com/alexeypetrushin/vfs