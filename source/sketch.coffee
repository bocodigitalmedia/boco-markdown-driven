Marked = require "marked"

getCoffeeTokens = (code) ->
  require("coffee-script").tokens code

getCoffeeVars = (code) ->
  tokens = getCoffeeTokens(code)

  tokens = tokens.filter (token) ->
    token[0] is "IDENTIFIER" and
      token.variable and
      token.spaced

  tokens.map ([type, text, data]) -> text

getFileData = (path) ->
  require("fs").readFileSync(path).toString()

getMarkdownTokens = (markdown, types...) ->
  tokenInTypes = (token) -> token.type in types
  tokens = require("marked").lexer(markdown)
  tokens = tokens.filter(tokenInTypes) if types.length
  tokens

processMarkdown = (markdown) ->
  jasmineTokens = []
  currentContext = null
  currentDepth = null

  processHeadingToken = (token) ->
    currentDepth = token.depth
    return addExampleToken token if /^example/i.test token.text
    return addDescribeToken token

  addExampleToken = (token) ->
    currentContext = "example"
    jasmineTokens.push
      type: "example"
      depth: currentDepth
      text: token.text

  addDescribeToken = (token) ->
    currentContext = "describe"
    jasmineTokens.push
      type: "describe"
      depth: currentDepth
      text: token.text

  processCodeToken = (token) ->
    return addDescribeCodeToken token if currentContext is "describe"
    return addExampleCodeToken token if currentContext is "example"

  addDescribeCodeToken = (token) ->
    code = token.text
    vars = getCoffeeVars code

    jasmineTokens.push
      type: "describe.code"
      depth: currentDepth
      vars: vars
      code: code

  addExampleCodeToken = (token) ->
    code = token.text
    vars = getCoffeeVars code

    jasmineTokens.push
      type: "example.code"
      depth: currentDepth
      vars: vars
      code: code

  processMarkdownTokens = (tokens) ->
    tokens.forEach (token) ->
      return processHeadingToken token if token.type is "heading"
      return processCodeToken token if token.type is "code"

  markdownTokens = getMarkdownTokens(markdown, "heading", "code")
  processMarkdownTokens markdownTokens
  return jasmineTokens

Path = require "path"
sourcePath = Path.resolve __dirname, "..", "docs", "math.coffee.md"
markdown = getFileData sourcePath
jasmineTokens = processMarkdown markdown
console.log jasmineTokens
process.exit 0
