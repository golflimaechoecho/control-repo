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
mod 'puppetlabs-acl', '3.2.0'
# puppetlabs/dsc replaced with puppetized dsc modules
# https://confluence.puppetlabs.com/display/ECO/Deprecation+plan+for+legacy+DSC+modules
# https://dev.to/puppet/converting-to-use-puppetized-dsc-modules-30d
#mod 'puppetlabs-dsc', '1.9.4'
mod 'dsc-activedirectorycsdsc', '3.1.0-0-0'
mod 'dsc-auditpolicydsc', '1.4.0-0-1'
mod 'dsc-certificatedsc', '4.4.0-0-0'
mod 'dsc-computermanagementdsc', '6.2.0-0-0'
mod 'dsc-dfsdsc', '4.3.0-0-0'
mod 'dsc-networkingdsc', '7.0.0-0-0'
mod 'dsc-officeonlineserverdsc', '1.2.0-0-0'
mod 'dsc-securitypolicydsc', '2.7.0-0-0'
mod 'dsc-sharepointdsc', '3.2.0-0-0'
mod 'dsc-sqlserverdsc', '12.3.0-0-0'
mod 'dsc-storagedsc', '4.5.0-0-0'
mod 'dsc-systemlocaledsc', '1.2.0-0-0'
mod 'dsc-xactivedirectory', '2.24.0-0-0'
mod 'dsc-xazure', '0.2.0-0-0'
mod 'dsc-xazurepack', '1.4.0-0-0'
mod 'dsc-xbitlocker', '1.4.0-0-0'
mod 'dsc-xcredssp', '1.3.0-0-0'
mod 'dsc-xdatabase', '1.9.0-0-0'
mod 'dsc-xdefender', '0.2.0-0-0'
mod 'dsc-xdhcpserver', '2.0.0-0-0'
mod 'dsc-xdisk', '1.0.0-0-0'
mod 'dsc-xdismfeature', '1.3.0-0-0'
mod 'dsc-xdnsserver', '1.11.0-0-0'
mod 'dsc-xexchange', '1.27.0-0-0'
mod 'dsc-xfailovercluster', '1.12.0-0-0'
mod 'dsc-xhyper_v', '3.16.0-0-0'
mod 'dsc-xinternetexplorerhomepage', '1.0.0-0-0'
mod 'dsc-xjea', '0.2.16-6-0'
mod 'dsc-xmysql', '2.1.0-0-0'
mod 'dsc-xpendingreboot', '0.4.0-0-0'
mod 'dsc-xphp', '1.2.0-0-0'
mod 'dsc-xpowershellexecutionpolicy', '3.1.0-0-0'
mod 'dsc-xpsdesiredstateconfiguration', '8.5.0-0-0'
mod 'dsc-xremotedesktopadmin', '1.1.0-0-0'
mod 'dsc-xremotedesktopsessionhost', '1.8.0-0-0'
mod 'dsc-xrobocopy', '2.0.0-0-0'
mod 'dsc-xscdpm', '1.2.0-0-0'
mod 'dsc-xscom', '1.3.3-0-0'
mod 'dsc-xscsma', '2.0.0-0-0'
mod 'dsc-xscspf', '1.3.1-0-0'
mod 'dsc-xscsr', '1.3.0-0-0'
mod 'dsc-xscvmm', '1.2.4-0-0'
mod 'dsc-xsmbshare', '2.1.0-0-0'
mod 'dsc-xsqlps', '1.4.0-0-0'
mod 'dsc-xtimezone', '1.8.0-0-0'
mod 'dsc-xwebadministration', '2.5.0-0-0'
mod 'dsc-xwebdeploy', '1.2.0-0-0'
mod 'dsc-xwindowseventforwarding', '1.0.0-0-0'
mod 'dsc-xwindowsrestore', '1.0.0-0-0'
mod 'dsc-xwindowsupdate', '2.7.0-0-0'
mod 'dsc-xwineventlog', '1.2.0-0-0'
mod 'dsc-xwordpress', '1.1.0-0-0'
### end replacement puppetized dsc modules

# ca_extend testing
mod 'puppetlabs-ca_extend', '1.1.1'

mod 'tragiccode-wsusserver', '1.1.3'
mod 'puppetlabs-wsus_client', '3.1.0'
mod 'puppetlabs-registry', '3.1.1'

# dsc_lite, iis
mod 'puppetlabs-dsc_lite', '3.0.1'
mod 'puppetlabs-iis', '7.1.0'

mod 'puppet-archive', '4.6.0'
mod 'puppetlabs-chocolatey', '5.1.1'
mod 'WhatsARanjit-node_manager', '0.7.3'

mod 'encore-patching', '1.1.1'
#mod 'encore-patching',
#  :git => 'git@gl-gitlab.platform9.puppet.net:p9/fork-encore-patching.git',
#  :ref => '79fa54f364a7d371567f3dfa55ed2c4718022ea5'

mod 'puppetlabs-puppet_agent', '4.1.1'

#mod 'bnm_patching',
#  :git => 'git@gl-gitlab.platform9.puppet.net:p9/bnm_patching.git',
#  :branch => :control_branch,
#  :default_branch => 'production'

# Modules from Git
# Examples: https://github.com/puppetlabs/r10k/blob/master/doc/puppetfile.mkd#examples
#mod 'apache',
#  git:    'https://github.com/puppetlabs/puppetlabs-apache',
#  commit: '1b6f89afdde0df7f9433a163d5c4b5328eac5779'

#mod 'apache',
#  git:    'https://github.com/puppetlabs/puppetlabs-apache',
#  branch: 'docs_experiment'
