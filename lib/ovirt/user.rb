module Ovirt
  class User < Base
    self.top_level_strings  = [:name, :description, :domain, :user_name]
    self.top_level_booleans = [:logged_in]

    def self.parse_node_extended(node, hash)
      groups_node   = node.xpath('groups').first
      hash[:groups] = groups_node.xpath('group').collect(&:text) unless groups_node.nil?
    end
  end
end
