# Startup #

The shebang indicates that this script should be executed by the bash program.

```bash
#!/bin/bash

```

# Filenames #

We want to support any type of code wrapped in Markdown, so we'll make no assumptions about the filename and extension preceding it and pass it through unmodified for use as the output filename.

```bash
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
```

We also need the ability to test a filename to see if it matches the conventions we're assuming for literate programming, which is to say, we need to ensure that it has. (See what's going on? We're grouping this code along with the other filename parsing logic even though we actually use it in the main execution loop. This, right here, is literate programming!)

```bash
# make sure a filename is safe to process
function test_filename {
  # first argument is the filename to test
  local file_path=$1
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
```

# Parse Markdown Lines #

This function uses a needlessly verbose version of [Rich Traube](https://github.com/trauber)'s clever [one-line awk routine](https://gist.github.com/trauber/4955706) to walk through the lines in the Markdown document and pass them into the output file as appropriate.

```bash
# strip Markdown
function process_lines {
  # first argument is filename
  local file=$1
  # iterate through lines with awk
  local awk_command='
      # if it is a code block
      if (/^```/) {
        # increase backtick counter
        i++;
        # jump to next command
        next;
      }
      # print
      if ( i % 2 == 1) {
        print;
      }
  '
  # run awk command
  local processed=$(awk {"$awk_command"} $file)
  # return code blocks only
  echo "$processed"
}
```

# Compile A Single File #

Wrap the awk routine and the filename logic into a single function which can be called on any file to compile its output.

```bash
# compile Markdown code blocks in a file using awk
function compile {
  # first argument is filename
  local file=$1
  # conver to the new filename
  local new_filename=$(remove_extension $file "md")
  # log message
  echo "compiling $file > $new_filename"
  # parse file content and remove Markdown comments
  local compiled=$(process_lines $file)
  # save results to file
  echo "$compiled" > $new_filename
}
```

# Input Argument #

Everything up until this point has been wrapped in a reusable function, but now it's time to define the script logic.

First, grab the files specified by an optional filename pattern (or alternatively the files in the current working directory).

```bash
# if the first argument exists, use it as the
# target directory
if [ $1 ]; then
  files=$1
# otherwise load all files in current directory
else
  files=.
fi
```

For each file, test the filename to see if it looks like a literate code file. If it does, compile it.

```bash
# loop through files
for file in $files
do
  # make sure it's a literate code file
  if test_filename $file; then
    # compile
    compile $file
  fi
done
```
