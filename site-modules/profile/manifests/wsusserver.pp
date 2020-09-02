# wsusserver profile
# uses mod 'tragiccode-wsusserver', '1.1.3'
#
# minimum requirements according to module - these are set via hiera (eg: roles/wsusserver.yaml)
#
# class { 'wsusserver':
#     package_ensure => 'present',
#     update_languages                   => ['en'],
#     products                           => [
#       'Active Directory Rights Management Services Client 2.0',
#       'ASP.NET Web Frameworks',
#       'Microsoft SQL Server 2012',
#       'SQL Server Feature Pack',
#       'SQL Server 2012 Product Updates for Setup',
#       'Windows Server 2016',
#     ],
#     update_classifications             => [
#         'Critical Updates',
#         'Security Updates',
#         'Updates',
#     ],
# }
class profile::wsusserver {
  include ::wsusserver
}
