require_relative './example_helper'

STORAGE_DOMAIN_1 = raise "please define STORAGE_DOMAIN_1"
STORAGE_DOMAIN_2 = raise "please define STORAGE_DOMAIN_2"
VM_NAME          = raise "please define VM_NAME"

rhevm = ExampleHelper.service

sd1 = Ovirt::StorageDomain.find_by_name(rhevm, STORAGE_DOMAIN_1)
puts "SD1: #{sd1.inspect}"
sd2 = Ovirt::StorageDomain.find_by_name(rhevm, STORAGE_DOMAIN_2)
puts "SD2: #{sd2.inspect}"

vm = Ovirt::Vm.find_by_name(rhevm, VM_NAME)
puts "VM: #{vm.inspect}"

disks = vm.disks
puts "DISKS: #{disks.inspect}"

disk = disks.first
puts "DISK: #{disk.inspect}"
puts "DISK SD: #{disk[:storage_domains].inspect}"
sd_id = disk[:storage_domains].first[:id]
puts "DISK SD ID: #{sd_id.inspect}"

sd = Ovirt::StorageDomain.find_by_id(rhevm, sd_id)
puts "DISK SD: #{sd.inspect}"

if sd[:id] == sd1[:id]
  puts "SD1 MATCH"
  target_sd = sd2
elsif sd[:id] == sd2[:id]
  puts "SD2 MATCH"
  target_sd = sd1
else
  puts "MISMATCH"
  target_sd = nil
end

puts "MOVING VM from #{sd[:name]} => #{target_sd[:name]}"
action = vm.move(target_sd)
puts "ACTION: #{action.inspect}"

loop do
  status = rhevm.status(action)
  puts "STATUS: #{status.inspect}"
  break if status == 'complete'
  sleep 1
end
