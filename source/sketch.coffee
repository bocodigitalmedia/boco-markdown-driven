MarkDownDriven = require "./"
File = require "fs"
Path = require "path"
glob = require "glob"

class Compiler
  tokenizer: null
  converter: null
  parser: null

  constructor: (props = {}) ->
    @[key] = val for own key, val of props
    @tokenizer ?= new MarkDownDriven.Tokenizer
    @converter ?= new MarkDownDriven.JasmineConverter
    @parser ?= new MarkDownDriven.JasmineCoffeeParser

  parse: (markdown) ->
    tokens = @tokenizer.tokenize markdown
    tokens = @converter.convert tokens
    @parser.parse tokens

  readFile: (path, done) ->
    require("fs").readFile path, done

  writeFile: (path, data, done) ->
    require("fs").writeFile path, data, done

  compile: (sourcePath, targetPath, done) ->
    @readFile sourcePath, (error, data) =>
      return done error if error?
      compiled = @parse data.toString()
      @writeFile targetPath, compiled, done

class MassCompiler
  constructor: (params = {}) ->
    @[key] = val for own key, val of params
    @cwd ?= process.cwd()
    @compiler ?= new Compiler
    @sourceDir ?= Path.resolve @cwd, "docs"
    @targetDir ?= Path.resolve @cwd, "spec"

  getTargetName: (sourceName) ->
    sourceName.replace /((\.coffee)?\.md|\.litcoffee)$/, "-spec.coffee"

  compileSourceName: (sourceName, done) ->
    targetName = @getTargetName sourceName
    sourcePath = Path.join @sourceDir, sourceName
    targetPath = Path.join @targetDir, targetName
    @compiler.compile sourcePath, targetPath, done

  eachSeries: (series, fn, done) ->
    require("async").eachSeries series, fn, done

  compile: (pattern = "**/*.?(md|litcoffee)", done) ->
    glob pattern, cwd: @sourceDir, (error, sourceNames) =>
      return done error if error
      @eachSeries sourceNames, @compileSourceName.bind(this), done

compiler = new MassCompiler 
compiler.compile "**/*.?(md|litcoffee)", (error) -> throw error if error?
