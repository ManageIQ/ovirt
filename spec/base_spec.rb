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
end
