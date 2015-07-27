describe Ovirt::Base do
  it ".api_endpoint" do
    expect(Ovirt::Base.api_endpoint).to          eq("bases")
    expect(Ovirt::Template.api_endpoint).to      eq("templates")
    expect(Ovirt::Cluster.api_endpoint).to       eq("clusters")
    expect(Ovirt::Vm.api_endpoint).to            eq("vms")
    expect(Ovirt::StorageDomain.api_endpoint).to eq("storagedomains")
    expect(Ovirt::DataCenter.api_endpoint).to    eq("datacenters")
  end

  it ".href_to_guid" do
    guid = "1c92b67c-9d10-4f48-85bd-28ba2fd6d9b3"
    expect(Ovirt::Base.send(:href_to_guid, "/api/clusters/#{guid}")).to eq(guid)
    expect(Ovirt::Base.send(:href_to_guid, guid)).to                    eq(guid)
    expect { Ovirt::Base.send(:href_to_guid, 12345) }.to                raise_error(ArgumentError)
  end
end
