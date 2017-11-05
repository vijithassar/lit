#!/usr/bin/env bats

setup() {
  mkdir test
  ./lit.sh --input lit.sh.md
}

teardown() {
  rm -rf test
}

@test "live compilation script matches Markdown source" {
  git checkout lit.sh
  pre="$(less lit.sh)"
  ./lit.sh --input lit.sh.md
  post="$(less lit.sh)"
  [ "${pre}" == "${post}" ]
}

@test "compiled example matches Markdown source" {
  git checkout hello-world.js
  pre="$(less hello-world.js)"
  ./lit.sh --input hello-world.js.md
  post="$(less hello-world.js)"
  [ "${pre}" == "${post}" ]
}

@test "skips files that end in a single .md extension" {
  touch test/README.md
  ./lit.sh --input "./test/*"
  count="$(find test/ -type f | wc -l)"
  [ "${count}" -eq 1 ]
}

@test "skips files that end in a single file extension" {
  touch test/script.py
  touch test/script.js
  ./lit.sh --input "./test/*"
  count="$(find test/ -type f | wc -l)"
  [ "${count}" -eq 2 ]
}

@test "skips non-Markdown files that end in a double file extension" {
  touch test/script.py.js
  ./lit.sh --input "./test/*"
  count="$(find test -type f | wc -l)"
  [ "${count}" -eq 1 ]
}

@test "compiles Markdown files that end in a double file extension" {
  touch test/script.py.md
  ./lit.sh --input "./test/*"
  count="$(find test/ -type f | wc -l)"
  [ "${count}" -eq 2 ]
}

@test "preserves original file extensions in output filenames" {
  touch test/script.py.md
  ./lit.sh --input "./test/*"
  new_file="$([ -e test/script.py ])"
  [ new_file ]
}

@test "compiles multiple files" {
  touch test/first.py.md
  touch test/second.py.md
  ./lit.sh --input "./test/*"
  count="$(find test/ -type f | wc -l)"
  [ "${count}" -eq 4 ]
}

@test "compiles files in the current working directory" {
  touch test/script.py.md
  cd test
  ../lit.sh
  cd ..
  count="$(find test/ -type f | wc -l)"
  [ "${count}" -eq 2 ]
}

@test "selects files to compile based on a file glob provided via the --input long argument" {
  touch test/first.py.md
  touch test/second.py.md
  touch test/third.js.md
  ./lit.sh --input "./test/*.py.md"
  count="$(find test/ -type f | wc -l)"
  [ "${count}" -eq 5 ]
}

@test "selects files to compile based on a file glob provided via the -i short argument" {
  touch test/first.py.md
  touch test/second.py.md
  touch test/third.js.md
  ./lit.sh -i "./test/*.py.md"
  count="$(find test/ -type f | wc -l)"
  [ "${count}" -eq 5 ]
}

@test "writes to an output directory based on a path provided via the --output long argument" {
  touch test/first.py.md
  touch test/second.py.md
  ./lit.sh --input "./test/*.py.md" --output test/subdirectory/
  count="$(find test/subdirectory/ -type f | wc -l)"
  [ "${count}" -eq 2 ]
}

@test "writes to an output directory based on a path provided via the -o short argument" {
  touch test/first.py.md
  touch test/second.py.md
  ./lit.sh --input "./test/*.py.md" -o test/subdirectory/
  count="$(find test/subdirectory/ -type f | wc -l)"
  [ "${count}" -eq 2 ]
}

@test "writes to nested subdirectories" {
  touch test/first.py.md
  touch test/second.py.md
  ./lit.sh --input "./test/*.py.md" --output test/subdirectory/a/b
  count="$(find test/subdirectory/a/b/ -type f | wc -l)"
  [ "${count}" -eq 2 ]
}

@test "appends trailing slashes to output directories" {
  touch test/first.py.md
  touch test/second.py.md
  ./lit.sh --input "./test/*.py.md" --output test/subdirectory
  count="$(find test/subdirectory/ -type f | wc -l)"
  [ "${count}" -eq 2 ]
}

@test "uses existing paths if no output directory is specified" {
  mkdir test/subdirectory
  touch test/subdirectory/first.py.md
  ./lit.sh --input "./test/subdirectory/*.py.md"
  count="$(find test/subdirectory/ -type f | wc -l)"
  [ "${count}" -eq 2 ]
}

@test "removes Markdown and preserves code" {
  markdown=$'# a heading\nsome text\n```\nsome code\n```'
  printf "${markdown}" >> test/script.py.md
  ./lit.sh --input ./test/script.py.md
  code="$(less ./test/script.py)"
  [ "${code}" == "some code" ]
}

@test "allows language annotation after backticks" {
  markdown=$'# a heading\nsome text\n```javascript\nsome code\n```'
  printf "${markdown}" >> test/script.py.md
  ./lit.sh --input ./test/script.py.md
  code="$(less ./test/script.py)"
  [ "${code}" == "some code" ]
}

@test "compiles multiple fenced code blocks" {
  first=$'# a heading\nsome text\n```\nsome code\n```'
  second=$'# a heading\nsome text\n```\nsome more code\n```'
  expected=$'some code\nsome more code'
  printf "${first}" >> test/script.py.md
  printf "${second}" >> test/script.py.md
  ./lit.sh --input ./test/script.py.md
  code="$(less ./test/script.py)"
  [ "${code}" == "${expected}" ]
}

@test "preserves line positions using line comments with the --before long argument" {
  input=$'# a heading\nsome text\n```\nsome code\n```'
  expected=$'// # a heading\n// some text\n// ```\nsome code\n// ```'
  printf "${input}" >> test/script.js.md
  ./lit.sh --input ./test/script.js.md --before "//"
  code="$(less ./test/script.js)"
  [ "${code}" == "${expected}" ]
}

@test "preserves line positions using line comments with the -b short argument" {
  input=$'# a heading\nsome text\n```\nsome code\n```'
  expected=$'// # a heading\n// some text\n// ```\nsome code\n// ```'
  printf "${input}" >> test/script.js.md
  ./lit.sh --input ./test/script.js.md -b "//"
  code="$(less ./test/script.js)"
  [ "${code}" == "${expected}" ]
}

@test "preserves line positions using block comments with the --after long argument" {
  input=$'# a heading\nsome text\n```\nsome code\n```'
  expected=$'/* # a heading */\n/* some text */\n/* ``` */\nsome code\n/* ``` */'
  printf "${input}" >> test/style.css.md
  ./lit.sh --input ./test/style.css.md --before "/*" --after "*/"
  code="$(less ./test/style.css)"
  [ "${code}" == "${expected}" ]
}

@test "preserves line positions using block comments with the -a short argument" {
  input=$'# a heading\nsome text\n```\nsome code\n```'
  expected=$'/* # a heading */\n/* some text */\n/* ``` */\nsome code\n/* ``` */'
  printf "${input}" >> test/style.css.md
  ./lit.sh --input ./test/style.css.md --before "/*" -a "*/"
  code="$(less ./test/style.css)"
  [ "${code}" == "${expected}" ]
}
