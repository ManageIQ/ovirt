require 'spec_helper'
require 'rest-client'

describe Ovirt::Service do
  before do
    @service = described_class.new(:server => "", :username => "", :password => "")
  end

  context "#resource_post" do
    it "raises Ovirt::Error if HTTP 409 response code received" do
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
      expect { @service.resource_post('uri', 'data') }.to raise_error(Ovirt::Error, error_detail)
    end
  end

  context "#base_uri" do
    let(:defaults) { {:username => nil, :password => nil}}
    subject { described_class.new(defaults.merge(@options)).send(:base_uri) }

    it "ipv4" do
      @options = {:server => "127.0.0.1"}
      subject.should == "https://127.0.0.1:443"
    end

    it "ipv6" do
      @options = {:server => "::1"}
      subject.should == "https://[::1]:443"
    end

    it "hostname" do
      @options = {:server => "nobody.com"}
      subject.should == "https://nobody.com:443"
    end

    it "port 4443" do
      @options = {:server => "nobody.com", :port => 4443}
      subject.should == "https://nobody.com:4443"
    end

    it "blank port" do
      @options = {:server => "nobody.com", :port => ""}
      subject.should == "https://nobody.com"
    end

    it "nil port uses defaults" do
      @options = {:server => "nobody.com", :port => nil}
      subject.should == "https://nobody.com:443"
    end
  end
end
