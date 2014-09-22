require_relative './example_helper'

rhevm = ExampleHelper.service

# pp rhevm.api

puts "NAME: #{rhevm.name}"
puts "VENDOR: #{rhevm.vendor}"
puts "VERSION: #{rhevm.version_string}"

pp rhevm.blank_template
pp rhevm.root_tag
pp rhevm.summary

puts "API:#{rhevm.api.inspect}"
puts "Capabilities:\t#{rhevm.resource_get(:capabilities)}"
#puts "Users:\t#{rhevm.resource_get(:users)}"
#puts "Groups:\t#{rhevm.resource_get(:groups)}"
puts "Roles:\t#{rhevm.resource_get(:roles)}"
puts "Tags:\t#{rhevm.resource_get(:tags)}"
puts "Datacenters:\t#{rhevm.resource_get(:datacenters)}"
puts "Storage Domains:\t#{rhevm.resource_get(:storagedomains)}"
puts "Networks:\t#{rhevm.resource_get(:networks)}"
puts "Clusters:\t#{rhevm.resource_get(:clusters)}"
puts "Hosts:\t#{rhevm.resource_get(:hosts)}"
puts "VMPools:\t#{rhevm.resource_get(:vmpools)}"
puts "VMs:\t#{rhevm.resource_get(:vms)}"
puts "Templates:\t#{rhevm.resource_get(:templates)}"
puts "Events:\t#{rhevm.resource_get(:events)}"
