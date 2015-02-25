module Ovirt
  class Host < Base
    def self.parse_node_extended(_node, hash)
      hash[:relationships][:host_nics] = hash[:relationships].delete(:nics)
    end
  end
end
