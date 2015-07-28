module Ovirt
  class Snapshot < Base
    self.top_level_strings    = [:description, :snapshot_status, :type]
    self.top_level_timestamps = [:date]
    self.top_level_objects    = [:vm]

    def initialize(service, options = {})
      super
      @relationships[:disks] = self[:href] + "/disks"
    end

    def delete
      destroy
      while self[:snapshot_status] == "locked" || self[:snapshot_status] == "ok"
        sleep 2
        break if (obj = self.class.find_by_href(@service, self[:href])).nil?
        replace(obj)
      end
    end
  end
end
