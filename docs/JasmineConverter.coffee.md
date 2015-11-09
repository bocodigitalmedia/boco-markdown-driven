# Jasmine Converter

Converts tokens from a generic format to one suitable for Jasmine specs.

    MarkDownDriven = require "boco-mdd"
    converter = new MarkDownDriven.JasmineConverter

## Converting

### Converting context/code tokens

    tokens = [
      { type: "context", depth: 1, text: "Mather" }
      { type: "code", text: 'mather = new Mather' }
      { type: "code", text: '[a,b] = [1,2]' }
    ]

    converted = converter.convert tokens

#### example: the first context/code pair converted

    converted.shift() # => { type: 'describe', depth: 1, text: 'Mather' }
    converted.shift() # => { type: 'vars', depth: 2, vars: ['mather', 'Mather'] }
    converted.shift() # => { type: 'beforeEach', depth: 2, code: 'mather = new Mather' }
    converted.shift() # => { type: 'vars', depth: 2, vars: ['a', 'b'] }
    converted.shift() # => { type: 'beforeEach', depth: 2, code: '[a,b] = [1,2]' }

### Converting example/code tokens

    tokens = [
      { type: "example", depth: 3, text: "example: adding two numbers" },
      { type: "code", text: 'mather.add a,b # => 3' }
    ]

    converted = converter.convert tokens

#### example: converted example/code tokens

    converted.shift() # => { type: 'it', depth: 3, text: 'adding two numbers' }
    converted.shift() # => { type: 'assertion', depth: 4, code: 'mather.add a,b # => 3' }
