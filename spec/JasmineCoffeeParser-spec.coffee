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
    
    it "generated coffeescript", (done) ->
      l = lines = parsed.split("\n")
      done()
      expect(l[ 0]).toEqual('describe "Mather", ->')
      expect(l[ 1]).toEqual('  ')
      done()
      expect(l[ 2]).toEqual('  [mather, Mather, a, b] = []')
      expect(l[ 3]).toEqual('  ')
      done()
      expect(l[ 4]).toEqual('  beforeEach (done) ->')
      expect(l[ 5]).toEqual('    mather = new Mather')
      expect(l[ 6]).toEqual('    done()')
      expect(l[ 7]).toEqual('  ')
      done()
      expect(l[ 8]).toEqual('  it "adds two numbers", (done) ->')
      expect(l[ 9]).toEqual('    expect(mather.add a,b).toEqual(3)')
      expect(l[10]).toEqual('    done()')
      expect(l[11]).toEqual('')
      done()
