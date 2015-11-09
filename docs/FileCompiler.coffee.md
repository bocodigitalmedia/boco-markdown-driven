# FileCompiler

    FileCompiler = require("boco-mdd").FileCompiler
    compiler = new FileCompiler

## Compiling

Let's create a mock filesystem, then override our compiler's `readFile` and `writeFile` methods
so we can test reading and writing:

    mockFs = Object.create null

    compiler.readFile =  (path, done) ->
      done null, mockFs[path]

    compiler.writeFile = (path, data, done) ->
      mockFs[path] = data
      done()


By default, the file compiler is configured with a default tokenizer, jasmine converter, and jasmine coffee parser.
Let's spy on their methods to see what's going on here...

    {tokenizer, converter, parser} = compiler

    spyOn(tokenizer, 'tokenize').and.returnValue "tokenized"
    spyOn(converter, 'convert').and.returnValue "converted"
    spyOn(parser, 'parse').and.returnValue "parsed"

Let's try compiling some markdown into jasmine coffeescript specs:

    sourcePath = "docs/mather.md"
    targetPath = "spec/mather-spec.md"

    mockFs[sourcePath] = """
      # Mather

      Mather is a library for doing maths.

          Mather = require "Mather"
          mather = new Mather

      ### example: adding two numbers

          mather.add 1, 2 # => 3
          mather.add 3, 4 # => 7
      """

### example: compiling the markdown

      compiler.compile sourcePath, targetPath, (error) ->
        throw error if error?

        expect(tokenizer.tokenize).toHaveBeenCalledWith mockFs[sourcePath]
        expect(converter.convert).toHaveBeenCalledWith "tokenized"
        expect(parser.parse).toHaveBeenCalledWith "converted"

        mockFs[targetPath] # => "parsed"
