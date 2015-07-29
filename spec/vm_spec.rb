describe Ovirt::Vm do
  let(:service) { vm.service }
  let(:vm)      { build(:vm_full) }

  context "#create_disk" do
    before do
      @resource_url = "#{vm.attributes[:href]}/disks"
      @base_options = {
        :storage           => "aa7e70e5-abcd-1234-a605-92ce6ba652a8",
        :id                => "01eae62b-90df-424d-978c-beaa7eb2f7f6",
        :href              => "/api/templates/54f1b9f4-0e89-4c72-9a26-f94dcb857264/disks/01eae62b-90df-424d-978c-beaa7eb2f7f6",
        :name              => "bd-clone_Disk1",
        :interface         => "virtio",
        :format            => "raw",
        :image_id          => "a791ba77-8cc1-44de-9945-69f0a291cc47",
        :size              => 10_737_418_240,
        :provisioned_size  => 10_737_418_240,
        :actual_size       => 1_316_855_808,
        :sparse            => true,
        :bootable          => true,
        :wipe_after_delete => true,
        :propagate_errors  => true,
        :status            => {:state => "ok"},
        :storage_domains   => [{:id => "aa7e70e5-40d0-43e2-a605-92ce6ba652a8"}],
        :storage_domain_id => "aa7e70e5-40d0-43e2-a605-92ce6ba652a8"
      }
      @base_data = <<-EOX.chomp
<disk>
  <name>bd-clone_Disk1</name>
  <interface>virtio</interface>
  <format>raw</format>
  <size>10737418240</size>
  <sparse>true</sparse>
  <bootable>true</bootable>
  <wipe_after_delete>true</wipe_after_delete>
  <propagate_errors>true</propagate_errors>
  <storage_domains>
    <storage_domain id=\"aa7e70e5-abcd-1234-a605-92ce6ba652a8\"/>
  </storage_domains>
</disk>
EOX
    end

    [:sparse, :bootable, :wipe_after_delete, :propagate_errors].each do |boolean_key|
      context "xml #{boolean_key} value" do
        it "set to true" do
          expected_data = @base_data
          options       = @base_options.merge(boolean_key => true)

          expect(service).to receive(:resource_post).once.with(@resource_url, expected_data)
          vm.create_disk(options)
        end

        it "set to false" do
          expected_data = @base_data.gsub("<#{boolean_key}>true</#{boolean_key}>", "<#{boolean_key}>false</#{boolean_key}>")
          options       = @base_options.merge(boolean_key => false)

          expect(service).to receive(:resource_post).once.with(@resource_url, expected_data)
          vm.create_disk(options)
        end

        it "unset" do
          expected_data = @base_data.gsub("  <#{boolean_key}>true</#{boolean_key}>\n", "")
          options       = @base_options.dup
          options.delete(boolean_key)

          expect(service).to receive(:resource_post).once.with(@resource_url, expected_data)
          vm.create_disk(options)
        end
      end
    end
  end

  context "#create_nic" do
    before do
      @name         = 'nic_name'
      @resource_url = "#{vm.attributes[:href]}/nics"
      @base_options = {:name => @name}
    end

    def expected_data(element)
      <<-EOX.chomp
<nic>
  <name>#{@name}</name>
  #{element}
</nic>
EOX
    end

    it "populates the interface" do
      interface = 'interface'
      expect(service).to receive(:resource_post).once.with(
        @resource_url, expected_data("<interface>#{interface}</interface>"))
      vm.create_nic(@base_options.merge(:interface => interface))
    end

    it "populates the network id" do
      network_id = 'network_id'
      expect(service).to receive(:resource_post).once.with(
        @resource_url, expected_data("<network id=\"#{network_id}\"/>"))
      vm.create_nic(@base_options.merge(:network_id => network_id))
    end

    it "populates the MAC address" do
      mac_address = 'mac_address'
      expect(service).to receive(:resource_post).once.with(
        @resource_url, expected_data("<mac address=\"#{mac_address}\"/>"))
      vm.create_nic(@base_options.merge(:mac_address => mac_address))
    end
  end

  context "#memory_reserve" do
    it "updates the memory policy guarantee" do
      memory_reserve = 1.gigabyte
      expected_data  = <<-EOX.chomp
<vm>
  <memory_policy>
    <guaranteed>#{memory_reserve}</guaranteed>
  </memory_policy>
</vm>
EOX

      return_data = <<-EOX.chomp
<vm>
  <os type='dummy'/>
  <placement_policy>
    <affinity>dummy</affinity>
  </placement_policy>
</vm>
EOX

      expect(service).to receive(:resource_put).once.with(
        vm.attributes[:href],
        expected_data).and_return(return_data)
      vm.memory_reserve = memory_reserve
    end
  end

  context "#stop" do
    it "should raise Ovirt::VmIsNotRunning if the VM is not running" do
      return_data = <<-EOX.chomp
