# Startup #

The shebang indicates that this script should be executed by the bash program.

```bash
#!/bin/bash

set -e
```

# Arguments

Use a loop to read command line arguments to the script and set variables which control the desired compilation behaviors.

```bash

# default values
files="./*.*.md"
output_directory=""
before=''
after=''
stdio=0
verbose=0

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
        output_directory="${1}"
        ;;
        # verbose logging
        -v|--verbose)
        verbose=1
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
```


# Filenames #

We want to support any type of code wrapped in Markdown, so we'll make no assumptions about the filename and extension preceding the Markdown .md extension and pass it through unmodified for use as the output filename of the compiled code.

```bash
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
```

We also need the ability to test a filename to see if it matches the conventions we're assuming for literate programming, which is to say, we need to ensure that it both has double extensions to signify a programming language wrapped in Markdown and also ends with .md as the second extension.

```bash
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
```

# awk

The bulk of the logic here is performed by [awk](https://www.gnu.org/software/gawk/manual/gawk.html), specifically a lightly modified and needlessly verbose version of [Rich Traube](https://github.com/trauber)'s clever [one-line routine](https://gist.github.com/trauber/4955706) which counts lines based on the [fenced code blocks](https://help.github.com/articles/creating-and-highlighting-code-blocks/) of [GitHub-Flavored Markdown](https://github.github.com/gfm/).

The awk command is assembled in Bash as a string, with a few slight modifications made based on the input arguments which determine whether the Markdown content will be commented out using specified delimiters or stripped entirely. This string will later be run by awk in a subshell.

```bash
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
```

# Parse Markdown Lines #

Call the awk command on the input.

```bash
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
```

# Compile A Single File #

Wrap the awk command and the filename logic into a single function which can be called on any file to compile its output.

```bash
# routine to compile a single file
process_file() {
  local file
  local content
  local new_filename
  local compiled
  # first argument is filename
  file=${1}
  # convert to the new filename
  if [ ! -z "${output_directory}" ]; then
    new_filename="${output_directory}"/$(basename $(remove_extension "${file}"))
  else
    new_filename=$(remove_extension "${file}")
  fi
  content="$(less "${file}")"
  # parse file content and remove Markdown comments
  compiled="$(process_lines "${content}")"
  start=${SECONDS}
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
```

# Execution #

Create the output directory if it doesn't already exist.

```bash
if [ ! -z "${output_directory}" ] && [ ! -d "${output_directory}" ]; then
  mkdir -p "${output_directory}"
fi
```

# Loop Through Files #

For each file, test the filename to see if it looks like a literate code file, and if so, compile it.

```bash
# if stdio isn't enabled
if [ "${stdio}" -eq 0 ]; then
  
  # loop through files
  if [ "${verbose}" -eq 1 ]; then
    echo "compiling $(echo "$(ls ${files})" | wc -l) files in ${files}"
  fi
  for file in $(ls ${files})
  do
    # make sure it's a literate code file
    if test_filename "${file}"; then
      # compile
      process_file "${file}"
    fi
  done
```

# stdio

Alternately, read from stdin and echo the output.

```bash
# if stdio is enabled
elif [ "${stdio}" -eq 1 ]; then
  # process stdin to stdout
  content="$(</dev/stdin)"
  echo "$(process_lines "${content}")"
fi
```