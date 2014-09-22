require_relative './example_helper'

CLUSTER_NAME  = raise "please define CLUSTER_NAME"
ISO_NAME      = raise "please define ISO_NAME"
TEMPLATE_NAME = raise "please define TEMPLATE_NAME"
ROOT_PASSWORD = raise "please define ROOT_PASSWORD"
VM_NAME       = raise "please define VM_NAME"

rhevm    = ExampleHelper.service
cluster  = Ovirt::Cluster.find_by_name(rhevm, CLUSTER_NAME)
template = Ovirt::Template.find_by_name(rhevm, TEMPLATE_NAME)

payload  = { "ks.cfg" => <<-EOF }
##### RHEL 6.2 Desktop Kickstart file #####

### Install info
install
cdrom
lang en_US.UTF-8
keyboard us

#Configure Networking based on values from provisioning dialog
network --bootproto=dhcp --onboot=yes --device=eth0 --noipv6

rootpw --iscrypted #{ROOT_PASSWORD}
firewall --service=ssh
authconfig --enableshadow --passalgo=sha512
selinux --enforcing
timezone --utc America/New_York
poweroff
shutdown

### Post Install Scripts
%post --log=/root/ks-post.log

# Install virtualization agent package
yum -y install rhev-agent

### End Post-Install Script
%end

### Install standard desktop packages
%packages --nobase
@core
%end

### Done
EOF

def create_or_replace_vm(rhevm, vm_name, template, cluster)
  puts "Finding  VM #{vm_name}"
  vm = Ovirt::Vm.find_by_name(rhevm, vm_name)

  if vm
    print "Deleting VM #{vm_name}"
    vm_id = vm[:id]
    vm.destroy
    loop do
      vm = Ovirt::Vm.find_by_id(rhevm, vm_id)
      break if vm.nil?
      print "."
      sleep 1
    end
    puts
  end

  puts "Creating VM #{vm_name}"
  template.clone_to_vm_via_blank_template(
    :name    => vm_name,
    :cluster => cluster,
  )
end

def wait_for_power_off(vm)
  print "Waiting for power off"
  loop do
    vm.reload
    break if vm[:status][:state] == "down"
    print "."
    sleep 10
  end
  puts
end

def boot_with_retry(vm, iso_name)
  print "Booting from ISO"
  begin
    ret = vm.boot_from_cdrom(iso_name)
  rescue OvirtVmNotReadyToBoot
    print "."
    sleep 1
    retry
  end
  puts
  puts ret
end

vm = create_or_replace_vm(rhevm, VM_NAME, template, cluster)
puts

puts "Attaching floppy payload"
puts vm.attach_floppy(payload)

boot_with_retry(vm, ISO_NAME)
puts

wait_for_power_off(vm)

puts "Detaching floppy payload"
puts vm.detach_floppy

puts
pp vm
