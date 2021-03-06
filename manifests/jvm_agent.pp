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
  $external_service     = '',
  $firewall             = params_lookup( 'firewall' , 'global' ),
  $collectd             = false,
  $collectd_type        = 'generic',
  $collectd_mbeans      = ['java.lang:type=Memory', 'java.lang:type=GarbageCollector,*', 'java.lang:type=Threading']
) {

  include jolokia

  validate_re($protocol, '^http(s)?$', 'the protocol has to bo one of http or https')
  validate_re($executor, '^(single|cached|fixed)$', 'the executer has to be one of single, cached or fixed')
  validate_bool($use_ssl_client_auth)
  validate_bool($boot_amx)
  validate_bool($discovery_enabled)
  validate_bool($include_stacktrace)

  $manage_external_service = $external_service ? {
    ''      => undef,
    default => Service[$external_service]
  }

  file { "jolokia.jvm_agent.${name}":
    ensure  => file,
    path    => "${jolokia::config_dir}/${name}.properties",
    mode    => $jolokia::config_file_mode,
    owner   => $jolokia::config_file_owner,
    group   => $jolokia::config_file_group,
    content => template('jolokia/jvm_agent.properties.erb'),
    notify  => $manage_external_service,
  }

  if $firewall {
    if $host != 'localhost' {
      firewall { "jolokia_access_tcp_${port}":
        enable      => true,
        source      => '0.0.0.0/0',
        destination => '0.0.0.0/0',
        protocol    => 'tcp',
        port        => $port,
        action      => 'allow',
        direction   => 'input',
        tool        => 'iptables',
      }
    }
  }

  $jolokia_mbeans = $collectd_type ? {
    'tomcat'   => ['java.lang:type=Memory', 'java.lang:type=GarbageCollector,*', 'java.lang:type=Threading', '*:type=GlobalRequestProcessor,*', '*:type=Manager,*'],
    'activemq' => ['java.lang:type=Memory', 'java.lang:type=GarbageCollector,*', 'java.lang:type=Threading', 'org.apache.activemq:type=Broker,*'],
    default    => $collectd_mbeans
  }

  if $collectd {
    collectd::plugin::jolokia::connection {
      "jolokia.collectd.${name}":
        url      => "http://localhost:${port}${agent_context}/",
        instance => $name,
        mbeans   => $jolokia_mbeans
    }
  }
}
