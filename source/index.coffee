class Node
  type: null
  children: null

  constructor: (props = {}) ->
    Object.defineProperty @, "parent",
      value: null, enumerable: false, writable: true

    Object.defineProperty @, "ancestors", enumerable: false, get: ->
      do => node = this; node = node.parent while node.parent?

    Object.defineProperty @, "depth", enumerable: true, get: ->
      @ancestors.length

    @[key] = val for own key, val of props
    @type ?= @constructor.name
    @children ?= []

  addChild: (node) ->
    node.parent = this
    @children.push node
    return node

  getChildrenByType: (type) ->
    @children.filter (child) -> child.type is type

class RootNode extends Node

  addContextNode: (props) ->
    @addChild new ContextNode(props)

class ContextNode extends Node
  text: null
  depth: null

  addContextNode: (props) ->
    @addChild new ContextNode(props)

  addBeforeEachNode: (props) ->
    @addChild new BeforeEachNode(props)

  addFileNode: (props) ->
    @addChild new FileNode(props)

  addAssertionNode: (props) ->
    @addChild new AssertionNode(props)

class BeforeEachNode extends Node
  code: null

class FileNode extends Node
  path: null
  data: null

class AssertionNode extends Node
  text: null
  code: null

class DepthError extends Error
  constructor: ({previous, heading}) ->
    @previous = previous
    @heading = heading
    @name = @constructor.name
    Error.captureStackTrace @, @constructor
    @message = @getMessage()

  getMessage: ->
    "Invalid heading depth (#{@heading.depth}) for heading '#{@heading.text}'."

class Parser

  isAssertionCode: (code) ->
    /# =>/.test code

  isAssertionNext: (tokens) ->
    return false unless tokens.length > 1
    {type, text} = tokens[1]
    tokens[0].type is "paragraph" and type is "code" and @isAssertionCode text

  consumeNextAssertion: (contextNode, tokens) ->
    [para, code] = tokens.splice 0, 2
    contextNode.addAssertionNode text: para.text, code: code.text

  isFileCode: (code) ->
    /^.* file: "([^"]*)"/.test code

  isFileNext: (tokens) ->
    return false unless tokens.length
    {type, text} = tokens[0]
    type is "code" and @isFileCode text

  consumeNextFile: (contextNode, tokens) ->
    {text} = tokens.shift()
    path = /^.*file: "([^"]*)"/.exec(text)[1]
    data = text.split("\n").slice(2).join("\n")
    contextNode.addFileNode path: path, data: data

  isBeforeEachNext: (tokens) ->
    return false unless tokens.length
    {type, text} = tokens[0]
    type is "code" and !@isAssertionCode(text) and !@isFileCode(text)

  consumeNextBeforeEach: (contextNode, tokens) ->
    code = tokens.shift()
    contextNode.addBeforeEachNode code: code.text

  getParentNode: (headingToken, rootNode, previousContextNode) ->
    previousNode = (previousContextNode or rootNode)
    depthDiff = previousNode.depth - headingToken.depth

    return previousNode if depthDiff is -1
    return previousNode.ancestors[depthDiff] if depthDiff >= 0
    throw new DepthError headingToken: headingToken, previousNode: previousNode

  parseContextChildTokens: (contextNode, tokens) ->
    return contextNode unless tokens.length

    switch
      when @isAssertionNext(tokens) then @consumeNextAssertion(contextNode, tokens)
      when @isFileNext(tokens) then @consumeNextFile(contextNode, tokens)
      when @isBeforeEachNext(tokens) then @consumeNextBeforeEach(contextNode, tokens)
      else tokens.shift()

    @parseContextChildTokens contextNode, tokens

  parse: (tokens, rootNode = (new RootNode), previousContextNode) ->
    headingToken = tokens.find ({type}) -> type is "heading"
    return rootNode unless headingToken?

    tokens = tokens.slice (tokens.indexOf(headingToken) + 1)
    childTokens = do -> tokens.shift() while tokens.length and tokens[0].type isnt "heading"

    parentNode = @getParentNode headingToken, rootNode, previousContextNode
    contextNode = parentNode.addContextNode text: headingToken.text
    @parseContextChildTokens contextNode, childTokens
    @parse tokens, rootNode, contextNode

test = ->

  markdown = require("fs").readFileSync("example.md").toString()
  tokens = require("marked").lexer markdown
  parser = new Parser
  parser.parse tokens

results = test()
console.log JSON.stringify(results,null,2)
