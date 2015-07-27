require 'spec_helper'

describe Ovirt::CloudInitViaFloppyPayload do
  let(:vm) { build(:vm) }

  it "cloud_init= Ovirt 3.3 and older" do
    cloud_config = "#cloud_config\nroot_password: some_password\nregenerate_ssh_keys: false\ncustom_script: \"#!/bin/bash\necho 'hi'\""

    expect(vm.service).to receive(:api).and_return(:product_info => {:version => {:major => "3", :minor => "3", :revision => "0", :build => "0"}})
    expect(vm).to         receive(:attach_floppy).with("user-data.txt" => cloud_config)

    vm.cloud_init = cloud_config
  end
end
