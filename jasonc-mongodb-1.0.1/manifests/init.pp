# == Class: mongodb
#
# Install, configure, and manage mongodb from the 10-gen repository.
#
#This module currently only supports RHEL/CentOS/Fedora.
#
# === Examples
#
#  include mongodb
#
# === Authors
#
# Jason Cochard <jason.cochard@gmail.com>
#
# === Copyright
#
# Copyright 2012 Jason Cochard
#

class mongodb {
  include mongodb::params, mongodb::install
}