MarkDownDriven = require ".."
Path = require 'path'
compiler = new MarkDownDriven.MultiFileCompiler
  sourceDir: Path.resolve __dirname, "..", "docs"
  targetDir: Path.resolve __dirname, "..", "spec"

compiler.compile "**/*.coffee.md", (error) ->
  throw error if error?
