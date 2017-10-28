#!/usr/bin/env bats


@test "live compilation script should match Markdown source" {
  # read existing form of the live script
  pre="$(less lit.sh)"
  # recompile Markdown source to shell script
  ./lit.sh lit.sh.md
  # read newly compiled version of the live script
  post="$(less lit.sh)"
  [ "$pre" == "$post" ]
}
