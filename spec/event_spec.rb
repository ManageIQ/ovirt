describe Ovirt::Event do
  context ".set_event_name" do
    it "sets the name corresponding to a valid code" do
      hash = {:code => 1}
      described_class.send(:set_event_name, hash)
      expect(hash[:name]).to eq(Ovirt::Event::EVENT_CODES[1])
    end

    it "sets 'UNKNOWN' as the name with an invalid code" do
      expect(Ovirt.logger).to receive(:warn).with("Ovirt::Event.set_event_name Unknown RHEVM event -1: Invalid Code")
      hash = {:code => -1, :description => "Invalid Code"}
      described_class.send(:set_event_name, hash)
      expect(hash[:name]).to eq("UNKNOWN")
    end
  end
end
