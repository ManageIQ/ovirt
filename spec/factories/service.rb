FactoryGirl.define do
  factory :service, :class => "Ovirt::Service" do
    server ""
    initialize_with { new(:server => server, :username => "", :password => "") }
  end
end
