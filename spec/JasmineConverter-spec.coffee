describe "Jasmine Converter", ->

  [MarkdownDriven, converter] = []

  beforeEach ->
    MarkdownDriven = require "boco-markdown-driven"
    converter = new MarkdownDriven.JasmineConverter

  describe "Converting context/code tokens", ->

    [converted] = []

    beforeEach ->
      converted = converter.convert [
        { type: "context", depth: 1, text: "Mather" }
        { type: "code", text: 'mather = new Mather' }
      ]

    it "converted context/code tokens", (done) ->
      expect(converted.shift()).toEqual({ type: 'describe', depth: 1, text: 'Mather' })
      expect(converted.shift()).toEqual({ type: 'vars', depth: 2, vars: ['mather', 'Mather'] })
      expect(converted.shift()).toEqual({ type: 'beforeEach', depth: 2, code: 'mather = new Mather' })
      done()

  describe "Converting example/code tokens", ->

    [converted] = []

    beforeEach ->
      converted = converter.convert [
        { type: "example", depth: 3, text: "example: adding two numbers" },
        { type: "code", text: 'mather.add a,b # => 3' }
      ]

    it "converted example/code tokens", (done) ->
      expect(converted.shift()).toEqual({ type: 'it', depth: 3, text: 'adding two numbers' })
      expect(converted.shift()).toEqual({ type: 'assertion', depth: 4, code: 'mather.add a,b # => 3' })
      done()

  describe "Specifying Global Variables", ->

    [converted] = []

    beforeEach ->
      converter.globalVariables.push "foo", "bar"

      converted = converter.convert [
        { type: "context", depth: 1, text: "Test globals" },
        { type: "code", text: "[a,b,c,foo,bar] = [1,2,3,4,5]" }
      ]

    it "global variables are not initialized", (done) ->
      converted.shift() # the "describe" token here
      expect(converted.shift()).toEqual({ type: 'vars', depth: 2, vars: ['a', 'b', 'c'] })
      done()
