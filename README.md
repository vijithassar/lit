# lit

a little preprocessor for literate programming

![fire](https://cloud.githubusercontent.com/assets/3488572/10808206/272feea0-7dbf-11e5-8d49-f6134a900530.png)

# Overview #

[Literate programming](https://en.wikipedia.org/wiki/Literate_programming) is the increasingly sensible idea popularized by Donald Knuth that source code should be written and/or richly annotated for clarity to human readers instead of mercilessly optimized for computing efficiency. This script is a tiny text preprocessor based on [bash](https://www.gnu.org/software/bash/) and [awk](https://en.wikipedia.org/wiki/AWK) which allows you to write all your source code in [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown/) with beautiful rich annotations (links! pictures! whatever!) and then quickly send the content of the Markdown code blocks into parallel code-only files. For a quick illustration, compare the [annotated source](hello-world.js.md) of the included hello-world script to its [compiled output](hello-world.js).

# Installation?!? #

Feel free to clone this repository, but you can also just [download the script](lit.sh). It is self contained and there are no dependencies beyond bash and awk, which you almost certainly already have.

# Usage #

To compile literate source code, simply run the script.

```bash
# compile literate code files
$ ./lit.sh
```

The script takes one optional argument, which is a UNIX file pattern. If you don't supply one, it will compile any Markdown files it finds in the current directory.

```bash
# compile literate code files in the current directory
$ ./lit.sh

# compile literate code files in the src subdirectory
$ ./lit.sh ./src/*
```

In addition to your file pattern, filenames must contain two extensions in order for the compiler to operate on them. The first should be the regular extension for the language you're compiling to, and the second should be the Markdown .md extension.

For example, these filenames would be compiled:

- myscript.js.md
- some_program.py.md

These would not be compiled:

- myscript.js
- README.md

# Advantages #

- This script will work with any language.
- If you write your code this way, your software documentation will be great.
- Unlike most other literate programming tools, this script is transparently backwards compatible with non-literate code. To start literate programming with any file in a project, copy the original file, append the .md extension, add backticks at the top and bottom of the file, and then you're ready to start working in Markdown. Compiled changes will overwrite the original file and thus will be properly tracked by version control systems like Git.
- More complex literate programming tools introduce the possibility of control flow using language instead of code, which means the program cannot function without the compiler. This script has linear output, which means you can also brute-force compile it simply by manually deleting the Markdown. In the unlikely event that you both decide literate programming isn't for you *and* can no longer access this script, you can still quickly extract all your code with a little elbow grease.

# Disadvantages #

- This will probably [break function folding](https://github.com/atom/atom/issues/8879) in your code editor of choice.
- Line numbers in the source will differ from line numbers reported by debuggers. Source maps would solve this problem for JavaScript and CSS, but haven't yet been implemented because unfortunately equivalents don't exist for all the other languages you might write.

# Pedantry #

This isn't quite true to the original conception of literate programming, which particularly advocated for nonlinear compiling so source code can be structured for humans and then reorganized for execution.

However:

- Most modern programming languages mitigate the importance of this feature by allowing functions and objects to be defined in memory fairly freely and then executed later.
- Nonlinear compiling introduces an irreversible dependency on the compiler; the nonlinear logic added by the literate programming tool effectively becomes part of the application code.
- If you really want nonlinear compiling, you are free to implement it in your build process by using [grunt-concat](https://github.com/gruntjs/grunt-contrib-concat) or similar – that is, it is still possible using this tool if you just use separate files for each block and concatenate elsewhere. You may not like the idea of making your build process part of your application logic, but that's not actually so different from doing the same using your literate programming tool.

# Miscellaneous #

This lil guy:

- was deeply inspired by [Literate CoffeeScript](http://coffeescript.org/#literate)
- aims to be much simpler than the powerful [Node.js literate-programming compiler](https://github.com/jostylr/literate-programming)
- uses GitHub-style ["fenced code blocks"](https://help.github.com/articles/github-flavored-markdown/#fenced-code-blocks) delimited with backticks instead of the space-driven notation used by [traditional Markdown](https://daringfireball.net/projects/markdown/)
- is almost entirely based on [Rich Traube's one-liner for awk](https://gist.github.com/trauber/4955706); I've just added a few convenience wrappers
- is minimalist and will remain that way so it can be an unobtrusive part of other your other build processes
- is itself written with [heavily annotated source code](https://github.com/vijithassar/lit/blob/master/lit.sh.md) and [recursively compiles itself](https://github.com/vijithassar/lit/commit/3434fd18772bec44c19a191bb5592624844de255), which is ridiculous and a huge pain in the ass but it's too late now!
