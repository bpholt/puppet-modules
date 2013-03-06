# Install mongodb and configure parameters
#
# === Parameters
#
# $version can be 1.8.5-mongodb_1, 2.0.8-mongodb_1, 2.2.2-mongodb_1, or 'UNSET' (Default)
# UNSET will install the latest version from the 10-gen repo
#
# === Examples
# class { "mongodb::install": version => '2.2.2-mongodb_1' }
#
#
#
class mongodb::install ( $quota       = 'true', 
                         $quotafiles  = '32', 
                         $ensure      = 'UNSET',
                         $dbpath      = '/var/lib/mongo',
                         $logpath     = '/var/log/mongo/mongod.log',
                         $port        = '27017',
                         $version     = 'UNSET',
                         $ipv6        = false,
                         $auth        = false,
) {
  
include mongodb::params

if $mongodb::params::supported == true {
  
  #Support the latest 3 versions in the 10-gen repository, if version is 'UNSET' we default
  #to the latest
  if ! ($version in ['1.8.5-mongodb_1', '2.0.8-mongodb_1', '2.2.2-mongodb_1', 'UNSET']) {
    fail ("Version must be 1.8.5-mongodb_1, 2.0.8-mongodb_1, 2.2.2-mongodb_1, or UNSET")
  }
  
# Install for redhat/centos/fedora
  if $mongodb::params::os == 'redhat' {
    
    # Set package names based on the input version and OS
      case $version {
        '1.8.5-mongodb_1': {
          $svr_name   = 'mongo18-10gen-server'
          $cli_name   = 'mongo18-10gen'
        }
        '2.0.8-mongodb_1': {
          $svr_name   = 'mongo20-10gen-server'
          $cli_name   = 'mongo20-10gen'
        }
        '2.2.2-mongodb_1': {
          $svr_name   = 'mongo-10gen-server'
          $cli_name   = 'mongo-10gen'
        }
        default: {
          $svr_name   = 'mongo-10gen-server'
          $cli_name   = 'mongo-10gen'
        }  
      }
  
      # Setup the mongodb repo
      file { 'mongo-repo':
        path    => '/etc/yum.repos.d/10gen.repo',
        source  => "puppet:///modules/${module_name}/10gen.repo",
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
      }

      # Install the server.
      $ver = $version ? {
        'UNSET' => installed,
        default => $version
      }
      package { $svr_name:
        name    => $svr_name,
        ensure  => $ver,
        require => File['mongo-repo'],
      } 
  }
    
# Setup the config file
  file { $mongodb::params::config:
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template("${module_name}/${mongodb::params::config_tpl}"),
    require => Package[$svr_name],
  }
  
  # Configure the service
  if ($ensure == 'UNSET') {
    notice("Service parameter, ensure, not set.  Doing nothing with service.")
  } 
  
  else {
    service { $mongodb::params::svc_name:
      ensure    => $ensure,
      subscribe => [ Package[$svr_name], File[$mongodb::params::config]],
    }
  }
}
  else {
    notice("System not supported")    
  }
}