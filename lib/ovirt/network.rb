module Ovirt
  class Network < Base
    self.top_level_strings  = [:name, :description]
    self.top_level_booleans = [:stp, :display]
    self.top_level_objects  = [:data_center, :cluster, :vlan]

    def self.parse_node_extended(node, hash)
      parse_first_node(node, :status, hash, :node => [:state])
    end
  end
end
