plan profile::user_remove (
  TargetSpec $targets,
) {
  apply_prep($targets)
  apply($targets) {
    $user = 'cccsdp'
    $group = 'Administrators'
    user { $user:
      ensure     => absent,
      forcelocal => true,
    }
  }
  return()
}
