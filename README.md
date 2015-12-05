# boco-markdown-driven

![npm version](https://img.shields.io/npm/v/boco-markdown-driven.svg)
![npm license](https://img.shields.io/npm/l/boco-markdown-driven.svg)
![dependencies](https://david-dm.org/bocodigitalmedia/boco-markdown-driven.png)
[![join chat](https://badges.gitter.im/Join%20Chat.svg)]( https://gitter.im/bocodigitalmedia/boco-markdown-driven)

Convert markdown documents into runnable specs/tests for your project.


## Table of Contents

* [Installation]
* [Overview]
* [Generators]
  * [Available Generators]
  * [Write a Generator]
* [Usage]
  * [Using the API]
  * [Using the CLI]


## Installation

Install via [npm]:

``` sh
$ npm install boco-markdown-driven
```


## Overview

This library provides the following main components:

* `Parser` - parses markdown tokens into a `ParseTree` representing a specification
* `Compiler` - compiles markdown source to a specification format
* `Converter` - reads markdown files, compiles, and writes specification files
* `CLI` - command line interface

This library does not include a `Generator`. You should install one of the [available generators], or [write a generator] for your language and test framework.


## Generators

Generators consume a `ParseTree` and generate specification code for a given language and framework (ie: jasmine/coffee).


### Available Generators

 generator                  | framework    | language   | Notes
:---------------------------|:-------------|:-----------|:------
 [boco-mdd-jasmine-coffee]  | jasmine      | coffee     |
 boco-mdd-jasmine-js        | jasmine      | js         | coming soon
 boco-mdd-mocha-coffee      | mocha        | coffee     | coming soon
 boco-mdd-mocha-js          | mocha        | js         | coming soon


### Write a Generator

Your generator class should have a single `generate` method that consumes a `ParseTree` and outputs specification code.

Take a look at the source for one of the [available generators] for more information.

If you have written a generator, please contact us to add it to the list.


## Usage

```coffee
MarkdownDriven = require "boco-markdown-driven"
MDDJasmineCoffee = require "boco-mdd-jasmine-coffee"
```


### Using the API

Create a `parser` and a `generator`, then use them to construct a `compiler`:

```coffee
parser = new MarkdownDriven.Parser nativeLanguages: ["coffee"]
generator = new MDDJasmineCoffee.Generator

compiler = new MarkdownDriven.Compiler
  parser: parser
  generator: generator
```

Compile markdown into testable source code:

```coffee
compiler.compile "# Mather..." # => "describe 'Mather' -> ..."
```


### Using the CLI

Create a configuration file and pass it to the CLI:

```sh
# compile all .md files in {readDir}
$ markdown-driven -c ./markdown-driven.json "**/*.md"

# get help
$ markdown-driven --help

# local installation
$ ./node_modules/.bin/markdown-driven --help
```

```js
// file: "markdown-driven.json"
{
  // require this generator
  "generator": "boco-mdd-jasmine-coffee",

  // marked lexer constructor options
  // see: https://github.com/chjj/marked
  "lexerOptions": {
    "gfm": true
  },

  // parser constructor options
  "parserOptions": {
    "nativeLanguages": ["coffee"]
  },

  // generator constructor options
  "generatorOptions": null,

  // converter options
  "converterOptions": {
    "readDir": "docs",
    "writeDir": "spec",
    "writeExt": ".spec.coffee"
  }
}
```


[installation]: #installation
[overview]: #overview
[usage]: #usage
[using the api]: #using-the-api
[using the cli]: #using-the-cli
[generators]: #generators
[available generators]: #available-generators
[write a generator]: #write-a-generator

[npm]: https://npmjs.org
[boco-mdd-jasmine-coffee]: https://github.com/bocodigitalmedia/boco-mdd-jasmine-coffee

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

