require_relative './example_helper'

SOURCE_TEMPLATE_NAME = raise "please define SOURCE_TEMPLATE_NAME"
DESTINATION_VM_NAME  = raise "please define DESTINATION_VM_NAME"

rhevm  = ExampleHelper.service
source = Ovirt::Template.find_by_name(rhevm, SOURCE_TEMPLATE_NAME)

unless source.nil?
  puts "Template"
  pp source.attributes
end

destination = source.create_vm(
  :clone_type => :linked,
  :name       => DESTINATION_VM_NAME,
  :cluster    => Ovirt::Cluster.find_by_id(rhevm, source[:cluster][:id]),
)

puts "Created VM"
pp destination

destination = Ovirt::Vm.find_by_name(rhevm, DESTINATION_VM_NAME)
puts "Found VM"
pp destination
