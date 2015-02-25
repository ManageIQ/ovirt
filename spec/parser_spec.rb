require 'spec_helper'
require 'yaml'

describe Ovirt::Parser do
  it "#definition" do
    definition = {"string" => "string"}
    parser = described_class.new(definition)
    expect(parser.definition).to eq(definition)
  end

  it "#parse" do
    definition = YAML.load_file(File.join(__dir__, "data/sample_definition.yml"))
    xml = File.open(File.join(__dir__, "data/sample.xml")) { |f| Nokogiri::XML(f).root }

    parser = described_class.new(definition)
    expect(parser.parse(xml)).to eq(
      :id            => "1",
      :href          => "/api/1",
      :actions       => {:action => "/api/1/action"},
      :relationships => {:relationship => "/api/1/relationship"},
      :string        => "string",
      :integer       => 1,
      :bool_true     => true,
      :bool_false    => false,
      :attrs         => {
        :attr_string     => "string",
        :attr_integer    => 1,
        :attr_bool_true  => true,
        :attr_bool_false => false
      },
      :nodes => {
        :string     => "string",
        :integer    => 1,
        :bool_true  => true,
        :bool_false => false,
        :attrs      => {
          :attr_string     => "string",
          :attr_integer    => 1,
          :attr_bool_true  => true,
          :attr_bool_false => false
        },
      },
      :node_with_attrs   => {:attr_integer => 1, :string => "string"},
      :attrs_with_value  => {:attr_integer => 1, :value => "string"},
      :node_with_nesting => {:subnode => {:string => "string"}},
      :object            => {:id => "2", :href => "/api/2"},
      :version           => {
        :major        => "1",
        :minor        => "2",
        :build        => "3",
        :revision     => "4",
        :full_version => "1.2.3.4-alpha1"
      }
    )
  end
end
