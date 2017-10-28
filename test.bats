#!/usr/bin/env bats


@test "live compilation script should match Markdown source" {
  mkdir test
  # read existing form of the live script
  pre="$(less test/lit.sh)"
  # recompile Markdown source to shell script
  ./lit.sh lit.sh.md
  # read newly compiled version of the live script
  post="$(less test/lit.sh)"
  rm -rf ./test
  [ "$pre" == "$post" ]
}

@test "does not compile files that end in .md without a double extension" {
  mkdir test
  ./lit.sh ./lit.sh.md
  touch test/README.md
  ./lit.sh "./test/*"
  count="$(find test -type f | wc -l)"
  rm -rf ./test
  [ "$count" -eq 1 ]
}

@test "does not compile files that end in a normal file extension" {
  mkdir test
  ./lit.sh ./lit.sh.md
  touch test/script.py
  touch test/script.js
  ./lit.sh "./test/*"
  count="$(find test -type f | wc -l)"
  rm -rf ./test
  [ "$count" -eq 2 ]
}

@test "does not compile non-Markdown files that end in a double file extension" {
  mkdir test
  ./lit.sh ./lit.sh.md
  touch test/script.py.js
  ./lit.sh "./test/*"
  count="$(find test -type f | wc -l)"
  rm -rf ./test
  [ "$count" -eq 1 ]
}

@test "compiles Markdown files that end in a double file extension" {
  mkdir test
  ./lit.sh ./lit.sh.md
  touch test/script.py.md
  ./lit.sh "./test/*"
  count="$(find test -type f | wc -l)"
  rm -rf ./test
  [ "$count" -eq 2 ]
}
