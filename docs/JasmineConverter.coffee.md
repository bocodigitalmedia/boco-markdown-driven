# Jasmine Converter

Converts tokens from a generic format to one suitable for Jasmine specs.

    MarkDownDriven = require "boco-mdd"
    converter = new MarkDownDriven.JasmineConverter

## Converting context/code tokens

    converted = converter.convert [
      { type: "context", depth: 1, text: "Mather" }
      { type: "code", text: 'mather = new Mather' }
      { type: "code", text: '[a,b] = [1,2]' }
    ]

### example: converted context/code tokens

The converted context token now represents a jasmine "describe" block:

    converted.shift() # => { type: 'describe', depth: 1, text: 'Mather' }

A code block gets converted into a pair of "vars" and "beforeEach" tokens:

    converted.shift() # => { type: 'vars', depth: 2, vars: ['mather', 'Mather'] }
    converted.shift() # => { type: 'beforeEach', depth: 2, code: 'mather = new Mather' }

Additional code blocks also get converted into vars/beforEach pairs:

    converted.shift() # => { type: 'vars', depth: 2, vars: ['a', 'b'] }
    converted.shift() # => { type: 'beforeEach', depth: 2, code: '[a,b] = [1,2]' }

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
