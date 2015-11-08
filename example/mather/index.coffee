class Mather
  add: (args...) ->
    args.reduce (a, b) -> a + b

  subtract: (args...) ->
    args.reduce (a, b) -> a - b

module.exports = Mather
