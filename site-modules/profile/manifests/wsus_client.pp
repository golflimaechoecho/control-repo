# wsus_client profile
# uses mod 'puppetlabs-wsus_client', '3.1.0'
#
# At the time of writing server_url set via hiera
#
class profile::wsus_client {
  include ::wsus_client
}
