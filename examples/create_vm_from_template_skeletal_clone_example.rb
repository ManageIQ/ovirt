require_relative './example_helper'

DESTINATION_STORAGE_DOMAIN = raise "please define DESTINATION_STORAGE_DOMAIN"
DESTINATION_VM_NAME        = raise "please define DESTINATION_VM_NAME"
SOURCE_TEMPLATE_NAME       = raise "please define SOURCE_TEMPLATE_NAME"

rhevm  = ExampleHelper.service
source = Ovirt::Template.find_by_name(rhevm, SOURCE_TEMPLATE_NAME)

unless source.nil?
  puts "Template"
  pp source.attributes
end

destination = source.create_vm(
  :name       => DESTINATION_VM_NAME,
  :clone_type => :skeletal,
  :cluster    => Ovirt::Cluster.find_by_id(rhevm, source[:cluster][:id]),
  :sparse     => :false,
  :storage    => Ovirt::StorageDomain.find_by_name(rhevm, DESTINATION_STORAGE_DOMAIN)[:href],
)

puts "Created VM"
pp destination

destination = Ovirt::Vm.find_by_name(rhevm, DESTINATION_VM_NAME)
puts "Found VM"
pp destination
