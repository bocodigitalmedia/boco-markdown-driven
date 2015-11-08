MarkDownDriven = require "boco-mdd"

compiler = new MarkDownDriven.MultiFileCompiler
  sourceDir: require("path").resolve __dirname, "docs"
  targetDir: require("path").resolve __dirname, "spec"

compiler.compile "**/*.coffee.md", (error) ->
  throw error if error?
