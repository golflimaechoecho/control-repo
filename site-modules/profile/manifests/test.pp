# test.pp
class profile::test {
  if defined("potato::nobueno") {
    notify { "potato defined": }
  } else {
    notify { "potato not defined": }
  }
  if defined("pe_nc_backup") {
    notify { "pe_nc_backup defined": }
  } else {
    notify { "pe_nc_backup not defined": }
  }
  #include potato::nobueno
}
