# boco-markdown-driven

[![Join the chat at https://gitter.im/bocodigitalmedia/boco-markdown-driven](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/bocodigitalmedia/boco-markdown-driven?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

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

--------------------------------------------------------------------------------

The MIT License (MIT)

Copyright (c) 2015 Christian Bradley, Boco Digital Media, LLC 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

