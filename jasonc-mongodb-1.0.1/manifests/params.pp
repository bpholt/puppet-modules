class mongodb::params {
  case $::operatingsystem {
      /(Redhat|CentOS|Fedora)/: {
        $supported  = true
        $svc_name   = 'mongod'
        $config     = '/etc/mongod.conf'
        $config_tpl = 'mongod.conf.redhat.erb'
        $os         = 'redhat'
    }
      default: {
        $supported = false
        notify { "${module_name}_unsupported":
          message => "The ${module_name} module is not support on ${::operatingsystem}",
          }
      }
    }
}