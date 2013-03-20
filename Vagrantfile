def Kernel.is_windows
  processor, platform, *rest = RUBY_PLATFORM.split("-")
  platform == "mingw32"
end

Vagrant::Config.run do |config|
    config.vm.box     = "squeeze32puppet3"
    config.vm.box_url = "http://files.adrienbrault.fr/squeeze32-puppet3.box"

    config.vm.customize [ "modifyvm", :id, "--name", "PHP VM" ]
    config.vm.customize [ "modifyvm", :id, "--memory", "1024", "--cpus", "1" ]

    config.vm.network :hostonly, "11.11.11.11"
    config.vm.host_name = "php.localhost"

    config.vm.share_folder "vagrant", "/vagrant", "."
    config.vm.share_folder "project", "/var/www/sites", "./sites", :nfs => !Kernel.is_windows, :create => true, :remount => true

    config.vm.provision :shell, :inline => "echo \"UTC\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"

    config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "manifests"
        puppet.module_path    = "modules"
        puppet.manifest_file  = "base.pp"
    end
end
