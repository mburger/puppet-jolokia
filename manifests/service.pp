# Class: jolokia::service
#
# This class manages jolokia service
#
# == Variables
#
# Refer to jolokia class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It's automatically included by jolokia
#
class jolokia::service {

  service { 'jolokia':
    ensure     => $jolokia::manage_service_ensure,
    name       => $jolokia::service,
    enable     => $jolokia::manage_service_enable,
    hasstatus  => $jolokia::service_status,
    pattern    => $jolokia::process,
    noop       => $jolokia::noops,
  }
}
