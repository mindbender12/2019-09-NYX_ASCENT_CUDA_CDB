
workflow "nyx" {
  resolves = "execute"
}

action "install dependencies" {

  uses = "sh"
  args = "setup/install-deps.sh"
}

action "execute" {
  needs = "install dependencies"
  uses = "sh"
  args = "run/copy_and_launch.sh"
}
