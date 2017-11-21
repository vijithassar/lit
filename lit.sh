#!/bin/bash
set -e

# default values
files="./*.*.md"
output_directory=""
before=''
after=''
stdio=0
verbose=0
filename_prefix=""

# as long as there is at least one more argument, keep looping
while [[ ${#} -gt 0 ]]; do
    key="${1}"
    case "${key}" in
        # stdio
        -s|--stdio)
        stdio=1
        ;;
        # input files
        -i|--input)
        shift
        files="${1}"
        ;;
        # output files
        -o|--output)
        shift
        output_directory="${1%/}/"
        ;;
        # verbose logging
        -v|--verbose)
        verbose=1
        ;;
        # hidden files
        -h|--hidden)
        filename_prefix="."
        ;;
        # demarcate start of block or line comment
        -b|--before)
        shift
        before="${1}"
        ;;
        # end block comment
        -a|--after)
        shift
        after="${1}"
        ;;
        *)
        # report unrecognized options
        echo "unknown option '${key}'"
        exit 1
        ;;
    esac
    # shift after checking all the cases to get the next option
    shift
done
# given a filename ending in .md, return the base filename
remove_extension() {
  local file=${1}
  # file extension .md will always have three characters
  local extension_length=3
  # old file path length
  local old_length=${#file}
  # calculate new filename length
  local new_length=${old_length}-${extension_length}
  # cut substring for new filename
  local new_filename=${file:0:$new_length}
  # output the new string
  echo "${new_filename}"
}
# make sure a filename is safe to process
test_filename() {
  # first argument is the filename to test
  local file_path=${1}
  # return immediately if this isn't a markdown file
  local last_three_characters=${file_path: -3}
  if [ "${last_three_characters}" != ".md" ]; then
    return 1
  fi
  # strip leading directories and only look at the filename
  local file_name=${file_path##*/}
  # return filename
  local dots=${file_name//[^.]};
  local dot_count=${#dots}
  if [ "${dot_count}" -gt 1 ]; then
    return 0
  else
    return 1
  fi
}
# swap substrings in a string to produce an awk command
configure_awk_command() {
  local markdown_action
  local awk_command_base
  local awk_command
  # if there's no delimiter, jump to next line for Markdown content
  if [ -z "${before}" ]; then
    markdown_action="next;"
  # if a delimiter is provided in the --before flag, comment out Markdown content
  else
    # if there's no --after flag, use a line comment
    if [ -z "${after}" ]; then
      markdown_action="{ print \"${before}\", \$0 };"
    # if there's an --after flag, use a block comment
    else
      markdown_action="{ print \"${before}\", \$0, \"${after}\" };"
    fi
  fi
  # base command structure
  awk_command_base='
      if (/^```/) {
        i++;
        REPLACE
        next;
      }
      if ( i % 2 != 0 ) {
        print $0;
      } else {
        REPLACE
      }
  '
  # substitute desired actions in the command string
  awk_command="${awk_command_base//REPLACE/$markdown_action}"
  # output configured awk command
  echo "${awk_command}"
}
# handle Markdown content in an input file
process_lines() {
  local awk_command
  local processed
  local content
  # first argument is Markdown content
  content="${1}"
  # run awk command
  awk_command=$(configure_awk_command)
  processed=$(echo "${content}" | awk {"$awk_command"})
  # return code blocks only
  echo "${processed}"
}
# routine to compile a single file
process_file() {
  local markdown_file
  local content
  local output_file
  local compiled
  # first argument is filename
  markdown_file=${1}
  output_filename="${filename_prefix}$(basename "${markdown_file}" '.md')"
  # convert to the new filename
  if [ ! -z "${output_directory}" ]; then
    new_filename="${output_directory}${output_filename}"
  else
    new_filename="$(dirname ${markdown_file})/${output_filename}"
  fi
  content="$(less "${file}")"
  # parse file content and remove Markdown comments
  compiled="$(process_lines "${content}")"
  # save results to file
  echo "${compiled}" > "${new_filename}"
  if [ "${stdio}" = 0 ]; then
    if [ "${verbose}" -eq 0 ]; then
      # print filename of compiled file to output
      echo "${new_filename}"
    elif [ "${verbose}" -eq 1 ]; then
      # alternately, verbose logging
      echo "${file} > ${new_filename}"
    fi
  fi
}
if [ ! -z "${output_directory}" ] && [ ! -d "${output_directory}" ]; then
  mkdir -p "${output_directory}"
fi
# if stdio isn't enabled
if [ "${stdio}" -eq 0 ]; then

  # expand glob into a list of filenames
  filelist=$(find ${files} -name "*.md" -type f)

  # loop through files
  if [ "${verbose}" -eq 1 ]; then
    echo "compiling $(echo ${filelist} | wc -l) files in ${files}"
  fi
  for file in ${filelist}
  do
    # make sure it's a literate code file
    if test_filename "${file}"; then
      # compile
      process_file "${file}"
    fi
  done
# if stdio is enabled
elif [ "${stdio}" -eq 1 ]; then
  # process stdin to stdout
  content="$(</dev/stdin)"
  echo "$(process_lines "${content}")"
fi
