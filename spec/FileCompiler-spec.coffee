describe "FileCompiler", ->

  [MarkdownDriven, compiler, fileCompiler, mockFs, path, done, data] = []

  beforeEach ->
    MarkdownDriven = require("boco-markdown-driven")

    compiler = new MarkdownDriven.Compiler
    fileCompiler = new MarkdownDriven.FileCompiler compiler: compiler

    mockFs = Object.create null

    spyOn(compiler, 'compile').and.returnValue "compiled spec"

    spyOn(fileCompiler, 'readFile').and.callFake (path, done) ->
      done null, mockFs[path]

    spyOn(fileCompiler, 'writeFile').and.callFake (path, data, done) ->
      mockFs[path] = data
      done()

  describe "Compiling", ->

    [sourcePath, targetPath] = []

    beforeEach ->
      sourcePath = "docs/mather.md"
      targetPath = "docs/mather-spec.coffee"

      mockFs[sourcePath] = "some markdown"
      mockFs[targetPath] = null

    it "compiling", (done) ->
      fileCompiler.compile sourcePath, targetPath, (error) ->
        throw error if error?

        expect(fileCompiler.readFile)
          .toHaveBeenCalledWith sourcePath, jasmine.any(Function)

        expect(compiler.compile)
          .toHaveBeenCalledWith "some markdown"

        expect(fileCompiler.writeFile)
          .toHaveBeenCalledWith targetPath, "compiled spec", jasmine.any(Function)

        expect(mockFs[targetPath]).toEqual("compiled spec")

        done()
