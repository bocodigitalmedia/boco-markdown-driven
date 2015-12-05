
# boco-mdd-jasmine-coffee
![npm version](https://img.shields.io/npm/v/boco-mdd-jasmine-coffee.svg)
![npm license](https://img.shields.io/npm/l/boco-mdd-jasmine-coffee.svg)
![dependencies](https://david-dm.org/bocodigitalmedia/boco-mdd-jasmine-coffee.png)

Jasmine + CoffeeScript generator for [boco-markdown-driven].

* [Installation](#installation)
* [Using the CLI](#using-the-cli)
* [Using the API](#using-the-api)

## Installation

Install both this library and [boco-markdown-driven] via [npm]:

```sh
$ npm install boco-mdd-jasmine-coffee boco-markdown-driven
```

## Using the CLI

Create a configuration file called `markdown-driven.json`:

```js
// file: "markdown-driven.json"
{
  "generator": "boco-mdd-jasmine-coffee",
  "parserOptions": {
    "nativeLanguages": ["coffee", "coffeescript"],
    "assertionCodePattern": /\bexpect\b/
  },
  "converterOptions": {
    "readDir": "docs",
    "writeDir": "spec",
    "writeExt": ".spec.coffee"
  }
}
```

Run the CLI:

```sh
$ boco-markdown-driven -c markdown-driven.json "docs/**/*.coffee.md"
```

See the CLI documentation on [boco-markdown-driven] for more information.

## Using the API

_note: you can view the example markdown and coffeescript files at the end of this section_

```coffee
JasmineCoffee = require 'boco-mdd-jasmine-coffee'
MarkdownDriven = require 'boco-markdown-driven'

generator = new JasmineCoffee.Generator
compiler = new MarkdownDriven.Compiler generator: generator
```

The compiler will now generate jasmine specs for your markdown:

``` coffee
compiled = compiler.compile $files['example.md']
expect(compiled).toEqual $files['example.spec.coffee']
```

---

```markdown
<!-- file: "example.md" -->
# Mather

Mather is a library for doing Math.

    Mather = require "mather"
    mather = new Mather

## Adding numbers

It adds two numbers:

    mather.add 2, 2, (error, result) ->
      throw error if error?
      expect(result).toEqual 4
      ok()

It adds more than two numbers:

    mather.add 3, 4, 5, (error, result) ->
      throw error if error?
      expect(result).toEqual 12
      ok()
```

```coffee
# file: "example.spec.coffee"
$files = null

describe "Mather", ->
  [Mather, mather] = []

  beforeEach ->
    Mather = require "mather"
    mather = new Mather

  describe "Adding numbers", ->

    it "It adds two numbers:", (ok) ->
      mather.add 2, 2, (error, result) ->
        throw error if error?
        expect(result).toEqual 4
        ok()

    it "It adds more than two numbers:", (ok) ->
      mather.add 3, 4, 5, (error, result) ->
        throw error if error?
        expect(result).toEqual 12
        ok()
```

## An empty context with before each

    console.log("do something here")

[boco-markdown-driven]: https://github.com/bocodigitalmedia/boco-markdown-driven
[npm]: https://npmjs.org

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
