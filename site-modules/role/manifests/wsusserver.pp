# wsusserver role
class role::wsusserver {
  include profile::base
  include profile::wsusserver
}
