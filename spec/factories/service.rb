FactoryGirl.define do
  factory :service, :class => "Ovirt::Service" do
    initialize_with { new(:server => "", :username => "", :password => "") }
  end
end
