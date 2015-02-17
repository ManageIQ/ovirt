module Ovirt
  class Vmpool < Base
    self.top_level_strings  = [:name, :description]
    self.top_level_integers = [:size]
    self.top_level_objects  = [:cluster, :template]
  end
end
