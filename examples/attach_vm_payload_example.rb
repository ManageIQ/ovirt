require_relative './example_helper'

PAYLOAD = {"test.file" => "test content"}
VM_NAME = "test_vm"

rhevm = ExampleHelper.service

puts "Finding VM..."
if vm = Ovirt::Vm.find_by_name(rhevm, VM_NAME)
  puts "Found #{VM_NAME}"

  puts "Attaching floppy payload"
  puts vm.attach_floppy(PAYLOAD)

  puts
  pp vm
end