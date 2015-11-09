describe "Jasmine Converter", ->

  [MarkDownDriven,converter] = []

  beforeEach (done) ->
    MarkDownDriven = require "boco-mdd"
    converter = new MarkDownDriven.JasmineConverter
  
    done()

  describe "Converting", ->

    describe "Converting context/code tokens", ->

      [tokens,converted] = []

      beforeEach (done) ->
        tokens = [
          { type: "context", depth: 1, text: "Mather" }
          { type: "code", text: 'mather = new Mather' }
          { type: "code", text: '[a,b] = [1,2]' }
        ]
        
        converted = converter.convert tokens
      
        done()

      it "the first context/code pair converted", (done) ->

        expect(converted.shift()).toEqual({ type: 'describe', depth: 1, text: 'Mather' })
        expect(converted.shift()).toEqual({ type: 'vars', depth: 2, vars: ['mather', 'Mather'] })
        expect(converted.shift()).toEqual({ type: 'beforeEach', depth: 2, code: 'mather = new Mather' })
        expect(converted.shift()).toEqual({ type: 'vars', depth: 2, vars: ['a', 'b'] })
        expect(converted.shift()).toEqual({ type: 'beforeEach', depth: 2, code: '[a,b] = [1,2]' })
        
        done()

    describe "Converting example/code tokens", ->

      [tokens,converted] = []

      beforeEach (done) ->
        tokens = [
          { type: "example", depth: 3, text: "example: adding two numbers" },
          { type: "code", text: 'mather.add a,b # => 3' }
        ]
        
        converted = converter.convert tokens
      
        done()

      it "converted example/code tokens", (done) ->

        expect(converted.shift()).toEqual({ type: 'it', depth: 3, text: 'adding two numbers' })
        expect(converted.shift()).toEqual({ type: 'assertion', depth: 4, code: 'mather.add a,b # => 3' })
        
        done()
