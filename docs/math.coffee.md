# Math

Math is a library for adding numbers.

    Math = require "math"
    math = new Math

## Adding numbers

Math can add numbers.

    a = 2, b = 3, c = 4, d = 5

### example: adding two numbers

    adder.add a, b, (error, result) ->
      throw error if error?
      result # => 5

### example: adding more than two numbers

    adder.add a, b, c, d, (error, result) ->
      throw error if error?
      result # => 14
