plan profile::user_remove (
  TargetSpec $targets,
) {
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
