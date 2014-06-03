define jolokia::jvm_agent (
  $port,
  $agent_context        = '/jolokiaagent',
  $host                 = 'localhost',
  $user                 = undef,
  $password             = undef,
  $protocol             = 'http',
  $backlog              = undef,
  $executor             = 'single',
  $thread_nr            = undef,
  $keystore             = undef,
  $keystore_password    = undef,
  $use_ssl_client_auth  = false,
  $boot_amx             = false,
  $discovery_enabled    = false,
  $discovery_agent_url  = undef,
  $include_stacktrace   = false,
  $policy_location      = '/jumio/data/jolokia/jumio-policy.xml',
) {

  require jolokia

  validate_re($protocol, '^http(s)?$', 'the protocol has to bo one of http or https')
  validate_re($executor, '^(single|cached|fixed)$', 'the executer has to be one of single, cached or fixed')
  validate_bool($use_ssl_client_auth)
  validate_bool($boot_amx)
  validate_bool($discovery_enabled)
  validate_bool($include_stacktrace)

  file { "jolokia.jvm_agent.${name}":
    ensure  => file,
    path    => "${jolokia::config_dir}/${name}.properties",
    mode    => $jolokia::config_file_mode,
    owner   => $jolokia::config_file_owner,
    group   => $jolokia::config_file_group,
    content => template('jolokia/jvm_agent.properties.erb'),
  }

}
