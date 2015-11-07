describe "Math", ->
  [Math, math] = []

  beforeEach ->
    Math = require "math"
    math = new Math

  describe "Adding numbers", ->

    [a,b,c,d] = []

    beforeEach ->
      a = 2, b = 3, c = 4, d = 5

    it "example: adding two numbers", (done) ->
      adder.add a, b, (error, result) ->
        throw error if error?
        expect(result).toEqual 5
        done()

    it "example: adding more than two numbers", (done) ->
      adder.add a, b, c, d, (error, result) ->
        throw error if error?
        expect(result).toEqual 14
