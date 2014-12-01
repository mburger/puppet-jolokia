# Class: jolokia::params
#
# This class defines default parameters used by the main module class jolokia
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to jolokia class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class jolokia::params {

  ### Application related parameters

  $package = $::operatingsystem ? {
    default => 'jolokia',
  }

  $config_dir = $::operatingsystem ? {
    default => '/etc/jolokia',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  # General Settings
  $my_class = ''
  $dependency_class = ''
  $source_dir = undef
  $source_dir_purge = false
  $options = {}
  $version = 'present'
  $absent = false
  $jvm_agents = {}

  ### General module variables that can have a site or per module default
  $puppi = false
  $puppi_helper = 'standard'
  $debug = false
  $audit_only = false
  $noops = undef

}
