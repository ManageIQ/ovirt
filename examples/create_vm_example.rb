require_relative './example_helper'

CLUSTER           = raise "please define CLUSTER"
PXE_TEMPLATE_NAME = raise "please define PXE_TEMPLATE_NAME"
VM_NAME           = raise "please define VM_NAME"

rhevm = ExampleHelper.service
vm    = Ovirt::Vm.find_by_name(rhevm, VM_NAME)

unless vm.nil?
  puts "VM"
  pp vm.attributes
end

unless vm.nil?
  vm_id = vm[:id]
  puts  "DELETING VM"
  vm.destroy
  loop do
    vm = Ovirt::Vm.find_by_id(rhevm, vm_id)
    break if vm.nil?
    puts  "VM still exists"
    sleep 1.0
  end
end

pxe_template = Ovirt::Template.find_by_name(rhevm, PXE_TEMPLATE_NAME)
puts "TEMPLATE:"
pp pxe_template.attributes

cluster = Ovirt::Cluster.find_by_name(rhevm, CLUSTER)
vm      = pxe_template.clone_to_vm_via_blank_template(
  :name    => VM_NAME,
  :cluster => cluster,
)

puts "Created VM"
pp vm

vm = Ovirt::Vm.find_by_name(rhevm, VM_NAME)
puts "Found VM"
pp vm
