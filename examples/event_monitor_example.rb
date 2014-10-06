require_relative './example_helper'

SERVER   = raise "please define SERVER"
PORT     = 443
DOMAIN   = raise "please define DOMAIN"
USERNAME = raise "please define USERNAME"
PASSWORD = raise "please define PASSWORD"

rhevm_em = RhevmEventMonitor.new(
  :server   => SERVER,
  :port     => PORT,
  :domain   => DOMAIN,
  :username => USERNAME,
  :password => PASSWORD
)

def print_object(base, caption, indent = 0, recurse = true)
  indentation = "\t" * indent
  puts "#{indentation}================= #{caption} ======================"
  base.keys.sort { |a,b| a.to_s <=> b.to_s }.each do |key|
    puts "#{indentation}#{key.to_s}:\t#{base[key].inspect}"
  end
  puts "#{indentation}relationships:\t#{base.relationships.inspect}"
  puts "#{indentation}operations:\t#{base.operations.inspect}"

  if recurse
    base.relationships.keys.sort { |a,b| a.to_s <=> b.to_s}.each do |rel|
      base.send(rel).each { |obj| print_base(obj, rel.to_s.singularize.upcase, indent+1) }
    end
  end
end

Signal.trap("INT") { rhevm_em.stop }

rhevm_em.start
rhevm_em.each do |event|
  print_object(event, "Event")
end
