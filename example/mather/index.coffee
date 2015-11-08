class Mather

  add: (args..., done) ->
    n = args.reduce (a, b) -> a + b
    done null, n

  subtract: (args..., done) ->
    n = args.reduce (a, b) -> a - b
    done null, n

module.exports = Mather
