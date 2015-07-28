require_relative './example_helper'

VM_NAME                   = raise "please define VM_NAME"
DESTINATION_TEMPLATE_NAME = raise "please define DESTINATION_TEMPLATE_NAME"

rhevm  = ExampleHelper.service
source = Ovirt::Vm.find_by_name(rhevm, VM_NAME)

unless source.nil?
  puts "VM"
  pp source.attributes
end

destination = source.create_template(:name => DESTINATION_TEMPLATE_NAME)
puts "Created Template:"
pp destination

destination = Ovirt::Template.find_by_name(rhevm, DESTINATION_TEMPLATE_NAME)
puts "Found Template:"
pp destination
