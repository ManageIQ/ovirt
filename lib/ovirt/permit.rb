module Ovirt
  class Permit < Base
    self.top_level_strings  = [:name]
    self.top_level_booleans = [:administrative]
    self.top_level_objects  = [:role]
  end
end
