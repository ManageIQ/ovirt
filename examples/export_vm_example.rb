require_relative './example_helper'

STORAGE_DOMAIN_1 = raise "please define STORAGE_DOMAIN_1"
VM_NAME          = raise "please define VM_NAME"

rhevm = ExampleHelper.service

sd1 = Ovirt::StorageDomain.find_by_name(rhevm, STORAGE_DOMAIN_1)
puts "SD1: #{sd1.inspect}"

vm = Ovirt::Vm.find_by_name(rhevm, VM_NAME)
puts "VM: #{vm.inspect}"

action = vm.export(sd1)
puts "ACTION: #{action.inspect}"

loop do
  status = rhevm.status(action)
  puts "STATUS: #{status.inspect}"
  break if status == 'complete'
  sleep 1
end
