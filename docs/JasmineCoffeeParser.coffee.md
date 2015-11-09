# JasmineCoffeeParser

Parses tokens from the JasmineConverter and outputs coffeescript "specs" for Jasmine.

    parser = new (require("boco-mdd").JasmineCoffeeParser)

## Parsing Jasmine tokens

    parsed = parser.parse [
      { type: "describe", depth: 1, text: "Mather" },
      { type: "vars", depth: 2, vars: ['mather', 'Mather', 'a', 'b'] },
      { type: "beforeEach", depth: 2, code: 'mather = new Mather' },
      { type: "it", depth: 2, text: "adds two numbers" },
      { type: "assertion", depth: 3, code: 'mather.add a,b # => 3' }
    ]

### example: foo

    lines = parsed.split("\n")

    lines.shift() # => 'describe "Mather", ->'
    lines.shift() # => '  '
    lines.shift() # => '  [mather, Mather, a, b] = []'
    lines.shift() # => '  '
    lines.shift() # => '  beforeEach (done) ->'
    lines.shift() # => '    mather = new Mather'
    lines.shift() # => '    done()'
    lines.shift() # => '  '
    lines.shift() # => '  it "adds two numbers", (done) ->'
    lines.shift() # => '    expect(mather.add a,b).toEqual(3)'
    lines.shift() # => '    done()'
    lines.shift() # => ''
    
