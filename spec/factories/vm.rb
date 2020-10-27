FactoryBot.define do
  factory :vm, :class => "Ovirt::Vm" do
    initialize_with { new(service, {}) }
    service { build(:service) }
  end

  factory :vm_full, :parent => :vm do
    initialize_with do
      new(service,
          :actions           => {:stop => '/api/vms/128f9ffd-b82c-41e4-8c00-9742ed173bac/stop'},
          :id                => "128f9ffd-b82c-41e4-8c00-9742ed173bac",
          :href              => "/api/vms/128f9ffd-b82c-41e4-8c00-9742ed173bac",
          :cluster           => {
            :id   => "5be5d08a-a60b-11e2-bee6-005056a217db",
            :href => "/api/clusters/5be5d08a-a60b-11e2-bee6-005056a217db"},
          :template          => {
            :id   => "00000000-0000-0000-0000-000000000000",
            :href => "/api/templates/00000000-0000-0000-0000-000000000000"},
          :name              => "bd-skeletal-clone-from-template",
          :origin            => "rhev",
          :type              => "server",
          :memory            => 536_870_912,
          :stateless         => false,
          :creation_time     => "2013-09-04 16:24:20 -0400",
          :status            => {:state => "down"},
          :display           => {:type => "spice", :monitors => 1},
          :usb               => {:enabled => false},
          :cpu               => {:sockets => 1, :cores => 1},
          :high_availability => {:priority => 1, :enabled => false},
          :os                => {:type => "unassigned", :boot_order => [{:dev => "hd"}]},
          :custom_attributes => [],
          :placement_policy  => {:affinity => "migratable", :host => {}},
          :memory_policy     => {:guaranteed => 536_870_912},
          :guest_info        => {}
         )
    end
  end
end
