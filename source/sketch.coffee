MarkDownDriven = require "./"
File = require "fs"
Path = require "path"
glob = require "glob"


compileMarkdownFile = (params = {}, done) ->
  sourcePath = params.sourcePath
  targetPath = params.targetPath ? sourcePath + ".spec.coffee"

  tokenizer = params.tokenizer ? new MarkDownDriven.Tokenizer
  converter = params.converter ? new MarkDownDriven.JasmineConverter
  parser = params.parser ? new MarkDownDriven.JasmineCoffeeParser

  File.readFile sourcePath, (error, data) ->
    return done error if error?
    markdown = data.toString()
    tokens = tokenizer.tokenize markdown
    tokens = converter.convert tokens
    jasmine = parser.parse tokens

    File.writeFile targetPath, jasmine, done

compileMarkdownFiles = (params = {}, done) ->
  cwd = process.cwd()
  sourceDir = params.sourceDir ? Path.resolve cwd, "docs"
  destDir = params.destDir ? Path.resolve cwd, "spec"
  sourcePattern = params.sourcePattern ? "**/*.?(md|litcoffee)"

  glob sourcePattern, cwd: sourceDir, (error, sourceNames) ->
    return done error if error?

    compileSourceName = (sourceName, done) ->
      targetName = sourceName.replace /(\.(coffee)?\.md)$/, "-spec.coffee"
      targetPath = Path.resolve destDir, targetName
      sourcePath = Path.resolve sourceDir, sourceName
      compileMarkdownFile sourcePath: sourcePath, targetPath: targetPath, (error) ->
        return done error if error?

    require("async").eachSeries sourceNames, compileSourceName, done

compileMarkdownFiles null, (error) -> throw error if error?; process.exit(0)
