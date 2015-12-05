$files = {}

  describe "boco-markdown-driven", ->

describe "Usage", ->
  [MarkdownDriven, MDDJasmineCoffee] = []

  beforeEach ->
    MarkdownDriven = require "boco-markdown-driven"
    MDDJasmineCoffee = require "boco-mdd-jasmine-coffee"

  it "is ok", ->
    

  describe "Using the API", ->
    [parser, generator, compiler] = []

    beforeEach ->
      parser = new MarkdownDriven.Parser nativeLanguages: ["coffee"]
      generator = new MDDJasmineCoffee.Generator
      
      compiler = new MarkdownDriven.Compiler
        parser: parser
        generator: generator
      compiler.compile "# Mather..." # => "describe 'Mather' -> ..."

    it "is ok", ->
      
