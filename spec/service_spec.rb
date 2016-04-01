require 'rest-client'

describe Ovirt::Service do
  let(:service) { build(:service) }

  context "#resource_post" do
    it "raises Ovirt::Error if HTTP 409 response code received" do
      error_detail = "API error"
      return_data  = <<-EOX.chomp
<action>
    <fault>
        <detail>#{error_detail}</detail>
    </fault>
</action>
EOX

      rest_client = double('rest_client').as_null_object
      expect(rest_client).to receive(:post) do |&block|
        allow(return_data).to receive(:code).and_return(409)
        block.call(return_data)
      end

      allow(service).to receive(:create_resource).and_return(rest_client)
      expect { service.resource_post('uri', 'data') }.to raise_error(Ovirt::Error, error_detail)
    end

    it "raises Ovirt::Error if HTTP 409 response code received" do
      error_detail = "Usage message"
      return_data  = <<-EOX.chomp
<usage_message>
  <message>#{error_detail}</message>
</usage_message>
EOX

      rest_client = double('rest_client').as_null_object
      expect(rest_client).to receive(:post) do |&block|
        allow(return_data).to receive(:code).and_return(409)
        block.call(return_data)
      end

      allow(service).to receive(:create_resource).and_return(rest_client)
      expect { service.resource_post('uri', 'data') }.to raise_error(Ovirt::UsageError, error_detail)
    end
  end

  describe "#ca_certificate" do
    subject { service.ca_certificate }

    it 'calls the rest client to download the certificate' do
      cert = "-----BEGIN CERTIFICATE-----"
      klass = stub_const("RestClient::Resource", double)
      instance = double
      expect(service).to receive(:base_uri)
      expect(klass).to receive(:new).and_return(instance)
      expect(instance).to receive(:get).and_return(cert)
      expect(subject).to eq(cert)
    end
  end

  it "#resource_get on exception" do
    allow(service).to receive(:create_resource).and_raise(Exception, "BLAH")
    expect { service.resource_get('api') }.to raise_error(Exception, "BLAH")
  end

  context ".ovirt?" do
    it "false when ResourceNotFound" do
      expect_any_instance_of(described_class).to receive(:engine_ssh_public_key).and_raise(RestClient::ResourceNotFound)
      expect(described_class.ovirt?(:server => "127.0.0.1")).to be false
    end

    it "false when invalid content encoding returned" do
      expect_any_instance_of(described_class).to receive(:engine_ssh_public_key).and_raise(NoMethodError)
      expect(described_class.ovirt?(:server => "127.0.0.1")).to be false
    end

    it "true when key non-empty" do
      fake_key = "ssh-rsa " + ("A" * 372) + " ovirt-engine\n"
      expect_any_instance_of(described_class).to receive(:engine_ssh_public_key).and_return(fake_key)
      expect(described_class.ovirt?(:server => "127.0.0.1")).to be true
    end

    it "false when key empty" do
      fake_key = "\n"
      expect_any_instance_of(described_class).to receive(:engine_ssh_public_key).and_return(fake_key)
      expect(described_class.ovirt?(:server => "127.0.0.1")).to be false
    end
  end

  context "#base_uri" do
    let(:defaults) { {:username => nil, :password => nil} }
    subject { described_class.new(defaults.merge(@options)).send(:base_uri) }

    it "ipv4" do
      @options = {:server => "127.0.0.1"}
      expect(subject).to eq("https://127.0.0.1:443")
    end

    it "ipv6" do
      @options = {:server => "::1"}
      expect(subject).to eq("https://[::1]:443")
    end

    it "hostname" do
      @options = {:server => "nobody.com"}
      expect(subject).to eq("https://nobody.com:443")
    end

    it "port 4443" do
      @options = {:server => "nobody.com", :port => 4443}
      expect(subject).to eq("https://nobody.com:4443")
    end

    it "blank port" do
      @options = {:server => "nobody.com", :port => ""}
      expect(subject).to eq("https://nobody.com")
    end

    it "nil port uses defaults" do
      @options = {:server => "nobody.com", :port => nil}
      expect(subject).to eq("https://nobody.com:443")
    end
  end

  context "#version" do
    it "with :full_version" do
      allow(service).to receive(:product_info).and_return(:full_version => "3.4.5-0.3.el6ev", :version => {:major => "3", :minor => "4", :build => "0", :revision => "0"})
      expect(service.version).to eq(:major => "3", :minor => "4", :revision => "5", :build => "0")
    end

    it "without :full_version" do
      allow(service).to receive(:product_info).and_return(:version => {:major => "3", :minor => "4", :build => "0", :revision => "0"})
      expect(service.version).to eq(:major => "3", :minor => "4", :revision => "0", :build => "0")
    end
  end
end
