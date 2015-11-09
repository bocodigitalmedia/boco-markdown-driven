# FileCompiler

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

## Compiling

    sourcePath = "docs/mather.md"
    targetPath = "docs/mather-spec.coffee"

    mockFs[sourcePath] = "some markdown"
    mockFs[targetPath] = null

### example: compiling

    fileCompiler.compile sourcePath, targetPath, (error) ->
      throw error if error?

      expect(fileCompiler.readFile)
        .toHaveBeenCalledWith sourcePath, jasmine.any(Function)

      expect(compiler.compile)
        .toHaveBeenCalledWith "some markdown"

      expect(fileCompiler.writeFile)
        .toHaveBeenCalledWith targetPath, "compiled spec", jasmine.any(Function)

      mockFs[targetPath] # => "compiled spec"
