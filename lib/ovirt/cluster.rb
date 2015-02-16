module Ovirt
  class Cluster < Base
    self.top_level_strings = [:name, :description]
    self.top_level_objects = [:data_center, :scheduling_policy]

    def self.parse_node_extended(node, hash)
      parse_first_node(node, :cpu,            hash, :attribute => [:id])
      parse_first_node(node, :version,        hash, :attribute_to_i => [:major, :minor])
      parse_first_node(node, :error_handling, hash, :node           => [:on_error])

      hash[:memory_policy] = {}
      parse_first_node_with_hash(node, 'memory_policy/overcommit', hash[:memory_policy][:overcommit] = {},
                                 :attribute_to_f => [:percent])
      parse_first_node_with_hash(node, 'memory_policy/transparent_hugepages', hash[:memory_policy][:transparent_hugepages] = {},
                                 :node_to_bool => [:enabled])
    end

    def find_network_by_name(network_name)
      self.networks.detect { |n| n[:name] == network_name }
    end
  end
end
