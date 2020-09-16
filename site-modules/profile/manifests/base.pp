# @summary base profile
#
# the base profile should include component modules that will be on all nodes
# and should be included in all roles
#
class profile::base {
  # common classes here
  include profile::puppet_agent

  # platform specific
  case $facts['os']['family'] {
    'AIX': {
    }
    'RedHat': {
    }
    'windows': {
      include profile::windows::installedkb
    }
    default: {
      fail("Unsupported OS: ${facts['os']['family']}")
    }
  }
}
