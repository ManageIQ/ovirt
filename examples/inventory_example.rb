require_relative './example_helper'

def puts_caption(caption, indent)
  puts "#{indent}================= #{caption} ======================"
end

def print_object(base, caption, indent = 0, recurse = true)
  indentation = "\t" * indent
  puts_caption(caption, indentation)
  base.keys.sort_by(&:to_s).each do |key|
    puts "#{indentation}#{key}:\t#{base[key].inspect}"
  end
  puts "#{indentation}relationships:\t#{base.relationships.inspect}"
  puts "#{indentation}operations:\t#{base.operations.inspect}"

  if recurse
    base.relationships.keys.sort_by(&:to_s).each do |rel|
      begin
        new_caption = rel.to_s.singularize.upcase
        base.send(rel).each { |obj| print_object(obj, new_caption, indent + 1) }
      rescue NameError
        puts_caption(new_caption, indentation)
        puts "#{indentation}Ignoring #{rel} relationship"
      rescue Ovirt::Error => err
        puts_caption(new_caption, indentation)
        puts "#{indentation}Ignoring #{rel} relationship due to ovirt error: #{err}"
      rescue RestClient::InternalServerError => err
        puts_caption(new_caption, indentation)
        puts "#{indentation}Ignoring #{rel} relationship due to rest client error: #{err}"
      end
    end
  end
end

def collect(rhevm, method, caption = nil)
  caption ||= method.to_s
  puts ">>> Collecting #{caption.upcase} <<<"
  rhevm.send(method).each { |obj| print_object(obj, caption.singularize.upcase) }
  puts ">>> Collecting #{caption.upcase} COMPLETE <<<"
  puts "----------------------------------------------"
end

rhevm = Ovirt::Inventory.new(ExampleHelper.service_attributes)
collect(rhevm, :datacenters)
collect(rhevm, :clusters)
collect(rhevm, :hosts)
collect(rhevm, :vmpools)
collect(rhevm, :vms)
collect(rhevm, :templates)
collect(rhevm, :networks)
collect(rhevm, :events)
collect(rhevm, :roles)
