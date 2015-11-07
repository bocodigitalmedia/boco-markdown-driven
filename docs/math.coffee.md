# Mather

Mather is a `library` for adding numbers.

    Mather = require "mather"
    mather = new Mather

## Adding numbers

Mather can add numbers.

    [a,b,c,d] = [2,4,6,8]

### example: adding two numbers

    mather.add a, b, (error, result) ->
      throw error if error?
      result # => 6

### example: adding more than two numbers

    mather.add a, b, c, d, (error, result) ->
      throw error if error?
      result # => 20
