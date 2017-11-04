#!/usr/bin/env bats

setup() {
  mkdir test
  ./lit.sh --input lit.sh.md
}

teardown() {
  rm -rf test
}

@test "live compilation script should match Markdown source" {
  git checkout lit.sh
  pre="$(less lit.sh)"
  ./lit.sh --input lit.sh.md
  post="$(less lit.sh)"
  [ "${pre}" == "${post}" ]
}

@test "compiled example should match Markdown source" {
  git checkout hello-world.js
  pre="$(less hello-world.js)"
  ./lit.sh --input hello-world.js.md
  post="$(less hello-world.js)"
  [ "${pre}" == "${post}" ]
}

@test "should not compile files that end in .md without a double extension" {
  touch test/README.md
  ./lit.sh --input "./test/*"
  count="$(find test -type f | wc -l)"
  [ "${count}" -eq 1 ]
}

@test "should not compile files that end in a single file extension" {
  touch test/script.py
  touch test/script.js
  ./lit.sh --input "./test/*"
  count="$(find test -type f | wc -l)"
  [ "${count}" -eq 2 ]
}

@test "should not compile non-Markdown files that end in a double file extension" {
  touch test/script.py.js
  ./lit.sh --input "./test/*"
  count="$(find test -type f | wc -l)"
  [ "${count}" -eq 1 ]
}

@test "should compile Markdown files that end in a double file extension" {
  touch test/script.py.md
  ./lit.sh --input "./test/*"
  count="$(find test -type f | wc -l)"
  [ "${count}" -eq 2 ]
}

@test "should preserve original file extensions in output filenames" {
  touch test/script.py.md
  ./lit.sh --input "./test/*"
  new_file="$([ -e test/script.py ])"
  [ new_file ]
}

@test "should compile multiple files" {
  touch test/first.py.md
  touch test/second.py.md
  ./lit.sh --input "./test/*"
  count="$(find test -type f | wc -l)"
  [ "${count}" -eq 4 ]
}

@test "should select files to compile based on a file glob provided via the --input argument" {
  touch test/first.py.md
  touch test/second.py.md
  touch test/third.js.md
  ./lit.sh --input "./test/*.py.md"
  count="$(find test -type f | wc -l)"
  [ "${count}" -eq 5 ]
}

@test "should select files to compile based on a file glob provided via the -i short argument" {
  touch test/first.py.md
  touch test/second.py.md
  touch test/third.js.md
  ./lit.sh -i "./test/*.py.md"
  count="$(find test -type f | wc -l)"
  [ "${count}" -eq 5 ]
}

@test "should remove Markdown and preserve code" {
  markdown=$'# a heading\nsome text\n```\nsome code\n```'
  printf "${markdown}" >> test/script.py.md
  ./lit.sh --input ./test/script.py.md
  code="$(less ./test/script.py)"
  [ "${code}" == "some code" ]
}

@test "should allow language annotation after backticks" {
  markdown=$'# a heading\nsome text\n```javascript\nsome code\n```'
  printf "${markdown}" >> test/script.py.md
  ./lit.sh --input ./test/script.py.md
  code="$(less ./test/script.py)"
  [ "${code}" == "some code" ]
}

@test "should compile multiple fenced code blocks" {
  first=$'# a heading\nsome text\n```\nsome code\n```'
  second=$'# a heading\nsome text\n```\nsome more code\n```'
  expected=$'some code\nsome more code'
  printf "${first}" >> test/script.py.md
  printf "${second}" >> test/script.py.md
  ./lit.sh --input ./test/script.py.md
  code="$(less ./test/script.py)"
  [ "${code}" == "${expected}" ]
}

@test "should preserve line positions using line comments with the --before argument" {
  input=$'# a heading\nsome text\n```\nsome code\n```'
  expected=$'// # a heading\n// some text\n// ```\nsome code\n// ```'
  printf "${input}" >> test/script.js.md
  ./lit.sh --input ./test/script.js.md --before "//"
  code="$(less ./test/script.js)"
  [ "${code}" == "${expected}" ]
}

@test "should preserve line positions using line comments with the -b argument" {
  input=$'# a heading\nsome text\n```\nsome code\n```'
  expected=$'// # a heading\n// some text\n// ```\nsome code\n// ```'
  printf "${input}" >> test/script.js.md
  ./lit.sh --input ./test/script.js.md -b "//"
  code="$(less ./test/script.js)"
  [ "${code}" == "${expected}" ]
}

@test "should preserve line positions using block comments with the --after argument" {
  input=$'# a heading\nsome text\n```\nsome code\n```'
  expected=$'/* # a heading */\n/* some text */\n/* ``` */\nsome code\n/* ``` */'
  printf "${input}" >> test/style.css.md
  ./lit.sh --input ./test/style.css.md --before "/*" --after "*/"
  code="$(less ./test/style.css)"
  [ "${code}" == "${expected}" ]
}

@test "should preserve line positions using block comments with the -a argument" {
  input=$'# a heading\nsome text\n```\nsome code\n```'
  expected=$'/* # a heading */\n/* some text */\n/* ``` */\nsome code\n/* ``` */'
  printf "${input}" >> test/style.css.md
  ./lit.sh --input ./test/style.css.md --before "/*" -a "*/"
  code="$(less ./test/style.css)"
  [ "${code}" == "${expected}" ]
}
