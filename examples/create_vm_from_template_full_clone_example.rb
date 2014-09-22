require_relative './example_helper'

VM_NAME                    = raise "please define VM_NAME"
SOURCE_TEMPLATE_NAME       = raise "please define SOURCE_TEMPLATE_NAME"
DESTINATION_STORAGE_DOMAIN = raise "please define DESTINATION_STORAGE_DOMAIN"

rhevm  = ExampleHelper.service
source = Ovirt::Template.find_by_name(rhevm, SOURCE_TEMPLATE_NAME)

unless source.nil?
  puts "Template"
  pp source.attributes
end

destination = source.create_vm(
  :name         => VM_NAME,
  :clone_type   => :full,
  :cluster      => Ovirt::Cluster.find_by_id(rhevm, source[:cluster][:id]),
  :sparse       => :false,
  :storage      => Ovirt::StorageDomain.find_by_name(rhevm, DESTINATION_STORAGE_DOMAIN)[:href],
)

puts "Created VM"
pp destination

destination = Ovirt::Vm.find_by_name(rhevm, VM_NAME)
puts "Found VM"
pp destination
