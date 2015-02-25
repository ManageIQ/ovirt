require 'spec_helper'

describe Ovirt::Host do
  context ".parse_xml" do
    it "with latest version" do
      xml = File.read(File.join(__dir__, "data/host_rhev_3_4.xml"))
      expect(described_class.parse_xml(xml)).to eq(
        :id      => "49530bd6-31eb-44ab-9e70-6d6c26b0a69a",
        :href    => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a",
        :actions => {
          :approve         => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/approve",
          :forceselectspm  => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/forceselectspm",
          :iscsilogin      => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/iscsilogin",
          :iscsidiscover   => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/iscsidiscover",
          :commitnetconfig => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/commitnetconfig",
          :deactivate      => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/deactivate",
          :fence           => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/fence",
          :install         => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/install",
          :activate        => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/activate"
        },
        :relationships => {
          :storage     => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/storage",
          :tags        => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/tags",
          :permissions => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/permissions",
          :statistics  => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/statistics",
          :hooks       => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/hooks",
          :host_nics   => "/api/hosts/49530bd6-31eb-44ab-9e70-6d6c26b0a69a/nics"
        },
        :name        => "rhev_3_4_host",
        :address     => "1.2.3.4",
        :certificate => {
          :organization => "example.com",
          :subject      => "O=example.com,CN=1.2.3.4"
        },
        :status  => {:state => "up"},
        :cluster => {
          :id   => "dfd22951-68b1-4c68-a8ce-2d067a6ba6cf",
          :href => "/api/clusters/dfd22951-68b1-4c68-a8ce-2d067a6ba6cf"
        },
        :port            => 54321,
        :type            => "rhel",
        :storage_manager => false,
        :version         => {
          :major        => "4",
          :minor        => "14",
          :build        => "17",
          :revision     => "0",
          :full_version => "vdsm-4.14.17-2.el6ev"
        },
        :hardware_information => {
          :manufacturer  => "IBM",
          :version       => "0A",
          :serial_number => "KQ0Z1CD",
          :product_name  => "IBM System X3250 M4 -[2583AC1]-",
          :uuid          => "6D19C9AE-E70E-3A24-B9C0-EACF17F43E3A",
          :family        => "System X"
        },
        :power_management      => {:type => "apc", :enabled => false, :automatic_pm_enabled => true},
        :ksm                   => {:enabled => false},
        :transparent_hugepages => {:enabled => true},
        :iscsi                 => {:initiator => "iqn.1994-05.com.example:3b0dbcd97818"},
        :ssh                   => {:port => 22, :fingerprint => "c0:14:ea:4b:3d:bf:6a:d7:56:ac:5c:81:ba:6b:08:bc"},
        :cpu                   => {
          :name     => "Intel(R) Xeon(R) CPU E3-1220 V2 @ 3.10GHz",
          :speed    => 3100,
          :topology => {:sockets => 1, :cores => 4, :threads => 1}
        },
        :memory                => 33658241024,
        :max_scheduling_memory => 30678188032,
        :summary               => {:active => 9, :migrating => 0, :total => 9},
        :os                    => {:type => "RHEL", :version => {:full_version => "6Server - 6.5.0.1.el6"}},
        :libvirt_version       => {
          :major        => "0",
          :minor        => "10",
          :build        => "2",
          :revision     => "0",
          :full_version => "libvirt-0.10.2-46.el6_6.1"
        }
      )
    end

    it "with older version" do
      xml = File.read(File.join(__dir__, "data/host_rhev_3_1.xml"))
      expect(described_class.parse_xml(xml)).to eq(
        :id      => "bf7683bf-57d7-495d-b17a-91d0bf1daa0d",
        :href    => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d",
        :actions => {
          :deactivate      => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/deactivate",
          :fence           => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/fence",
          :install         => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/install",
          :activate        => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/activate",
          :iscsidiscover   => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/iscsidiscover",
          :commitnetconfig => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/commitnetconfig",
          :approve         => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/approve",
          :iscsilogin      => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/iscsilogin"
        },
        :relationships => {
          :storage     => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/storage",
          :tags        => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/tags",
          :permissions => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/permissions",
          :statistics  => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/statistics",
          :host_nics   => "/api/hosts/bf7683bf-57d7-495d-b17a-91d0bf1daa0d/nics"
        },
        :name        => "rhev_3_1_host",
        :address     => "1.2.3.4",
        :certificate => {
          :organization => "example.com",
          :subject      => "O=example.com,CN=1.2.3.4"
        },
        :status  => {:state => "non_responsive"},
        :cluster => {
          :id   => "12dd4eab-6050-496e-a5a3-b93e92346797",
          :href => "/api/clusters/12dd4eab-6050-496e-a5a3-b93e92346797"
        },
        :port                  => 54321,
        :type                  => "rhel",
        :storage_manager       => true,
        :power_management      => {:enabled => false},
        :ksm                   => {:enabled => false},
        :transparent_hugepages => {:enabled => true},
        :iscsi                 => {:initiator => "iqn.1994-05.com.example:6a7a1474bebf"},
        :cpu                   => {
          :name     => "Intel(R) Xeon(R) CPU E5504 @ 2.00GHz",
          :speed    => 1995,
          :topology => {:sockets => 2, :cores => 4}
        },
        :memory                => 59069431808,
        :max_scheduling_memory => 85995814912,
        :summary               => {:active => 2, :migrating => 0, :total => 2}
      )
    end
  end
end
