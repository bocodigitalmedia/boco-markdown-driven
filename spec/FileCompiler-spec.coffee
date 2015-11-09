describe "FileCompiler", ->

  [FileCompiler, compiler] = []

  beforeEach ->
    FileCompiler = require("boco-mdd").FileCompiler
    compiler = new FileCompiler

  describe "Compiling", ->

    [mockFs, path, done, data, tokenizer, converter, parser, sourcePath, targetPath] = []

    beforeEach ->
      mockFs = Object.create null

      compiler.readFile =  (path, done) ->
        done null, mockFs[path]

      compiler.writeFile = (path, data, done) ->
        mockFs[path] = data
        done()
      {tokenizer, converter, parser} = compiler

      spyOn(tokenizer, 'tokenize').and.returnValue "tokenized"
      spyOn(converter, 'convert').and.returnValue "converted"
      spyOn(parser, 'parse').and.returnValue "parsed"
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

    it "compiling the markdown", (done) ->
        compiler.compile sourcePath, targetPath, (error) ->
          throw error if error?

          expect(tokenizer.tokenize).toHaveBeenCalledWith mockFs[sourcePath]
          expect(converter.convert).toHaveBeenCalledWith "tokenized"
          expect(parser.parse).toHaveBeenCalledWith "converted"

          expect(mockFs[targetPath]).toEqual("parsed")

          done()
