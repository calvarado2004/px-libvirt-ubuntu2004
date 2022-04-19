#number of worker nodes
NUM_WORKERS = 3
# number of extra disks per worker
NUM_DISKS = 1
# size of each disk in gigabytes
DISK_GBS = 203

MAC = "52:54:00:00:01:1"

KUBERNETES_VERSION = "1.23.5"

ENV["VAGRANT_EXPERIMENTAL"] = "disks"

MASTER_IP = "192.168.121.100"
WORKER_IP_BASE = "192.168.121.2" # 200, 201, ...
TOKEN = "yi6muo.4ytkfl3l6vl8zfpk"

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provision "shell", path: "common.sh",
    env: { "KUBERNETES_VERSION" => KUBERNETES_VERSION }

  config.vm.provision "shell", path: "local-storage/create-volumes.sh"
  config.vm.disk :disk, size: "120GB", primary: true
  
  config.vm.define "master.calvarado04.com" do |master|
    master.vm.hostname = "master.calvarado04.com"
    #master.vm.network :private_network, :ip => MASTER_IP
    master.vm.provider :libvirt do |libvirt|
      libvirt.default_prefix = "kvm-"
      libvirt.cpu_mode = 'host-passthrough'
      libvirt.graphics_type = 'none'
      libvirt.memory = 6144
      libvirt.cpus = 2
      libvirt.qemu_use_session = false
      libvirt.machine_virtual_size = 70
      libvirt.management_network_mac = MAC + 9.to_s
    end
  
    
    master.vm.provision :file do |file|
      file.source = "calico.yml"
      file.destination = "/tmp/calico.yml"
    end

    master.vm.provision "shell", path: "master.sh",
      env: { "MASTER_IP" => MASTER_IP, "TOKEN" => TOKEN, "KUBERNETES_VERSION" => KUBERNETES_VERSION }

    master.vm.provision :file do |file|
      file.source = "local-storage/storageclass.yaml"
      file.destination = "/tmp/local-storage-storageclass.yaml"
    end
    master.vm.provision :file do |file|
      file.source = "local-storage/provisioner.yaml"
      file.destination = "/tmp/local-storage-provisioner.yaml"
    end
    master.vm.provision "shell", path: "local-storage/install.sh"
   
    master.vm.provision :file do |file|
      file.source = "nodelocaldns.yaml"
      file.destination = "/tmp/nodelocaldns.yaml"
    end

    master.vm.provision :file do |file|
      file.source = "portworx-enterprise.yaml"
      file.destination = "/tmp/portworx-enterprise.yaml"
    end

    
    master.vm.provision :file do |file|
      file.source = "portworx-essentials.yaml"
      file.destination = "/tmp/portworx-essentials.yaml"
    end
    
    master.vm.provision :file do |file|
      file.source = "metrics.yaml"
      file.destination = "/tmp/metrics.yaml"
    end

    master.vm.provision "shell", path: "portworx.sh"

    master.vm.provision :file do |file|
      file.source = "resolved.conf"
      file.destination = "/etc/systemd/resolved.conf"
    end
   end


  (0..NUM_WORKERS-1).each do |i|
    config.vm.define "worker#{i}.calvarado04.com" do |worker|

      worker.vm.hostname = "worker#{i}.calvarado04.com"

      #worker.vm.network :private_network, :ip => "#{WORKER_IP_BASE}" + i.to_s.rjust(2, '0')
      
      worker.vm.provider :libvirt do |libvirt|
        libvirt.default_prefix = "kvm-"
        libvirt.cpu_mode = 'host-passthrough'
        libvirt.graphics_type = 'none'
        libvirt.memory = 12288
        libvirt.cpus = 2
        libvirt.qemu_use_session = false
        libvirt.machine_virtual_size = 70
        libvirt.storage :file, :size => '40G'
        libvirt.storage :file, :size => '203G'
        libvirt.management_network_mac = MAC + i.to_s
      end    
     

      worker.vm.provision :file do |file|
        file.source = "resolved.conf"
        file.destination = "/etc/systemd/resolved.conf"
      end
 
      worker.vm.provision "shell", path: "worker.sh",
        env: { "MASTER_IP" => MASTER_IP, "TOKEN" => TOKEN }
    end
  end
end
