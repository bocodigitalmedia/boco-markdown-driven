# boco-markdown-driven

Turn markdown documents into runnable specs/tests for your project.

```coffee
MarkdownDriven = require 'boco-markdown-driven'
```

## Parser

``` coffee
parser = new MarkdownDriven.Parser
  nativeLanguages: ["coffee", "coffeescript"]
  assertionCodePattern: /\b(assert|expect|should)\b/
  fileCodePattern: /^.* file: "([^"]*)"/
```

* `nativeLanguages`<br>
   an array of languages to treat as native (specified by fenced code blocks in markdown)

* `assertionCodePattern`<br>
  a regex pattern to test if a markdown code block should be treated as an assertion

* `fileCodePattern`<br>
  a regex pattern to test if a markdown code block should be treated as a file

## Generator

``` coffee
JasmineCoffeeGenerator = require 'boco-mdd-jasmine-coffee-generator'
generator = new JasmineCoffeeGenerator
```

## Compiler

``` coffee
compiler = new MarkdownDriven.Compiler
  parser: parser
  generator: generator
```

### Compiling

``` coffee
result = compiler.compile markdown
```
