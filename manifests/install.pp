# Class: jolokia::install
#
# This class installs jolokia
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
class jolokia::install {

  package { $jolokia::package:
    ensure  => $jolokia::manage_package,
    noop    => $jolokia::noops,
  }
}
