require 'spec_helper'
require 'rest-client'

describe Ovirt::Service do
  before do
    @service = described_class.new(:server => "", :username => "", :password => "")
  end

  context "#resource_post" do
    it "raises OvirtError if HTTP 409 response code received" do
      error_detail = "API error"
      return_data = <<-EOX.chomp
<action>
    <fault>
        <detail>#{error_detail}</detail>
    </fault>
</action>
EOX

      rest_client = double('rest_client').as_null_object
      rest_client.should_receive(:post) do |&block|
        return_data.stub(:code).and_return(409)
        block.call(return_data)
      end

      @service.stub(:create_resource).and_return(rest_client)
      expect { @service.resource_post('uri', 'data') }.to raise_error(OvirtError, error_detail)
    end
  end
end
