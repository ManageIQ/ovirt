# Abstract RHEVM Error Class
class OvirtError < StandardError; end

# Existence
class OvirtTemplateAlreadyExists < OvirtError; end
class OvirtVmAlreadyExists       < OvirtError; end

# Power State
class OvirtVmAlreadyRunning < OvirtError; end
class OvirtVmIsNotRunning   < OvirtError; end
class OvirtVmNotReadyToBoot < OvirtError; end