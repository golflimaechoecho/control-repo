forge 'https://forge.puppet.com'

# Modules from the Puppet Forge
# Versions should be updated to be the latest at the time you start
mod 'danieldreier-autosign', '0.3.0'
mod 'puppetlabs-stdlib', '6.3.0'
mod 'puppetlabs-inifile', '4.2.0'
mod 'puppet-gitlab', '5.1.0'

# CD4PE requirements (apt omitted as only EL hosts for now; stdlib included above)
mod 'puppetlabs-cd4pe', '2.0.1'
mod 'puppetlabs-puppet_authorization', '0.5.1'
mod 'puppetlabs-hocon', '1.1.0'
mod 'puppetlabs-concat', '6.2.0'
mod 'puppetlabs-docker', '3.10.2'
mod 'puppetlabs-translate', '2.2.0'
mod 'puppetlabs-cd4pe_jobs', '1.4.0'

# powershell and reboot required for puppetlabs-docker
mod 'puppetlabs-powershell', '4.0.0' # docker requires <= 4.0.0 but 4.x adds el8 support
mod 'puppetlabs-reboot', '3.0.0'  # similarly <= 3.0.0 but 3.x updates nodes to targets

# pwshlib required for powershell
mod 'puppetlabs-pwshlib', '0.4.1'

# windows labs
mod 'puppetlabs-dsc', '1.9.4'
mod 'puppetlabs-acl', '3.2.0'

# ca_extend testing
mod 'puppetlabs-ca_extend', '1.1.1'

mod 'tragiccode-wsusserver', '1.1.3'
mod 'puppetlabs-wsus_client', '3.1.0'
mod 'puppetlabs-registry', '3.1.1'

#mod 'encore-patching', '1.1.1'
mod 'encore-patching',
  :git => 'git@gl-gitlab.platform9.puppet.net:p9/fork-encore-patching.git',
  :ref => '79fa54f364a7d371567f3dfa55ed2c4718022ea5'

mod 'puppetlabs-puppet_agent', '4.1.1'

mod 'bnm_patching',
  :git => 'git@gl-gitlab.platform9.puppet.net:p9/bnm_patching.git',
  :branch => :control_branch,
  :default_branch => 'production'

# Modules from Git
# Examples: https://github.com/puppetlabs/r10k/blob/master/doc/puppetfile.mkd#examples
#mod 'apache',
#  git:    'https://github.com/puppetlabs/puppetlabs-apache',
#  commit: '1b6f89afdde0df7f9433a163d5c4b5328eac5779'

#mod 'apache',
#  git:    'https://github.com/puppetlabs/puppetlabs-apache',
#  branch: 'docs_experiment'
