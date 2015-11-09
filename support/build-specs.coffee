MarkdownDriven = require "../source"
Path = require 'path'

compiler = new MarkdownDriven.MultiFileCompiler
  sourceDir: Path.resolve __dirname, "..", "docs"
  targetDir: Path.resolve __dirname, "..", "spec"

cli = new MarkdownDriven.CLI multiFileCompiler: compiler
cli.run()
