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

      mockFs[sourcePath] = "some markdown"

    it "compiling the markdown", (done) ->
        compiler.compile sourcePath, targetPath, (error) ->
          throw error if error?

          expect(tokenizer.tokenize).toHaveBeenCalledWith "some markdown"
          expect(converter.convert).toHaveBeenCalledWith "tokenized"
          expect(parser.parse).toHaveBeenCalledWith "converted"

          expect(mockFs[targetPath]).toEqual("parsed")

          done()
