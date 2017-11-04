#!/bin/bash

set -e

# default values
files="./*.*.md"
before=''
after=''

# as long as there is at least one more argument, keep looping
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        # input files
        -i|--input)
        shift
        files="$1"
        ;;
        # demarcate start of block or line comment
        -b|--before)
        shift
        before="$1"
        ;;
        # end block comment
        -a|--after)
        shift
        after="$1"
        ;;
        *)
        # report unrecognized options
        echo "unknown option '$key'"
        exit 1
        ;;
    esac
    # shift after checking all the cases to get the next option
    shift
done
# given a filename ending in .md, return the base filename
function remove_extension {
  local file=$1
  # file extension .md will always have three characters
  local extension_length=3
  # old file path length
  local old_length=${#file}
  # calculate new filename length
  local new_length=$old_length-$extension_length
  # cut substring for new filename
  local new_filename=${file:0:$new_length}
  # return the new string
  echo "$new_filename"
}
# make sure a filename is safe to process
function test_filename {
  # first argument is the filename to test
  local file_path=$1
  # return immediately if this isn't a markdown file
  local last_three_characters=${file_path: -3}
  if [ $last_three_characters != ".md" ]; then
    return 1
  fi
  # strip leading directories and only look at the filename
  local file_name=${file_path##*/}
  # return filename
  local dots=${file_name//[^.]};
  local dot_count=${#dots}
  if [ $dot_count -gt 1 ]; then
    return 0
  else
    return 1
  fi
}
function configure_awk_command {
  local action
  local awk_command_base
  local awk_command
  if [ -z "${before}" ]; then
    action="next"
  else
    action="print"
  fi
  awk_command_base='
      # if it is a code block
      if (/^```/) {
        # increase backtick counter
        i++;
        # jump to next command
        action;
      }
      # print
      if ( i % 2 == 1) {
        print;
      }
  '
  awk_command="${awk_command_base/action/$action}"
  echo "${awk_command}"
}
# strip Markdown
function process_lines {
  # first argument is filename
  local file=$1
  # run awk command
  local awk_command=$(configure_awk_command)
  local processed=$(awk {"$awk_command"} $file)
  # return code blocks only
  echo "$processed"
}
# compile Markdown code blocks in a file using awk
function compile {
  # first argument is filename
  local file=$1
  # convert to the new filename
  local new_filename=$(remove_extension $file)
  # log message
  echo "compiling $file > $new_filename"
  # parse file content and remove Markdown comments
  local compiled=$(process_lines $file)
  # save results to file
  echo "$compiled" > $new_filename
}
# loop through files
for file in $(ls $files)
do
  # make sure it's a literate code file
  if test_filename $file; then
    # compile
    compile $file
  fi
done
