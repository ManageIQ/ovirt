module Ovirt
  class Storage < Base
    self.top_level_objects = [:host]

    def self.parse_node_extended(node, hash)
      parse_first_node(node, :volume_group, hash, :attribute => [:id])
    end
  end
end
