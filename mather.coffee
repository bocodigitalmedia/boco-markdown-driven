class Math
  add: (args..., done) ->
    sum = args.reduce (a, b) -> a + b
    done null, sum

module.exports = Math
