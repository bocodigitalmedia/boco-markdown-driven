# Mather

Mather is a library for doing maths.

    Mather = require 'mather'
    mather = new Mather()

## Adding

You can add two numbers:

    result = mather.add 3, 4
    expect(result).toEqual 7

You can add more than two numbers

    result = mather.add 3, 4, 5
    expect(result).toEqual 12

## Foo

    foo = "bar"
    bar = "baz"
    mather = new Mather()

## Subtracting

You can subtract two numbers:

    result = mather.subtract 4, 3
    expect(result).toEqual 1

You can subtract more than two numbers:

    result = mather.subtract 4, 3, 2
    expect(result).toEqual -1
