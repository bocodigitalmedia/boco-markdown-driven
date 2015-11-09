describe "Compiler", ->

  [MarkdownDriven, tokenizer, converter, parser, compiler, result] = []

  beforeEach ->
    MarkdownDriven = require "boco-markdown-driven"

    tokenizer = new MarkdownDriven.Tokenizer
    spyOn(tokenizer, "tokenize").and.returnValue "tokenized"

    converter = new MarkdownDriven.JasmineConverter
    spyOn(converter, "convert").and.returnValue "converted"

    parser = new MarkdownDriven.JasmineCoffeeParser
    spyOn(parser, "parse").and.returnValue "parsed"

    compiler = new MarkdownDriven.Compiler
      tokenizer: tokenizer
      converter: converter
      parser: parser

    result = compiler.compile "some markdown"

  it "compiling", (done) ->
    expect(tokenizer.tokenize.calls.allArgs()).toEqual([["some markdown"]])
    expect(converter.convert.calls.allArgs()).toEqual([["tokenized"]])
    expect(parser.parse.calls.allArgs()).toEqual([["converted"]])
    expect(result).toEqual("parsed")
    done()
