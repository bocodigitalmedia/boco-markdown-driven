# JasmineCoffeeParser

Parses tokens from the JasmineConverter and outputs coffeescript "specs" for Jasmine.

    parser = new (require("boco-markdown-driven").JasmineCoffeeParser)

## Parsing Jasmine tokens

Let's take a look at the coffeescript generated from the following tokens:

    parsed = parser.parse [
      { type: "describe", depth: 1, text: "Mather" },
      { type: "vars", depth: 2, vars: ['mather', 'Mather'] },
      { type: "beforeEach", depth: 2, code: 'mather = new Mather' },
      { type: "describe", depth: 2, text: "Adding numbers" },
      { type: "vars", depth: 3, vars: ['a', 'b'] },
      { type: "beforeEach", depth: 3, code: '[a, b] = [1, 2]' },
      { type: "it", depth: 3, text: "adds two numbers" },
      { type: "assertion", depth: 4, code: 'mather.add a, b # => 3' }
    ]

### example: generated coffeescript

    l = lines = parsed.split("\n")

    l.shift() # => 'describe "Mather", ->'
    l.shift() # => ''
    l.shift() # => '  [mather, Mather] = []'
    l.shift() # => ''
    l.shift() # => '  beforeEach ->'
    l.shift() # => '    mather = new Mather'
    l.shift() # => ''
    l.shift() # => '  describe "Adding numbers", ->'
    l.shift() # => ''
    l.shift() # => '    [a, b] = []'
    l.shift() # => ''
    l.shift() # => '    beforeEach ->'
    l.shift() # => '      [a, b] = [1, 2]'
    l.shift() # => ''
    l.shift() # => '    it "adds two numbers", (done) ->'
    l.shift() # => '      expect(mather.add a, b).toEqual(3)'
    l.shift() # => '      done()'
    l.shift() # => ''
    l.shift() # => undefined
