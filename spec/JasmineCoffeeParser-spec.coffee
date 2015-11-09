describe "JasmineCoffeeParser", ->
  
  [parser] = []
  
  beforeEach (done) ->
    parser = new (require("boco-mdd").JasmineCoffeeParser)
    done()
  describe "Parsing Jasmine tokens", ->
    
    [parsed] = []
    
    beforeEach (done) ->
      parsed = parser.parse [
        { type: "describe", depth: 1, text: "Mather" },
        { type: "vars", depth: 2, vars: ['mather', 'Mather', 'a', 'b'] },
        { type: "beforeEach", depth: 2, code: 'mather = new Mather' },
        { type: "it", depth: 2, text: "adds two numbers" },
        { type: "assertion", depth: 3, code: 'mather.add a,b # => 3' }
      ]
      done()
    
    it "foo", (done) ->
      lines = parsed.split("\n")
      
      expect(lines.shift()).toEqual('describe "Mather", ->')
      expect(lines.shift()).toEqual('  ')
      expect(lines.shift()).toEqual('  [mather, Mather, a, b] = []')
      expect(lines.shift()).toEqual('  ')
      expect(lines.shift()).toEqual('  beforeEach (done) ->')
      expect(lines.shift()).toEqual('    mather = new Mather')
      expect(lines.shift()).toEqual('    done()')
      expect(lines.shift()).toEqual('  ')
      expect(lines.shift()).toEqual('  it "adds two numbers", (done) ->')
      expect(lines.shift()).toEqual('    expect(mather.add a,b).toEqual(3)')
      expect(lines.shift()).toEqual('    done()')
      expect(lines.shift()).toEqual('')
      done()
