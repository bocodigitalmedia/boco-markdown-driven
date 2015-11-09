describe "JasmineCoffeeParser", ->

  [parser] = []

  beforeEach ->
    parser = new (require("boco-mdd").JasmineCoffeeParser)

  describe "Parsing Jasmine tokens", ->

    [parsed] = []

    beforeEach ->
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

    it "generated coffeescript", (done) ->
      l = lines = parsed.split("\n")

      expect(l.shift()).toEqual('describe "Mather", ->')
      expect(l.shift()).toEqual('')
      expect(l.shift()).toEqual('  [mather, Mather] = []')
      expect(l.shift()).toEqual('')
      expect(l.shift()).toEqual('  beforeEach ->')
      expect(l.shift()).toEqual('    mather = new Mather')
      expect(l.shift()).toEqual('')
      expect(l.shift()).toEqual('  describe "Adding numbers", ->')
      expect(l.shift()).toEqual('')
      expect(l.shift()).toEqual('    [a, b] = []')
      expect(l.shift()).toEqual('')
      expect(l.shift()).toEqual('    beforeEach ->')
      expect(l.shift()).toEqual('      [a, b] = [1, 2]')
      expect(l.shift()).toEqual('')
      expect(l.shift()).toEqual('    it "adds two numbers", (done) ->')
      expect(l.shift()).toEqual('      expect(mather.add a, b).toEqual(3)')
      expect(l.shift()).toEqual('      done()')
      expect(l.shift()).toEqual('')
      expect(l.shift()).toEqual(undefined)
      done()
