# placeholder for patching::snapshot_vmware until firewall/functionality confirmed
plan profile::snapshot_placeholder (
  TargetSpec $targets,
  Optional[Enum['hostname', 'name', 'uri']] $target_name_property = undef,
  String[1] $vsphere_host       = get_targets($targets)[0].vars['vsphere_host'],
  String[1] $vsphere_username   = get_targets($targets)[0].vars['vsphere_username'],
  String[1] $vsphere_password   = get_targets($targets)[0].vars['vsphere_password'],
  String[1] $vsphere_datacenter = get_targets($targets)[0].vars['vsphere_datacenter'],
  Boolean $vsphere_insecure     = get_targets($targets)[0].vars['vsphere_insecure'],
) {
  # placeholder for patching::snapshot_vmware, replace once firewall rules in place/confirmed working
  out::message("Run plan('profile::snapshot_placeholder', targets => ${targets},
                                            action               => 'create',
                                            target_name_property => ${target_name_property},
                                            vsphere_host         => ${vsphere_host},
                                            vsphere_username     => ${vsphere_username},
                                            vsphere_password     => ${vsphere_password},
                                            vsphere_datacenter   => ${vsphere_datacenter},
                                            vsphere_insecure     => ${vsphere_insecure}")
}
