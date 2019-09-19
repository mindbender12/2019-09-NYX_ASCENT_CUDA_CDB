
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

action "validate" {
  needs = "execute"
  uses = "sh"
  args = "./sbang.sh validate/check_one_output_file.sh"
}
