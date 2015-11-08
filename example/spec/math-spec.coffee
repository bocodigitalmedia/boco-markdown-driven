describe "Mather", ->

  [Mather,mather] = []

  beforeEach ->
    Mather = require "mather"
    mather = new Mather

  describe "Adding numbers", ->

    [a,b,c,d] = []

    beforeEach ->
      [a,b,c,d] = [2,4,6,8]

    it "example: adding two numbers", (done) ->

      mather.add a, b, (error, result) ->
        throw error if error?
        expect(result).toEqual(6)
        done()

    it "example: adding more than two numbers", (done) ->

      mather.add a, b, c, d, (error, result) ->
        throw error if error?
        expect(result).toEqual(20)
        done()