module Ovirt
  class Role < Base
    self.top_level_strings  = [:name, :description]
    self.top_level_booleans = [:administrative, :mutable]
  end
end
