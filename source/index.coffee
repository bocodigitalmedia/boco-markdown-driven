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

  Tokenizer: Tokenizer

module.exports = configure()
