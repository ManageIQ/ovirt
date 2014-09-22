require_relative './example_helper'

VM_NAME = raise "please define VM_NAME"

rhevm = ExampleHelper.service
hosts = Ovirt::Host.all(rhevm)
host  = hosts.first

vm = Ovirt::Vm.find_by_name(rhevm, VM_NAME)
puts "VM Placement Policy: #{vm[:placement_policy].inspect}"

puts "Setting Host Affinity to: #{host[:name].inspect} with ID=#{host[:id].inspect}"
vm.host_affinity = host

vm = Ovirt::Vm.find_by_name(rhevm, VM_NAME)
puts "VM Placement Policy: #{vm[:placement_policy].inspect}"

puts "Unsetting Host Affinity"
vm.host_affinity = nil

vm = Ovirt::Vm.find_by_name(rhevm, VM_NAME)
puts "VM Placement Policy: #{vm[:placement_policy].inspect}"
