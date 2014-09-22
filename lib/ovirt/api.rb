module Ovirt
  class Api < Object

    def self.parse_xml(xml)
      node, hash                      = xml_to_hash(xml)

      parse_first_node(node, :product_info, hash,
                       :node         => [:name, :vendor])

      parse_first_node_with_hash(node, 'product_info/version', hash[:product_info][:version] = {},
                       :attribute => [:major, :minor, :build, :revision])

      hash[:summary] = {}
      [:vms, :hosts, :users, :storage_domains].each do |type|
        parse_first_node_with_hash(node, "summary/#{type}", hash[:summary][type] = {},
                         :node_to_i => [:total, :active])
      end

      hash[:special_objects] = {}
      node.xpath('special_objects/link').each do |link|
        hash[:special_objects][link['rel'].to_sym] = link['href']
      end


      # There should not be any actions defined on the api
      hash.delete(:actions) if hash[:actions].empty?

      hash
    end
  end
end
