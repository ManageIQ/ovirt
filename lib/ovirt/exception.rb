module Ovirt
  # Abstract RHEVM Error Class
  class Error < StandardError; end

  # Existence
  class MissingResourceError < Error; end
  class TemplateAlreadyExists < Error; end
  class VmAlreadyExists < Error; end

  # Power State
  class VmAlreadyRunning < Error; end
  class VmIsNotRunning < Error; end
  class VmNotReadyToBoot < Error; end

  class UsageError < Error; end
  class CloudInitSyntaxError < UsageError; end
end
