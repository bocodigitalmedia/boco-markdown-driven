configure = ($ = {}) ->

  $.assign ?= (target, source) ->
    target[key] = val for own key, val of source

  $.require ?= (path) -> require path

  class Compiler
    constructor: (props = {}) ->
      $.assign this, props
      @tokenizer ?= new Tokenizer
      @converter ?= new JasmineConverter
      @parser ?= new JasmineCoffeeParser

    compile: (markdown) ->
      tokens = @tokenizer.tokenize markdown
      tokens = @converter.convert tokens
      @parser.parse tokens

  class Tokenizer
    marked: null
    defaultLanguage: null

    constructor: (props) ->
      $.assign this, props
      @marked ?= $.require("marked")

    isExampleToken: (mdToken) ->
      mdToken.type is "heading" and /^example/i.test mdToken.text

    isContextToken: (mdToken) ->
      mdToken.type is "heading" and !@isExampleToken mdToken

    isCodeToken: (mdToken) ->
      mdToken.type is "code"

    createExampleToken: (mdToken) ->
      type: "example"
      text: mdToken.text
      depth: mdToken.depth

    createContextToken: (mdToken) ->
      type: "context"
      text: mdToken.text
      depth: mdToken.depth

    createCodeToken: (mdToken) ->
      type: "code"
      lang: mdToken.lang
      text: mdToken.text

    processMarkdownToken: (tokens, mdToken) ->
      createToken = switch
        when @isExampleToken mdToken then @createExampleToken
        when @isContextToken mdToken then @createContextToken
        when @isCodeToken mdToken then @createCodeToken

      return tokens unless createToken?

      token = createToken mdToken
      previous = tokens[tokens.length - 1]

      if token.type is "code" and previous?.type is "code" and previous?.lang is token.lang
        previous.text = previous.text + "\n" + token.text
        return tokens

      tokens = tokens.concat createToken(mdToken) if createToken?
      return tokens

    tokenizeMarkdown: (markdown) ->
      @marked.lexer markdown

    tokenize: (markdown) ->
      mdTokens = @tokenizeMarkdown markdown
      mdTokens.reduce @processMarkdownToken.bind(this), []

  class JasmineConverter
    globalVariables: null

    constructor: (props = {}) ->
      # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects
      @globalVariables ?= [
        "Infinity", "NaN", "undefined", "null",
        "eval", "isFinite", "isNaN", "parseFloat", "parseInt",
        "decodeURI", "decodeURIComponent", "encodeURI", "encodeURIComponent",
        "Object", "Function", "Boolean", "Error", "EvalError", "InternalError",
        "RangeError", "ReferenceError", "SyntaxError", "TypeError", "URIError",
        "Number", "Math", "Date", "String", "Symbol", "RegExp",
        "Array", "Int8Array", "Uint8Array", "Uint8ClampedArray", "Int16Array",
        "Uint16Array", "Int32Array", "Uint32Array", "Float32Array", "Float64Array",
        "Map", "Set", "WeakMap", "WeakSet", "SIMD", "ArrayBuffer", "DataView", "JSON",
        "Promise", "Generator", "GeneratorFunction", "Reflect", "Proxy", "arguments",
        "require", "console", "module", "process", "window", "jasmine", "spyOn"
      ]

    createDescribeToken: ({depth, text}) ->
      type: "describe"
      depth: depth
      text: text

    createVarsToken: ({depth, vars}) ->
      type: "vars"
      depth: depth
      vars: vars

    createBeforeEachToken: ({depth, code}) ->
      type: "beforeEach"
      depth: depth
      code: code

    createItToken: ({depth, text}) ->
      type: "it"
      depth: depth
      text: text.replace /^example\:?\s*/, ""

    createAssertionToken: ({depth, code}) ->
      type: "assertion"
      depth: depth
      code: code

    getVariableNames: (code) ->
      tokens = require("coffee-script").tokens(code)

      reduceFn = (vars, token) =>
        [type, value] = token
        return vars unless type is "IDENTIFIER" and token.variable
        return vars unless vars.indexOf(value) is -1
        return vars unless @globalVariables.indexOf(value) is -1
        vars.concat value

      tokens.reduce reduceFn, []

    convert: (tokens) ->
      currentDepth = 0
      currentContext = null

      reduceTokens = (tokens, token) =>
        currentDepth = token.depth if token.depth?

        if token.type is "context"
          currentContext = "describe"
          tokens.push @createDescribeToken token

        if token.type is "example"
          currentContext = "it"
          tokens.push @createItToken token

        if token.type is "code" and currentContext is "describe"
          vars = @getVariableNames token.text
          tokens.push @createVarsToken vars: vars, depth: currentDepth + 1
          tokens.push @createBeforeEachToken code: token.text, depth: currentDepth + 1

        if token.type is "code" and currentContext is "it"
          tokens.push @createAssertionToken code: token.text, depth: currentDepth + 1

        return tokens

      tokens.reduce reduceTokens, []

  class JasmineCoffeeParser
    constructor: (props = {}) ->

    parse: (tokens) ->
      # two dimensional array, first dimension representing depth at which vars defined
      declared = []
      snippets = []

      removeTrailingWhiteSpace = (code) ->
        code.replace /[ \t]+$/gm, ""

      indent = (code, depth) ->
        indentation = ""
        indentation += "  " for i in [1...depth]
        code.replace /^/gm, indentation

      addSnippet = (code, depth) ->
        code = indent code, depth
        snippets.push code

      replaceAssertionComments = (code) ->

        getAssertionCommentSubject = (line) ->
          startIndex = /[^\s]/.exec(line).index
          endIndex = line.indexOf " # =>"
          line[startIndex...endIndex]

        getAssertionCommentTarget = (line) ->
          /\s# => (.*)$/.exec(line)[1]

        getAssertionCommentIndentation = (line) ->
          /^(\s*)/.exec(line)[1]

        transformAssertionComment = (line) ->
          return line if line.indexOf(" # =>") is -1
          subject = getAssertionCommentSubject line
          target = getAssertionCommentTarget line
          indentation = getAssertionCommentIndentation line
          "#{indentation}expect(#{subject}).toEqual(#{target})"

        code.split("\n").map(transformAssertionComment).join("\n")

      addDone = (code) ->
        pattern = /^(\s*)([^\s]+)/gm
        lastSpacing = match[1] while match = pattern.exec code
        lastSpacing ?= ""
        code += "\n#{lastSpacing}done()"

      isDeclared = (v, depth) ->
        [(depth-1)..0].some (d) ->
          v in (declared[d] ? [])

      declareVar = (v, depth) ->
        d = declared[depth] ?= []
        d.push v if d.indexOf(v) is -1

      tokens.forEach (token) ->

        if token.type is "describe"
          quotedText = JSON.stringify token.text
          code = "describe #{quotedText}, ->"
          code = "\n" + code unless token.depth is 1
          addSnippet code, token.depth

        if token.type is "vars"
          vars = []

          token.vars.forEach (v) ->
            vars.push v unless isDeclared v, token.depth
            declareVar v, token.depth

          return if vars.length is 0
          code = "\n[#{vars.join(", ")}] = []"
          addSnippet code, token.depth

        if token.type is "beforeEach"
          code = "\nbeforeEach ->\n"
          code = code + indent(token.code, 2)
          addSnippet code, token.depth

        if token.type is "it"
          quotedText = JSON.stringify token.text
          code = "\nit #{quotedText}, (done) ->"
          addSnippet code, token.depth

        if token.type is "assertion"
          code = replaceAssertionComments token.code
          code = addDone code
          addSnippet code, token.depth

      result = snippets.join("\n") + "\n"
      removeTrailingWhiteSpace result

  class FileCompiler
    compiler: null

    constructor: (props = {}) ->
      @[key] = val for own key, val of props
      @compiler ?= new Compiler

    compile: (sourcePath, targetPath, done) ->

      @readFile sourcePath, (error, data) =>
        return done error if error?
        compiled = @compiler.compile data.toString()

        @writeFile targetPath, compiled, (error) ->
          return done error if error?
          return done null, compiled

    readFile: (path, done) ->
      require("fs").readFile path, done

    writeFile: (path, data, done) ->
      require("fs").writeFile path, data, done

  class MultiFileCompiler
    constructor: (params = {}) ->
      @[key] = val for own key, val of params
      @cwd ?= process.cwd()
      @fileCompiler ?= new FileCompiler
      @sourceDir ?= @resolvePath @cwd, "docs"
      @targetDir ?= @resolvePath @cwd, "spec"

    resolvePath: (args...) ->
      require("path").resolve args...

    joinPath: (args...) ->
      require("path").join args...

    eachSeries: (series, fn, done) ->
      require("async").eachSeries series, fn, done

    getTargetName: (sourceName) ->
      sourceName.replace /((\.coffee)?\.md|\.litcoffee)$/, "-spec.coffee"

    compileSourceName: (sourceName, done) ->
      targetName = @getTargetName sourceName
      sourcePath = @joinPath @sourceDir, sourceName
      targetPath = @joinPath @targetDir, targetName
      @fileCompiler.compile sourcePath, targetPath, done

    glob: (args...) ->
      require("glob") args...

    compile: (patterns..., done) ->
      patterns = ["**/*.?(md|litcoffee)"] if patterns.length is 0

      compilePattern = (pattern, done) =>
        @glob pattern, cwd: @sourceDir, (error, sourceNames) =>
          return done error if error
          @eachSeries sourceNames, @compileSourceName.bind(this), done

      @eachSeries patterns, compilePattern, done

  class CLI
    multiFileCompiler: null

    constructor: (props = {}) ->
      $.assign this, props
      @multiFileCompiler ?= new MultiFileCompiler

    getUsageBanner: ->
      """
      #{$0} [file|pattern]...
      Compile the specified files/patterns.
      """

    run: (done) ->

      yargs = require("yargs")
      argv = yargs.argv
      patterns = argv._

      @multiFileCompiler.compile patterns..., (error) ->
        throw error if error?
        process.exit 0

  CLI: CLI
  Compiler: Compiler
  FileCompiler: FileCompiler
  MultiFileCompiler: MultiFileCompiler
  JasmineCoffeeParser: JasmineCoffeeParser
  JasmineConverter: JasmineConverter
  Tokenizer: Tokenizer

module.exports = configure()
