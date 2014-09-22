require 'spec_helper'

describe Ovirt::Object do
  it ".api_endpoint" do
    Ovirt::Object.api_endpoint.should        == "objects"
    Ovirt::Template.api_endpoint.should      == "templates"
    Ovirt::Cluster.api_endpoint.should       == "clusters"
    Ovirt::Vm.api_endpoint.should            == "vms"
    Ovirt::StorageDomain.api_endpoint.should == "storagedomains"
    Ovirt::DataCenter.api_endpoint.should    == "datacenters"
  end
end
