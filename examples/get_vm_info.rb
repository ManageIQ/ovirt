require_relative './example_helper'

VM_NAME = raise "please define VM_NAME"

def indented_print(s, i)
  print "    " * i
  puts s
end

def dump_vm(vm, level = 0)
  indented_print "VM: #{vm[:name]} (#{vm[:id]})", level
  # puts "\nVM: #{vm.inspect}"

  dump_disks(vm.disks)

  puts
  indented_print "Snapshots:", level + 1
  vm.snapshots.each do |s|
    dump_snapshot(s, level + 2)
  end
end

def dump_disks(disks, level = 0)
  disks.each_with_index do |d, i|
    indented_print "DISK #{i}: #{d[:id]}", level + 1
    indented_print "image_id:         #{d[:image_id]}", level + 2
    indented_print "size:             #{d[:size]}", level + 2
    indented_print "provisioned_size: #{d[:provisioned_size]}", level + 2
    indented_print "actual_size:      #{d[:actual_size]}", level + 2
    # puts "\nDISK #{i}: #{d.inspect}"
  end
end

def dump_snapshot(s, level = 0)
  indented_print "Snapshot: #{s[:description]} (#{s[:id]}) type: #{s[:type]}", level
  # return unless (vm = s[:vm])
  disks = s.send(:disks, :disk)
  dump_disks(disks, level + 1)
end

rhevm = ExampleHelper.service
vm    = Ovirt::Vm.find_by_name(rhevm, VM_NAME)
dump_vm(vm)

exit
snap = vm.create_snapshot("API test snap")
snap.delete
