configure = ($ = {}) ->

  $.reduceUnique ?= (arr, v) ->
    arr.push(v) if arr.indexOf(v) is -1
    arr

  $.globalVariables ?= ["require", "jasmine"]

  class Snippets
    snippets: null
    indentationString: null

    constructor: (props = {}) ->
      @[key] = val for own key, val of props
      @snippets ?= []
      @indentationString ?= "  "

    indent: (code, depth) ->
      indentation = [0...depth].map(=> @indentationString).join('')
      code.replace /^/gm, indentation

    add: (code, depth = 0) ->
      @snippets.push @indent(code, depth)

    compile: (joinStr = "\n\n") ->
      @snippets.join(joinStr) + "\n"

  class CoffeeToken
    type: null
    value: null
    variable: null
    firstLine: null
    firstColumn: null
    lastLine: null
    lastColumn: null

    constructor: (props = {}) ->
      @[key] = val for own key, val of props

    @isVariable: (token) ->
      token.type is "IDENTIFIER" and token.variable

    @getValue: (token) ->
      token.value

    @convert: (csToken) ->
      new CoffeeToken type: csToken[0], value: csToken[1], variable: csToken.variable

  class CoffeeService
    globalVariables: null

    constructor: (props) ->
      @[key] = val for own key, val of props
      @globalVariables ?= $.globalVariables

    tokenize: (code) ->
      require('coffee-script').tokens(code).map CoffeeToken.convert

    getVariableNames: (code) ->
      tokens = @tokenize(code).filter CoffeeToken.isVariable
      names = tokens.map CoffeeToken.getValue
      names.reduce $.reduceUnique, []

    isGlobalVariable: (v) ->
      v in @globalVariables

  class JasmineCoffeeCompiler
    coffeeService: null

    constructor: (props = {}) ->
      @[key] = val for own key, val of props
      @coffeeService ?= new CoffeeService

    getContextVariableNames: (node) ->
      beforeEachNodes = node.getBeforeEachNodes()
      code = beforeEachNodes.map(({code}) -> code).join("\n")
      vars = @coffeeService.getVariableNames code

      if (ancestors = node.getAncestorContexts())?
        reduceAncestorVars = (vars, ancestor) => vars.concat @getContextVariableNames(ancestor)
        ancestorVars = ancestors.reduce reduceAncestorVars, []
        vars = vars.filter (v) -> ancestorVars.indexOf(v) is -1

      vars.filter (v) => !@coffeeService.isGlobalVariable(v)

    compileFileNodes: (snippets, nodes) ->
      return snippets unless nodes.length

      depth = nodes[0].depth
      mockFsObject = nodes.reduce ((memo, {path, data}) -> memo[path] = data), {}
      mockFsString = JSON.stringify mockFsObject, null, 2

      snippets.add "beforeEach ->", depth
      snippets.add "mockFsObject = #{mockFsString}", depth + 1
      snippets.add "require('mock-fs')(mockFsObject)", depth + 1
      snippets.add "afterEach ->", depth
      snippets.add "require('mock-fs').restore()", depth + 1
      snippets

    compileBeforeEachNodes: (snippets, nodes) ->
      return snippets unless nodes.length

      depth = nodes[0].depth
      code = nodes.map(({code}) -> code).join("\n")

      snippets.add "beforeEach ->", depth
      snippets.add code, depth + 1
      snippets

    compileAssertionNode: (snippets, node) ->
      {depth, text, code} = node
      snippets.add "it #{JSON.stringify(text)} ->", depth
      snippets.add code, depth + 1
      snippets

    compileAssertionNodes: (snippets, nodes) ->
      return snippets unless nodes.length
      nodes.reduce @compileAssertionNode.bind(@), snippets

    compileContextNode: (snippets, node) ->
      vars = @getContextVariableNames node
      snippets.add "describe #{JSON.stringify(node.text)} ->", node.depth
      snippets.add "[#{vars.join(', ')}] = []", node.depth + 1 if vars.length

      snippets = @compileBeforeEachNodes snippets, node.getBeforeEachNodes()
      snippets = @compileFileNodes snippets, node.getFileNodes()
      snippets = @compileAssertionNodes snippets, node.getAssertionNodes()
      snippets = @compileContextNodes snippets, node.getContextNodes()
      snippets

    compileContextNodes: (snippets, nodes) ->
      return snippets unless nodes.length
      nodes.reduce @compileContextNode.bind(@), snippets

    compile: (rootNode) ->
      snippets = @compileContextNodes new Snippets(), rootNode.getContextNodes()
      snippets.compile()

  JasmineCoffee =
    configuration: $
    configure: configure
    JasmineCoffeeCompiler: JasmineCoffeeCompiler
    CoffeeService: CoffeeService
    CoffeeToken: CoffeeToken
    Snippets: Snippets

module.exports = configure()
