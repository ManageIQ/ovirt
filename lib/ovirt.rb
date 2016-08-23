require 'more_core_extensions/all'

require 'ovirt/exception'
require 'ovirt/logging'
require 'ovirt/null_logger'
require 'ovirt/base'
require 'ovirt/version'

require 'ovirt/api'
require 'ovirt/cdrom'
require 'ovirt/cluster'
require 'ovirt/data_center'
require 'ovirt/disk'
require 'ovirt/domain'
require 'ovirt/event'
require 'ovirt/file'
require 'ovirt/group'
require 'ovirt/host'
require 'ovirt/host_nic'
require 'ovirt/network'
require 'ovirt/nic'
require 'ovirt/permission'
require 'ovirt/permit'
require 'ovirt/role'
require 'ovirt/service'
require 'ovirt/snapshot'
require 'ovirt/statistic'
require 'ovirt/storage'
require 'ovirt/storage_domain'
require 'ovirt/tag'
require 'ovirt/template'
require 'ovirt/user'
require 'ovirt/vm'
require 'ovirt/vmpool'

module Ovirt
  class << self
    attr_writer :logger
  end

  def self.logger
    @logger ||= NullLogger.new
  end
end
