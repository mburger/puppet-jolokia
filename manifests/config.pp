# Class: jolokia::config
#
# This class manages jolokia configuration
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
class jolokia::config {

  # The whole jolokia configuration directory can be recursively overriden
  file { 'jolokia.dir':
    ensure  => directory,
    path    => $jolokia::config_dir,
    notify  => $jolokia::manage_service_autorestart,
    source  => $jolokia::source_dir,
    recurse => true,
    purge   => $jolokia::bool_source_dir_purge,
    force   => $jolokia::bool_source_dir_purge,
    replace => $jolokia::manage_file_replace,
    audit   => $jolokia::manage_audit,
    noop    => $jolokia::noops,
    mode    => '0755',
  }
}
