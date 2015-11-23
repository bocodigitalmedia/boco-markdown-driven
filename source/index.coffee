configure = (configuration = {}) ->
  $ = {}
  $[key] = val for own key, val of configuration

  class ParseTree
    contextNodes: null
    depth: null

    constructor: (props = {}) ->
      @[key] = val for own key, val of props
      @depth ?= 0
      @contextNodes ?= []

    addContextNode: (props) ->
      node = new ContextNode(props)
      node.parent = this
      @contextNodes.push node
      node

    getContextNodes: ->
      @contextNodes

  class Node
    type: null

    constructor: (props = {}) ->
      Object.defineProperty @, "parent",
        value: null, enumerable: false, writable: true

      Object.defineProperty @, "ancestors", enumerable: false, get: ->
        do => node = this; node = node.parent while node.parent?

      Object.defineProperty @, "depth", enumerable: true, get: ->
        @ancestors.length

      @[key] = val for own key, val of props
      @type ?= @constructor.name

  class ContextNode extends Node
    text: null
    children: null

    constructor: (props) ->
      super props
      @children ?= []

    addChild: (node) ->
      node.parent = this
      @children.push node
      node

    getChildrenByType: (type) ->
      @children.filter (child) -> child.type is type

    addContextNode: (props) ->
      @addChild new ContextNode(props)

    addBeforeEachNode: (props) ->
      @addChild new BeforeEachNode(props)

    addFileNode: (props) ->
      @addChild new FileNode(props)

    addAssertionNode: (props) ->
      @addChild new AssertionNode(props)

    getContextNodes: ->
      @getChildrenByType "ContextNode"

    getFileNodes: ->
      @getChildrenByType "FileNode"

    getAssertionNodes: ->
      @getChildrenByType "AssertionNode"

    getBeforeEachNodes: ->
      @getChildrenByType "BeforeEachNode"

    getAncestorContexts: ->
      @ancestors.filter ({type}) -> type is "ContextNode"

    getParentContext: ->
      @getAncestorContexts[0]

  class BeforeEachNode extends Node
    code: null

  class FileNode extends Node
    path: null
    data: null

  class AssertionNode extends Node
    text: null
    code: null

  class DepthError extends Error
    headingToken: null

    constructor: (props = {}) ->
      @[key] = val for own key, val of props
      @name = @constructor.name
      Error.captureStackTrace @, @constructor
      @message = @getMessage()

    getMessage: ->
      "Invalid heading depth (#{@heading.depth}) for heading '#{@heading.text}'."

  class Parser
    nativeLanguages: null
    assertionCodePatterns: null
    fileCodePattern: null

    constructor: (props = {}) ->
      @[key] = val for own key, val of props
      @nativeLanguages ?= []
      @assertionCodePatterns ?= [/\b(assert|expect|should)\b/i]
      @fileCodePattern ?= /^.* file: "([^"]*)"/

    isNativeCode: (code, lang) ->
      !lang? or lang in @nativeLanguages

    isAssertionCode: (code, lang) ->
      return false if !@isNativeCode(code, lang) or @isFileCode(code, lang)
      @assertionCodePatterns.some (pattern) -> pattern.test(code)

    isBeforeEachCode: (code, lang) ->
      @isNativeCode(code, lang) and !@isFileCode(code, lang) and !@isAssertionCode(code, lang)

    isFileCode: (code, lang) ->
      @fileCodePattern.test code

    getFilePath: (code) ->
      @fileCodePattern.exec(code)[1]

    getFileData: (code) ->
      code.slice(code.indexOf("\n") + 1)

    isAssertionNext: (tokens) ->
      return false unless tokens.length > 1
      {type, text, lang} = tokens[1]
      tokens[0].type is "paragraph" and type is "code" and @isAssertionCode(text, lang)

    consumeNextAssertion: (contextNode, tokens) ->
      [para, code] = tokens.splice 0, 2
      contextNode.addAssertionNode text: para.text, code: code.text

    isFileNext: (tokens) ->
      return false unless tokens.length
      {type, text, lang} = tokens[0]
      type is "code" and @isFileCode(text, lang)

    consumeNextFile: (contextNode, tokens) ->
      {text} = tokens.shift()
      path = @getFilePath text
      data = @getFileData text
      contextNode.addFileNode path: path, data: data

    isBeforeEachNext: (tokens) ->
      return false unless tokens.length
      {type, text, lang} = tokens[0]
      type is "code" and @isBeforeEachCode(text, lang)

    consumeNextBeforeEach: (contextNode, tokens) ->
      {text} = tokens.shift()
      contextNode.addBeforeEachNode code: text

    getParentNodeForHeading: (headingToken, parseTree, previousContextNode) ->
      previousNode = (previousContextNode or parseTree)
      depthDiff = previousNode.depth - headingToken.depth
      return previousNode if depthDiff is -1
      return previousNode.ancestors[depthDiff] if depthDiff >= 0
      throw new DepthError headingToken: headingToken

    parseContextChildTokens: (contextNode, tokens) ->
      return contextNode unless tokens.length

      switch
        when @isAssertionNext(tokens) then @consumeNextAssertion(contextNode, tokens)
        when @isFileNext(tokens) then @consumeNextFile(contextNode, tokens)
        when @isBeforeEachNext(tokens) then @consumeNextBeforeEach(contextNode, tokens)
        else tokens.shift()

      @parseContextChildTokens contextNode, tokens

    parse: (tokens, parseTree = (new ParseTree), previousContextNode) ->
      headingToken = tokens.find ({type}) -> type is "heading"
      return parseTree unless headingToken?

      parentNode = @getParentNodeForHeading headingToken, parseTree, previousContextNode
      contextNode = parentNode.addContextNode text: headingToken.text

      tokens = tokens.slice (tokens.indexOf(headingToken) + 1)
      childTokens = do -> tokens.shift() while tokens.length and tokens[0].type isnt "heading"

      @parseContextChildTokens contextNode, childTokens
      @parse tokens, parseTree, contextNode

  MarkdownDriven =
    configuration: $
    configure: configure
    ParseTree: ParseTree
    Node: Node
    ContextNode: ContextNode
    BeforeEachNode: BeforeEachNode
    FileNode: FileNode
    AssertionNode: AssertionNode
    DepthError: DepthError
    Parser: Parser

module.exports = MarkdownDriven = configure()

unless module.parent?

  parser = new MarkdownDriven.Parser
    nativeLanguages: ["coffee"]
    assertionCodePatterns: [/\b(assert|expect|should)\b/, /# =>/]

  markdown = require("fs").readFileSync("example.md").toString()
  tokens = require("marked").lexer markdown
  parseTree = parser.parse tokens

  console.log JSON.stringify(parseTree, null, 2)
