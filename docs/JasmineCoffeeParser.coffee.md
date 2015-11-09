# JasmineCoffeeParser

Parses tokens from the JasmineConverter and outputs coffeescript "specs" for Jasmine.

    parser = new (require("boco-mdd").JasmineCoffeeParser)

## Parsing Jasmine tokens

Let's take a look at the coffeescript generated from the following tokens:

    parsed = parser.parse [
      { type: "describe", depth: 1, text: "Mather" },
      { type: "vars", depth: 2, vars: ['mather', 'Mather', 'a', 'b'] },
      { type: "beforeEach", depth: 2, code: 'mather = new Mather' },
      { type: "it", depth: 2, text: "adds two numbers" },
      { type: "assertion", depth: 3, code: 'mather.add a,b # => 3' }
    ]

### example: generated coffeescript

    l = lines = parsed.split("\n")

The describe token parses to a Jasmine describe block:

    l[ 0] # => 'describe "Mather", ->'
    l[ 1] # => '  '

The vars are output before the 'beforeEach' block so that they
are accessible by all child describes/its:

    l[ 2] # => '  [mather, Mather, a, b] = []'
    l[ 3] # => '  '

Note that each 'beforeEach' block is assigned a 'done' callback,
and that 'done()' is called at the end of the block.

    l[ 4] # => '  beforeEach (done) ->'
    l[ 5] # => '    mather = new Mather'
    l[ 6] # => '    done()'
    l[ 7] # => '  '

The same applies to 'it' blocks. In addition, assertion comments `# =>`
become jasmine expectations.

    l[ 8] # => '  it "adds two numbers", (done) ->'
    l[ 9] # => '    expect(mather.add a,b).toEqual(3)'
    l[10] # => '    done()'
    l[11] # => ''
