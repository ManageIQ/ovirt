require 'spec_helper'

describe Ovirt::Event do
  context ".set_event_name" do
    before :each do
      @orig_log, $rhevm_log = $rhevm_log, double("logger")
    end

    after :each do
      $rhevm_log = @orig_log
    end

    it "sets the name corresponding to a valid code" do
      hash = {:code => 1}
      described_class.send(:set_event_name, hash)
      expect(hash[:name]).to eq Ovirt::Event::EVENT_CODES[1]
    end

    it "sets 'UNKNOWN' as the name with an invalid code" do
      expect($rhevm_log).to receive :warn
      hash = {:code => -1, :description => "Invalid Code"}
      described_class.send(:set_event_name, hash)
      expect(hash[:name]).to eq "UNKNOWN"
    end
  end
end
