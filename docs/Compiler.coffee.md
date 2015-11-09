# Compiler

    MarkdownDriven = require "boco-mdd"

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

## example: compiling

    tokenizer.tokenize.calls.allArgs() # => [["some markdown"]]
    converter.convert.calls.allArgs() # => [["tokenized"]]
    parser.parse.calls.allArgs() # => [["converted"]]
    result # => "parsed"
