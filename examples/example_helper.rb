$:.push(File.expand_path(File.join(File.dirname(__FILE__), "../lib")))
require 'ovirt'
require 'pp'

module ExampleHelper
  SERVER   = raise "please define SERVER"
  PORT     = 443
  DOMAIN   = raise "please define DOMAIN"
  USERNAME = raise "please define USERNAME"
  PASSWORD = raise "please define PASSWORD"

  def self.service_attributes
    {
      :server     => SERVER,
      :port       => PORT,
      :domain     => DOMAIN,
      :username   => USERNAME,
      :password   => PASSWORD,
      :verify_ssl => false
    }
  end

  def self.service
    Ovirt::Service.new(service_attributes)
  end
end
