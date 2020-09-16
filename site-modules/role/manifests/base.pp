# @summary base role
#
# Default for any servers that don't have a role defined
# All roles should include the base profile
#
class role::base {
  include profile::base
}
