configure = ($ = {}) ->

  $.assign ?= (target, source) ->
    target[key] = val for own key, val of source

  $.require ?= (path) -> require path

  class Tokenizer
    marked: null

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
      text: mdToken.text

    processMarkdownToken: (tokens, mdToken) ->
      createToken = switch
        when @isExampleToken mdToken then @createExampleToken
        when @isContextToken mdToken then @createContextToken
        when @isCodeToken mdToken then @createCodeToken

      tokens = tokens.concat createToken(mdToken) if createToken?
      return tokens

    tokenizeMarkdown: (markdown) ->
      @marked.lexer markdown

    tokenize: (markdown) ->
      mdTokens = @tokenizeMarkdown markdown
      mdTokens.reduce @processMarkdownToken.bind(this), []

  class JasmineConverter

    constructor: (props = {}) ->

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
      text: text

    createAssertionToken: ({depth, code}) ->
      type: "assertion"
      depth: depth
      code: code

    getVariableNames: (code) ->
      tokens = require("coffee-script").tokens(code)
      tokens = tokens.filter (token) ->
        token[0] is "IDENTIFIER" and token.variable and token.spaced
      tokens.map (token) -> token[1]

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
      declared = ['require']
      snippets = []

      indent = (code, depth) ->
        indentation = ""
        indentation += "  " for i in [1...depth]
        code.replace /^/gm, indentation

      addSnippet = (code, depth) ->
        code = indent code, depth
        snippets.push code

      replaceAssertionComments = (code) ->
        pattern = /( +)(.*) # => (.*)/
        code.replace pattern, "$1expect($2).toEqual($3)"

      addAssertionDone = (code) ->
        pattern = /^( +)([^ ]+)/gm
        lastSpacing = match[1] while match = pattern.exec code
        code += "\n#{lastSpacing}done()"

      tokens.forEach (token) ->

        if token.type is "describe"
          code = "describe \"#{token.text}\", ->"
          addSnippet code, token.depth

        if token.type is "vars"
          vars = token.vars.filter (v) -> !(v in declared)
          declared = declared.concat vars
          code = "[#{vars.join(",")}] = []"
          addSnippet code, token.depth

        if token.type is "beforeEach"
          code = "beforeEach ->\n"
          code += indent token.code, 2
          addSnippet code, token.depth

        if token.type is "it"
          code = "it \"#{token.text}\", (done) ->"
          addSnippet code, token.depth

        if token.type is "assertion"
          code = replaceAssertionComments token.code
          code = addAssertionDone code
          addSnippet code, token.depth

      snippets.join("\n\n")

  JasmineCoffeeParser: JasmineCoffeeParser
  JasmineConverter: JasmineConverter
  Tokenizer: Tokenizer

module.exports = configure()