<action>
    <fault>
        <detail>[Cannot stop VM. VM is not running.]</detail>
    </fault>
</action>
EOX

      rest_client = double('rest_client').as_null_object
      expect(rest_client).to receive(:post) do |&block|
        allow(return_data).to receive(:code).and_return(409)
        block.call(return_data)
      end

      allow(service).to receive(:create_resource).and_return(rest_client)
      expect { vm.stop }.to raise_error Ovirt::VmIsNotRunning
    end
  end

  context "payloads" do
    skip "attach" do
    end

    context "detach floppy" do
      it "Ovirt 3.0 should set empty payload" do
        expected_data = <<-EOX.chomp
<vm>
  <payloads>
    <payload type="floppy"/>
  </payloads>
</vm>
EOX
        return_data = <<-EOX.chomp
<vm href="/api/vms/128f9ffd-b82c-41e4-8c00-9742ed173bac" id="128f9ffd-b82c-41e4-8c00-9742ed173bac">
  <name>bd-skeletal-clone-from-template</name>
  <cpu>
    <topology sockets="1" cores="1"/>
  </cpu>
  <os type="rhel_6x64">
    <boot dev="hd"/>
  </os>
  <payloads>
    <payload type="floppy"/>
  </payloads>
  <placement_policy>
    <host id="a3abe9ed-fa52-4a7f-8a9b-1eebc782781f"/>
    <affinity>migratable</affinity>
  </placement_policy>
  <memory_policy>
    <guaranteed>1073741824</guaranteed>
    <ballooning>true</ballooning>
  </memory_policy>
</vm>
EOX
        expect(service).to receive(:version).twice.and_return(:major => "3", :minor => "0", :build => "0", :revision => "0")
        expect(service).to receive(:resource_put).once.with(vm.attributes[:href], expected_data).and_return(return_data)
        vm.detach_floppy
      end

      it "Ovirt 3.3 should remove payload" do
        expected_data = <<-EOX.chomp
<vm>
  <payloads/>
</vm>
EOX
        return_data = <<-EOX.chomp
<vm href="/api/vms/128f9ffd-b82c-41e4-8c00-9742ed173bac" id="128f9ffd-b82c-41e4-8c00-9742ed173bac">
  <name>bd-skeletal-clone-from-template</name>
  <cpu>
    <topology sockets="1" cores="1"/>
  </cpu>
  <os type="rhel_6x64">
    <boot dev="hd"/>
  </os>
  <placement_policy>
    <host id="a3abe9ed-fa52-4a7f-8a9b-1eebc782781f"/>
    <affinity>migratable</affinity>
  </placement_policy>
  <memory_policy>
    <guaranteed>1073741824</guaranteed>
    <ballooning>true</ballooning>
  </memory_policy>
</vm>
EOX
        expect(service).to receive(:version).and_return(:major => "3", :minor => "3", :build => "0", :revision => "0")
        expect(service).to receive(:resource_put).once.with(vm.attributes[:href], expected_data).and_return(return_data)
        vm.detach_floppy
      end
    end
  end

  it "cloud_init= Ovirt 3.4 and newer" do
    cloud_config = <<-EOCC.chomp
#cloud_config
regenerate_ssh_keys: false
root_password: some_password
fqdn: example.example.com
debug: True
EOCC

    expected_data = <<-EOX.chomp
<vm>
  <initialization>
    <regenerate_ssh_keys>false</regenerate_ssh_keys>
    <root_password>some_password</root_password>
    <custom_script>fqdn: example.example.com\ndebug: true\n</custom_script>
  </initialization>
</vm>
EOX

    return_data = <<-EOX.chomp
<vm href="/api/vms/128f9ffd-b82c-41e4-8c00-9742ed173bac" id="128f9ffd-b82c-41e4-8c00-9742ed173bac">
  <name>bd-skeletal-clone-from-template</name>
  <cpu>
    <topology sockets="1" cores="1"/>
  </cpu>
  <os type="rhel_6x64">
    <boot dev="hd"/>
  </os>
  <placement_policy>
    <host id="a3abe9ed-fa52-4a7f-8a9b-1eebc782781f"/>
    <affinity>migratable</affinity>
  </placement_policy>
  <memory_policy>
    <guaranteed>1073741824</guaranteed>
    <ballooning>true</ballooning>
  </memory_policy>
</vm>
EOX

    expect(service).to receive(:api).and_return(:product_info => {:version => {:major => "3", :minor => "4", :revision => "0", :build => "0"}})
    expect(service).to receive(:resource_put).once.with(vm.attributes[:href], expected_data).and_return(return_data)
    vm.cloud_init = cloud_config
  end
end
