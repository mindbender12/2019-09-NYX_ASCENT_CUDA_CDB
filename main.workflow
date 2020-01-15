
workflow "nyx" {
  resolves = "validate"
}

action "install dependencies" {
  uses = "sh"
  args = "./sbang.sh setup/install-deps.sh"
}

action "execute" {
  needs = "install dependencies"
  uses = "sh"
  args = "./sbang.sh run/copy_and_launch.sh"
}

action "check job completion" {
  needs = "execute"
  uses = "sh"
  args = "./sbang.sh run/wait_for_completion.sh"
}

action "validate" {
  needs = "check job completion"
  uses = "sh"
  args = "./sbang.sh validate/package_cinema_databases.sh"
}
