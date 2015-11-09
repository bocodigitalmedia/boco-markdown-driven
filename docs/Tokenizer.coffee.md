## Tokenizer

Parses markdown into the tokens needed to build specs.

    MarkDownDriven = require "boco-markdown-driven"
    tokenizer = new MarkDownDriven.Tokenizer

### Tokenizing Markdown

Let's take a look at the results of tokenizing some markdown.

    markdown =
      """
      # Mather

      Mather is a library for doing math.

          Mather = require "mather"

      Let's create a Mather:

          mather = new Mather

      ## example: adding numbers

          mather.add a, b # => 3
          mather.add c, d # => 7
      """

    tokens = tokenizer.tokenize markdown

#### example: a heading is a context token

The heading `# Mather` becomes a context token with a depth of 1.

    tokens[0].type # => "context"
    tokens[0].depth # => 1
    tokens[0].text # => "Mather"

#### example: code is a code token

The code within the `# Mather` section gets tokenized as follows:

    tokens[1].type # => "code"

    lines = tokens[1].text.split "\n"
    lines[0] # => 'Mather = require "mather"'
    lines[1] # => 'mather = new Mather'

#### example: a heading, starting with "example" is an example token

The heading `## example: ...` becomes an example token with a depth of 2.

    tokens[2].type # => "example"
    tokens[2].depth # => 2
    tokens[2].text # => "example: adding numbers"

#### example: code sections within examples are still just code tokens

The code within the example is still a code token.

    tokens[3].type # => "code"
    tokens[3].text[0...22] # => 'mather.add a, b # => 3'
