# A Simple Example

This is a basic example of how literate programming works. It's written in Ruby, which uses the [puts](https://ruby-doc.org/core-2.1.3/IO.html#method-i-puts) method to **put** a **s**tring in the terminal.

You can write whatever you want here using any Markdown or HTML. When you're ready to start coding, just open up a code block by typing three backticks:

```ruby
puts 'hello world!'
```

When you run the [preprocessing script](lit.sh) as described in the [README.md](instructions), it will strip away all this explanatory material and create a new file consisting of [only the code sections](hello-world.rb).

```ruby
puts ':D'
```