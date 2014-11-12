require 'spec_helper'

describe Ovirt::Base do
  it ".api_endpoint" do
    Ovirt::Base.api_endpoint.should          == "bases"
    Ovirt::Template.api_endpoint.should      == "templates"
    Ovirt::Cluster.api_endpoint.should       == "clusters"
    Ovirt::Vm.api_endpoint.should            == "vms"
    Ovirt::StorageDomain.api_endpoint.should == "storagedomains"
    Ovirt::DataCenter.api_endpoint.should    == "datacenters"
  end

  it ".href_to_guid" do
    guid = "1c92b67c-9d10-4f48-85bd-28ba2fd6d9b3"
    expect(Ovirt::Base.send(:href_to_guid, "/api/clusters/#{guid}")).to eq(guid)
    expect(Ovirt::Base.send(:href_to_guid, guid)).to                    eq(guid)
    expect { Ovirt::Base.send(:href_to_guid, 12345) }.to                raise_error(ArgumentError)
  end
end
