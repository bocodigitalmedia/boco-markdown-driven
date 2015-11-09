# Jasmine Converter

Converts tokens from a generic format to one suitable for Jasmine specs.

    MarkdownDriven = require "boco-mdd"
    converter = new MarkdownDriven.JasmineConverter

## Converting context/code tokens

    converted = converter.convert [
      { type: "context", depth: 1, text: "Mather" }
      { type: "code", text: 'mather = new Mather' }
    ]

### example: converted context/code tokens

The converted context token now represents a jasmine "describe" block:

    converted.shift() # => { type: 'describe', depth: 1, text: 'Mather' }

A code block gets converted into a pair of "vars" and "beforeEach" tokens:

    converted.shift() # => { type: 'vars', depth: 2, vars: ['mather', 'Mather'] }
    converted.shift() # => { type: 'beforeEach', depth: 2, code: 'mather = new Mather' }

## Converting example/code tokens

    converted = converter.convert [
      { type: "example", depth: 3, text: "example: adding two numbers" },
      { type: "code", text: 'mather.add a,b # => 3' }
    ]

### example: converted example/code tokens

The example token gets converted to an "it" token

    converted.shift() # => { type: 'it', depth: 3, text: 'adding two numbers' }

The code token gets converted to an assertion

    converted.shift() # => { type: 'assertion', depth: 4, code: 'mather.add a,b # => 3' }


## Specifying Global Variables

    converter.globalVariables.push "foo", "bar"

    converted = converter.convert [
      { type: "context", depth: 1, text: "Test globals" },
      { type: "code", text: "[a,b,c,foo,bar] = [1,2,3,4,5]" }
    ]

### example: global variables are not initialized

    converted.shift() # the "describe" token here
    converted.shift() # => { type: 'vars', depth: 2, vars: ['a', 'b', 'c'] }
