module Ovirt
  module CloudInitViaFloppyPayload
    def cloud_init=(content)
      attach_floppy("user-data.txt" => content)
    end
  end
end
