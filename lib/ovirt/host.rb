module Ovirt
  class Host < Base
    self.top_level_strings  = [:name, :type, :address]
    self.top_level_integers = [:port, :memory, :max_scheduling_memory]
    self.top_level_booleans = [:storage_manager]
    self.top_level_objects  = [:cluster]

    def self.parse_node_extended(node, hash)
      hash[:relationships][:host_nics] = hash[:relationships].delete(:nics)

      parse_first_node(node, :certificate, hash,
                       :node => [:organization, :subject])

      parse_first_node(node, :status, hash,
                       :node => [:state])

      parse_first_node(node, :version, hash,
                       :attribute => [:major, :minor, :build, :revision, :full_version])

      parse_first_node(node, :hardware_information, hash,
                       :node => [:manufacturer, :version, :serial_number, :product_name, :uuid, :family])

      parse_first_node(node, :power_management, hash,
                       :attribute    => [:type],
                       :node         => [:address, :username, :options],
                       :node_to_bool => [:enabled])

      parse_first_node(node, :ksm, hash,
                       :node_to_bool => [:enabled])

      parse_first_node(node, :transparent_hugepages, hash,
                       :node_to_bool => [:enabled])

      parse_first_node(node, :iscsi, hash,
                       :node => [:initiator])

      parse_first_node(node, :ssh, hash,
                       :node => [:port, :fingerprint])

      parse_first_node(node, :cpu, hash,
                       :node      => [:name],
                       :node_to_i => [:speed])

      if has_first_node?(node, 'cpu/topology')
        parse_first_node_with_hash(node, 'cpu/topology', hash.store_path(:cpu, :topology, {}),
                                   :attribute_to_i => [:sockets, :cores])
      end

      parse_first_node(node, :summary, hash,
                       :node_to_i => [:active, :migrating, :total])

      parse_first_node(node, :os, hash,
                       :attribute => [:type])

      if has_first_node?(node, 'os/version')
        parse_first_node_with_hash(node, 'os/version', hash.store_path(:os, :version, {}),
                                   :attribute => [:full_version, :major, :minor, :build])
      end

      parse_first_node(node, :libvirt_version, hash,
                       :attribute => [:major, :minor, :build, :revision, :full_version])
    end
  end
end
