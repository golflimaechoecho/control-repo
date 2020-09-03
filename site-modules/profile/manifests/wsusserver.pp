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
class profile::wsusserver (
  Hash $approvalrule_overrides = {},
){
  include ::wsusserver

  $computer_target_groups = lookup('profile::wsusserver::computer_target_groups',
                                    { 'value_type'    => Array[String],
                                      'merge'         => 'unique',
                                      'default_value' => [],
                                    })

  $computer_target_groups.each | String $target_group | {
    wsusserver_computer_target_group { $target_group:
      ensure => present,
    }
  }

  $approvalrules = lookup('profile::wsusserver::approvalrules',
                          { 'value_type'    => Hash,
                            'merge'         => 'hash',
                            'default_value' => {},
                          })

  $approvalrules_real = $approvalrules + $approvalrule_overrides

  $approvalrules_real.each | String $approvalrule, Hash $rule_attributes | {
    wsusserver::approvalrule { $approvalrule:
      * => $rule_attributes,
    }
  }
}
