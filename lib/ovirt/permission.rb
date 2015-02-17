module Ovirt
  class Permission < Base
    self.top_level_objects = [:role, :user]

    def self.parse_node_extended(node, hash)
      [:template].each do |type|
        subject_node = node.xpath(type.to_s).first
        next if subject_node.nil?
        subject        = hash_from_id_and_href(subject_node)
        subject[:type] = type
        hash[:subject] = subject
      end
    end
  end
end
