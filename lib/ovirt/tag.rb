module Ovirt
  class Tag < Base
    self.top_level_strings = [:name, :description]
    self.top_level_objects = [:host, :user, :vm]

    def self.parse_node_extended(node, hash)
      parent_node = node.xpath('parent').first
      unless parent_node.nil?
        tag_node = parent_node.xpath('tag').first
        unless tag_node.nil?
          parent = hash_from_id_and_href(tag_node)
          parent[:type] = 'tag'
          hash[:parent] = parent
        end
      end
    end
  end
end
