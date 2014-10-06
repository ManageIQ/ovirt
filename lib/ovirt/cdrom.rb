module Ovirt
  class Cdrom < Base

    self.top_level_objects  = [:vm, :file]

    def self.parse_xml(xml)
      node, hash = xml_to_hash(xml)

      hash
    end
  end
end