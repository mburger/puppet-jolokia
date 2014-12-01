# = Class: jolokia
#
# This is the main jolokia class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, jolokia class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $jolokia_myclass
#
# [*dependency_class*]
#   Name of the class that provides third module dependencies
#
# [*source_dir*]
#   If defined, the whole jolokia configuration directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#   Can be defined also by the (top scope) variable $jolokia_source_dir
#
# [*source_dir_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#   Can be defined also by the (top scope) variable $jolokia_source_dir_purge
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $jolokia_options
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $jolokia_absent
#
# [*puppi*]
#   Set to 'true' to enable creation of module data files that are used by puppi
#   Can be defined also by the (top scope) variables $jolokia_puppi and $puppi
#
# [*puppi_helper*]
#   Specify the helper to use for puppi commands. The default for this module
#   is specified in params.pp and is generally a good choice.
#   You can customize the output of puppi commands for this module using another
#   puppi helper. Use the define puppi::helper to create a new custom helper
#   Can be defined also by the (top scope) variables $jolokia_puppi_helper
#   and $puppi_helper
#
# [*debug*]
#   Set to 'true' to enable modules debugging
#   Can be defined also by the (top scope) variables $jolokia_debug and $debug
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $jolokia_audit_only
#   and $audit_only
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: undef
#
# Default class params - As defined in jolokia::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*package*]
#   The name of jolokia package
#
# [*config_dir*]
#   Main configuration directory. Used by puppi
#
# [*config_file_mode*]
#   Main configuration file path mode
#
# [*config_file_owner*]
#   Main configuration file path owner
#
# [*config_file_group*]
#   Main configuration file path group
#
#
# See README for usage patterns.
#
class jolokia (
  $my_class                   = params_lookup( 'my_class' ),
  $dependency_class           = params_lookup( 'dependency_class' ),
  $source_dir                 = params_lookup( 'source_dir' ),
  $source_dir_purge           = params_lookup( 'source_dir_purge' ),
  $options                    = params_lookup( 'options' ),
  $version                    = params_lookup( 'version' ),
  $absent                     = params_lookup( 'absent' ),
  $puppi                      = params_lookup( 'puppi' , 'global' ),
  $puppi_helper               = params_lookup( 'puppi_helper' , 'global' ),
  $debug                      = params_lookup( 'debug' , 'global' ),
  $audit_only                 = params_lookup( 'audit_only' , 'global' ),
  $noops                      = params_lookup( 'noops' ),
  $package                    = params_lookup( 'package' ),
  $config_dir                 = params_lookup( 'config_dir' ),
  $config_file_mode           = params_lookup( 'config_file_mode' ),
  $config_file_owner          = params_lookup( 'config_file_owner' ),
  $config_file_group          = params_lookup( 'config_file_group' ),
  $jvm_agents                 = params_lookup( 'jvm_agents' )
  ) inherits jolokia::params {

  $bool_source_dir_purge=any2bool($source_dir_purge)
  $bool_absent=any2bool($absent)
  $bool_puppi=any2bool($puppi)
  $bool_debug=any2bool($debug)
  $bool_audit_only=any2bool($audit_only)

  ### Definition of some variables used in the module
  $manage_package = $jolokia::bool_absent ? {
    true  => 'absent',
    false => $jolokia::version,
  }

  $manage_file = $jolokia::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $jolokia::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $jolokia::bool_audit_only ? {
    true  => false,
    false => true,
  }

  ### Include custom class if $my_class is set
  if $jolokia::my_class {
    include $jolokia::my_class
  }

  ### Include dependencies provided by other modules
  if $jolokia::dependency_class {
    require $jolokia::dependency_class
  }

  ### Managed resources
  case $jolokia::bool_absent {
    true: {
      class { 'jolokia::config': } ->
      class { 'jolokia::install': } ->
      Class['jolokia']
    }
    false:{
      class { 'jolokia::install': } ->
      class { 'jolokia::config': } ->
      Class['jolokia']
    }
  }

  ### Create instances for integration with Hiera
  if $jvm_agents != {} {
    validate_hash($jvm_agents)
    create_resources(jolokia::jvm_agent, $jvm_agents)
  }

  ### Provide puppi data, if enabled ( puppi => true )
  if $jolokia::bool_puppi == true {
    $classvars=get_class_args()
    puppi::ze { 'jolokia':
      ensure    => $jolokia::manage_file,
      variables => $classvars,
      helper    => $jolokia::puppi_helper,
      noop      => $jolokia::noops,
    }
  }


  ### Debugging, if enabled ( debug => true )
  if $jolokia::bool_debug == true {
    file { 'debug_jolokia':
      ensure  => $jolokia::manage_file,
      path    => "${settings::vardir}/debug-jolokia",
      mode    => '0640',
      owner   => 'root',
      group   => 'root',
      content => inline_template('<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime.*|path|timestamp|free|.*password.*|.*psk.*|.*key)/ }.to_yaml %>'),
      noop    => $jolokia::noops,
    }
  }

}
