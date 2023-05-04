# lit

a little preprocessor for literate programming

![fire](https://cloud.githubusercontent.com/assets/3488572/10808206/272feea0-7dbf-11e5-8d49-f6134a900530.png)

inverts code and comments in any language to make a codebase **documentation-first**

# Quick Start

By default, extracts code from Markdown files:

```bash
# strip out Markdown content from literate programming
# files in the current directory, leaving only
# executable code in parallel files
$ ./lit.sh
```

Alternatively, and **highly recommended** for development purposes, you can just *comment out* the Markdown, thereby preserving the original line numbers for more accurate debugging:

```bash
# comment out Markdown content from literate programming
# files in the current directory with hash style inline
# comments as used in e.g. Python, Ruby, or Bash
$ ./lit.sh --before "#"
```

As above, but also *immediately execute* the code in a Markdown file:

```bash
# use Python to execute the fenced code blocks inside script.py.md
$ python $(./lit.sh --input "script.py.md" --before "#")
```

# Overview #

[Literate programming](https://en.wikipedia.org/wiki/Literate_programming) is the delightful idea popularized by Donald Knuth that source code should be written and/or richly annotated for clarity to human readers instead of mercilessly optimized for computing efficiency. One easy way to move in this direction is to write your source code into Markdown documents, with the code set aside in Markdown code blocks sprinkled throughout the written explanations. This inverts the usual relationship between code and comments: everything is assumed to be a comment until a special delimiter for marking the code is found, instead of the other way around as with most source code. In addition, your documentation can then use links, pictures, diagrams, embeds, iframes, or anything else allowed in Markdown and HTML.

This script is a tiny text preprocessor built with [bash](https://www.gnu.org/software/bash/) and [awk](https://en.wikipedia.org/wiki/AWK) which allows you to write all your source code in [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown/) and then quickly send the content of the code blocks into parallel executable files. For a quick illustration, compare the [annotated source](hello-world.rb.md) of the included hello-world script to its [processed output](hello-world.rb).

# Installation?!? #

Feel free to clone this repository, but you can also just [download the script](lit.sh). It is self contained and there are no dependencies beyond bash and awk, which you almost certainly already have.

A one-liner for command line installation:

```bash
# install lit.sh
$ curl https://raw.githubusercontent.com/vijithassar/lit/master/lit.sh > lit.sh && chmod +x lit.sh
```

# Usage #

To compile literate source code, simply run the script. By default, it will process any Markdown files it finds in the current directory.

```bash
# compile literate code files
$ ./lit.sh
```

Filenames must contain **two extensions** in order for the script to operate on them. The first should be the regular extension for the language you're compiling to (`.py`, `.js`, etc), and the second should be the Markdown `.md` extension.

For example, these filenames would be processed:

- `myscript.js.md`
- `some_program.py.md`

These would not be processed:

- `myscript.js`
- `README.md`

## Arguments

### Input

The `--input` or `-i` arguments can be used to specify a path or file glob within which to find files to process. File globs must be quoted strings. If this argument is omitted, all literate code files in the current working directory will be processed.

```bash
# compile literate code files in the ./source directory
$ ./lit.sh --input "./source"
```

```bash
# compile literate Python files in the ./source directory
$ ./lit.sh --input "./source/*.py.md"
```

### Output

The `--output` or `-o` arguments can be used to specify a path where the processed files will be written. If this argument is omitted, the processed files will be written in the same directory as the input files.

```bash
# compile literate code files in the current directory
# and write to the ./build directory
$ ./lit.sh --output ./build
```

```bash
# compile literate code files in the ./source directory
# and write to the current working directory
$ ./lit.sh --input "./source" --output .
```

### Comments

Rather than simply *stripping* Markdown content entirely, it can be advantageous to just *comment it out* instead, since that means all code in the output file appears on the same line as in the original literate Markdown source, and thus errors and messages can be accurately reported by debuggers, loggers, compilers, and other such development tools. To comment out Markdown content instead of stripping it, use the `--before` or `-b` arguments, followed by the character(s) used to denote inline code comments for the language you are compiling.

This is **definitely the recommended way to use this tool**, but it can't be the default behavior because you need to specify the inline comment delimiter for your language in order for it to work.

```bash
# comment out Markdown content from literate programming
# files in the current directory with hash style inline
# comments as used in e.g. Python, Ruby, or Bash
$ ./lit.sh --before "#"
```

You can also comment out Markdown content using a *block* commenting style by supplying the `--after` or `-a` arguments, followed by the characters used to denote the end of a block comment in the language you are compiling. However, inline comments are preferable, because block comments can be broken if any of your Markdown content includes the character sequence that denotes the end of a block comment. This option is included mostly to allow "literate CSS" files, since CSS does not have a single-line comment syntax.

```bash
# comment out Markdown content from "literate CSS" files
# in the current directory using block comment syntax
$ ./lit.sh --input "./*.css.md" --before "/*" --after "*/"
```

### Logging ###

As it processes files, the script echoes out the filenames of the resulting executable (non-Markdown) code files. If you want, you can capture these in a subshell and use them in further downstream logic, thereby totally abstracting away even the filename of the resulting processed code and creating a *completely documentation-first* workflow.

For example, to compile a single file, capture the filename with a subshell, and immediately execute the result:

```bash
# compile script.js.md to script.js and
# immediately execute with Node.js using a
# subshell
$ node $(./lit.sh --input "script.js.md" --before "//")
```

```bash
# compile script.py.md to script.py and
# immediately execute with Python using a
# subshell
$ python $(./lit.sh --input "script.py.md" --before "#")
```

Concise and subshell-friendly output is the most useful default, but you can also enable more verbose human-readable messages using the `--verbose` or `-v` arguments.

```bash
# compile all files in the current directory
# and output verbose log messages
$ ./lit.sh --verbose
```

Logging is naturally disabled when you use stdin or stdout with the `--stdio` or `-s` flags, in which case the printed output is the processed code.

### stdin and stdout

The `--stdio` or `-s` arguments can be used to read from stdin for the Markdown content to be processed and send the processed code content to stdout.

```bash
# compile annotated.py.md to code.py by routing over stdio
$ cat annotated.py.md | ./lit.sh --stdio > code.py
```

### Hidden Files ###

In addition, the `--hidden` or `-h` arguments can be used to prepend a dot `.` to the output filename. This is useful because files that start with a dot are hidden by default on most UNIX-like file systems. This behavior lets you hide the artifacts of compiling your Markdown into executable files.

For example, combining with subshells as described above:

```bash
# compile script.py.md to a hidden file and immediately execute it
$ python $(./lit.sh --input script.py.md --hidden)
```

If you're using Git, you may also want to add `script.js` or `script.py` to your `.gitignore` file in this scenario.

### Process Substitution ###

You can avoid the artifact of creating a hidden file by using [process substition](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html) to treat stdout as a file.

```bash
# compile script.py.md and execute the output
# with python as though it is a file
$ python <(cat script.py.md | ./lit.sh --stdio)
```

# Advantages #

- This script will work with any language.
- If you write your code this way, your software documentation will be great.
- Unlike most other literate programming tools, this script is transparently backwards compatible with non-literate code. To start literate programming with any file in a project, copy the original file, append the .md extension, add backticks at the top and bottom of the file, and then you're ready to start working in Markdown. Compiled changes will overwrite the original file and thus will be properly tracked by version control systems like Git.
- More complex literate programming tools introduce the possibility of control flow using language instead of code, which means the program cannot function without the compiler. This script has linear output, which means you can also brute-force compile it simply by manually deleting the Markdown. In the unlikely event that you both decide literate programming isn't for you *and* can no longer access this script, you can still quickly extract all your code with a little elbow grease.

# Disadvantages #

- This might [break function folding](https://github.com/atom/atom/issues/8879) if your code editor of choice assumes function structure is the same thing as indentation.

# Tests #

Unit tests are written with [bats](https://github.com/sstephenson/bats).

```bash
# run unit tests with bats
$ bats test.bats
```

# Ecosystem #

- [lit-web](https://github.com/vijithassar/lit-web) is a script that lets a browser execute the code blocks from a single Markdown document as JavaScript
- [lit-node](https://github.com/Rich-Harris/lit-node) is a wrapper for Node.js which lets Node execute Markdown files, import modules declared inside Markdown files using `require()`, and also provides a REPL
- [rollup-plugin-markdown](https://www.npmjs.com/package/rollup-plugin-markdown) implements essentially the same logic as this shell script, but it is optimized for JavaScript code, works with sourcemaps, integrates with a [popular build tool](https://rollupjs.org), and is [available via npm](https://www.npmjs.com/package/rollup-plugin-markdown)
- [Docco](http://ashkenas.com/docco/) and its many variants render literate source code into beautiful browsable HTML, in what is arguably the inverse complement to the operation performed by this script
- [Blaze](https://github.com/0atman/blaze) is a clever literate programming tool which optimizes for *execution* instead of *building*, allowing you to send Markdown files directly into any language of your choosing without any intermediate steps
- [CoffeeScript](http://coffeescript.org) and [Haskell](https://www.haskell.org/) support literate programming natively and do not need any additional tooling!

# Pedantry #

This isn't quite true to the original conception of literate programming, which also advocated for nonlinear compiling so source code can be structured for humans and then reorganized for execution.

However:

- Most modern programming languages mitigate the importance of this feature by allowing functions and objects to be defined in memory fairly freely and then executed later.
- Nonlinear compiling introduces an irreversible dependency on the compiler; the nonlinear logic added by the literate programming tool effectively becomes part of the application code.
- If you really want nonlinear compiling, you are free to implement it in your build process by using [grunt-concat](https://github.com/gruntjs/grunt-contrib-concat) or similar – that is, it is still possible using this tool if you just use separate files for each block and concatenate elsewhere. You may not like the idea of making your build process part of your application logic, but that's not actually so different from doing the same using your literate programming tool, now is it?

# Miscellaneous #

This lil guy:

- was deeply inspired by [Literate CoffeeScript](http://coffeescript.org/#literate)
- aims to be much simpler than the powerful [Node.js literate-programming compiler](https://github.com/jostylr/literate-programming)
- uses GitHub-style ["fenced code blocks"](https://help.github.com/articles/creating-and-highlighting-code-blocks/) delimited with triple backticks instead of the tab-driven notation used by [traditional Markdown](https://daringfireball.net/projects/markdown/)
- is based on a modified version of [Rich Traube's one-liner for awk](https://gist.github.com/trauber/4955706)
- is minimalist and will remain that way so it can be an unobtrusive part of other your other build processes
- is itself written with [heavily annotated source code](https://github.com/vijithassar/lit/blob/master/lit.sh.md) and [recursively compiles itself](https://github.com/vijithassar/lit/commit/3434fd18772bec44c19a191bb5592624844de255), which is ridiculous and a huge pain in the ass but it's too late now!
