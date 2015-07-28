describe Ovirt::Template do
  let(:service)  { template.service }
  let(:template) { build(:template_full) }

  context "#create_vm" do
    it "clones properties for skeletal clones" do
      options = {:clone_type => :skeletal}
      expected_data = {
        :clone_type        => :linked,
        :memory            => 536_870_912,
        :stateless         => false,
        :type              => "server",
        :display           => {:type => "spice", :monitors => 1},
        :usb               => {:enabled => false},
        :cpu               => {:topology => {:sockets => 1, :cores => 1}},
        :high_availability => {:priority => 1, :enabled => false},
        :os_type           => "rhel5_64"}
      allow(template).to receive(:nics).and_return([])
      allow(template).to receive(:disks).and_return([])
      allow(service).to receive(:blank_template).and_return(double('blank template'))
      expect(service.blank_template).to receive(:create_vm).once.with(expected_data)
      template.create_vm(options)
    end

    it "overrides properties for linked clones" do
      expected_data = <<-EOX.chomp
<vm>
  <name>new name</name>
  <cluster id=\"fb27f9a0-cb75-4e0f-8c07-8dec0c5ab483\"/>
  <template id=\"128f9ffd-b82c-41e4-8c00-9742ed173bac\"/>
  <memory>536870912</memory>
  <stateless>false</stateless>
  <type>server</type>
  <display>
    <type>spice</type>
    <monitors>1</monitors>
  </display>
  <usb>
    <enabled>false</enabled>
  </usb>
  <cpu>
    <topology sockets="1" cores="1"/>
  </cpu>
  <high_availability>
    <priority>1</priority>
    <enabled>false</enabled>
  </high_availability>
  <os type=\"test\">
    <boot dev=\"hd\"/>
  </os>
</vm>
EOX
      response_xml = <<-EOX.chomp
<vm>
  <os type='foo'/>
  <placement_policy><affinity>foo</affinity></placement_policy>
</vm>
EOX
      options = {
        :clone_type => :linked,
        :name       => 'new name',
        :cluster    => 'fb27f9a0-cb75-4e0f-8c07-8dec0c5ab483',
        :os_type    => 'test'}
      expect(service).to receive(:resource_post).once.with(:vms, expected_data).and_return(response_xml)
      template.create_vm(options)
    end

    context "#create_new_disks_from_template" do
      before do
        @disk = Ovirt::Disk.new(service, :id              => "01eae62b-90df-424d-978c-beaa7eb2f7f6",
                                         :href            => "/api/templates/54f1b9f4-0e89-4c72-9a26-f94dcb857264/disks/01eae62b-90df-424d-978c-beaa7eb2f7f6",
                                         :name            => "clone_Disk1",
                                         :storage_domains => [{:id => "aa7e70e5-40d0-43e2-a605-92ce6ba652a8"}])
        allow(template).to receive(:disks).and_return([@disk])

        @vm = double('rhevm_vm')
      end

      it "without a storage override" do
        expected_data = @disk.attributes.dup
        expected_data[:storage] = expected_data[:storage_domains].first[:id]

        expect(@vm).to receive(:create_disk).once.with(expected_data)
        template.send(:create_new_disks_from_template, @vm, {})
      end

      it "with a storage override" do
        expected_data = @disk.attributes.dup
        options = {:storage => "xxxxxxxx-40d0-43e2-a605-92ce6ba652a8"}
        expected_data.merge!(options)

        expect(@vm).to receive(:create_disk).once.with(expected_data)
        template.send(:create_new_disks_from_template, @vm, options)
      end
    end

    context "build_clone_xml" do
      it "Properly sets vm/cpu/topology attributes" do
        allow(Ovirt::Base).to receive(:object_to_id)
        xml     = template.send(:build_clone_xml, :name => "Blank", :cluster => "6b8f1c1e-3eb0-11e4-8420-56847afe9799")
        nodeset = Nokogiri::XML.parse(xml).xpath("//vm/cpu/topology")
        node    = nodeset.first

        expect(nodeset.length).to       eq(1)
        expect(node["cores"].to_i).to   eq(1)
        expect(node["sockets"].to_i).to eq(1)
      end
    end
  end
end
