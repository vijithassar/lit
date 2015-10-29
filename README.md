# lit

a little preprocessor for literate programming

# Overview #

[Literate programming](https://en.wikipedia.org/wiki/Literate_programming) is the increasingly sensible idea popularized by Donald Knuth that source code should be written and/or richly annotated for clarity to human readers instead of mercilessly optimized for computing efficiency. This script is a tiny text preprocessor based on [bash](https://www.gnu.org/software/bash/) and [awk](https://en.wikipedia.org/wiki/AWK) which allows you to write all your source code in [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown/) with beautiful rich annotations (links! pictures! whatever!) and then quickly send the content of the Markdown code blocks into parallel code-only files.

# Installation?!? #

Feel free to clone this repository, but you can also just download [the script](lit.sh). It is self contained and there are no dependencies beyond bash and awk.

# Usage #

To compile literate source code, just... run the script.

```bash
# compile the current directory
$ ./lit.sh
```

The script takes one optional argument, which is a UNIX file pattern. If you don't supply one, it will compile any Markdown files it finds in the current directory.

```bash
# compile files in the src directory
$ ./lit.sh ./src/*
```

In addition to your file pattern, filenames must contain two extensions in order for the compiler to operate on them. The first should be the regular extension for the language you're compiling to, and the second.

For example, these filenames would be compiled:

- myscript.js.md
- some_program.py.md

These will not be compiled:

- myscript.js
- README.md

# Miscellaneous #

This lil guy:

- was deeply inspired by [Literate CoffeeScript](http://coffeescript.org/#literate)
- aims to be much simpler than the powerful [Node.js literate-programming compiler](https://github.com/jostylr/literate-programming)
- uses GitHub-style ["fenced code blocks"](https://help.github.com/articles/github-flavored-markdown/#fenced-code-blocks) delimited with backticks instead of the space-driven notation used by [traditional Markdown](https://daringfireball.net/projects/markdown/)
- is almost entirely based on [Rich Traube's one-liner for awk](https://gist.github.com/trauber/4955706); I've just added a few convenience wrappers
- will probably break function folding in your code editor of choice
- could theoretically implement source maps for JavaScript and CSS but hasn't yet bothered because equivalents aren't possible for all the other languages you might write with it
- is minimalist and will remain that way so it can be an unobtrusive part of other your other build processes
- is itself written with [heavily annotated source code](https://github.com/vijithassar/lit/blob/master/lit.sh.md) and [recursively compiles itself](https://github.com/vijithassar/lit/commit/1bf289c056a156fca7da281ed6237578cd68534d), which is ridiculous and a huge pain in the ass but it's too late now
