# @summary profile to set up policy based autosigning on CA master
#
# mod 'danieldreier-autosign', '0.3.0'
#
# @see https://github.com/danieldreier/autosign
# @see https://puppet.com/docs/puppet/latest/ssl_autosign.html
# @see https://danieldreier.github.io/autosign/
class profile::autosign {

  # don't do anything if settings not present in hiera
  $autosign_config = lookup('autosign::config', { 'merge' => 'hash', 'default_value' => {}})

  unless $autosign_config.empty {
    ini_setting { 'policy-based autosigning':
      setting => 'autosign',
      path    => "${confdir}/puppet.conf",
      section => 'master',
      value   => '/opt/puppetlabs/puppet/bin/autosign-validator',
      notify  => Service['pe-puppetserver'],
    }

    # use APL to get autosign::config, other params from hiera
    include ::autosign
  }
}
