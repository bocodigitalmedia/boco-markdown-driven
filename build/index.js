// Generated by CoffeeScript 1.10.0
var configure,
  hasProp = {}.hasOwnProperty,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

configure = function($) {
  var JasmineCoffeeParser, JasmineConverter, Tokenizer;
  if ($ == null) {
    $ = {};
  }
  if ($.assign == null) {
    $.assign = function(target, source) {
      var key, results, val;
      results = [];
      for (key in source) {
        if (!hasProp.call(source, key)) continue;
        val = source[key];
        results.push(target[key] = val);
      }
      return results;
    };
  }
  if ($.require == null) {
    $.require = function(path) {
      return require(path);
    };
  }
  Tokenizer = (function() {
    Tokenizer.prototype.marked = null;

    function Tokenizer(props) {
      $.assign(this, props);
      if (this.marked == null) {
        this.marked = $.require("marked");
      }
    }

    Tokenizer.prototype.isExampleToken = function(mdToken) {
      return mdToken.type === "heading" && /^example/i.test(mdToken.text);
    };

    Tokenizer.prototype.isContextToken = function(mdToken) {
      return mdToken.type === "heading" && !this.isExampleToken(mdToken);
    };

    Tokenizer.prototype.isCodeToken = function(mdToken) {
      return mdToken.type === "code";
    };

    Tokenizer.prototype.createExampleToken = function(mdToken) {
      return {
        type: "example",
        text: mdToken.text,
        depth: mdToken.depth
      };
    };

    Tokenizer.prototype.createContextToken = function(mdToken) {
      return {
        type: "context",
        text: mdToken.text,
        depth: mdToken.depth
      };
    };

    Tokenizer.prototype.createCodeToken = function(mdToken) {
      return {
        type: "code",
        text: mdToken.text
      };
    };

    Tokenizer.prototype.processMarkdownToken = function(tokens, mdToken) {
      var createToken;
      createToken = (function() {
        switch (false) {
          case !this.isExampleToken(mdToken):
            return this.createExampleToken;
          case !this.isContextToken(mdToken):
            return this.createContextToken;
          case !this.isCodeToken(mdToken):
            return this.createCodeToken;
        }
      }).call(this);
      if (createToken != null) {
        tokens = tokens.concat(createToken(mdToken));
      }
      return tokens;
    };

    Tokenizer.prototype.tokenizeMarkdown = function(markdown) {
      return this.marked.lexer(markdown);
    };

    Tokenizer.prototype.tokenize = function(markdown) {
      var mdTokens;
      mdTokens = this.tokenizeMarkdown(markdown);
      return mdTokens.reduce(this.processMarkdownToken.bind(this), []);
    };

    return Tokenizer;

  })();
  JasmineConverter = (function() {
    function JasmineConverter(props) {
      if (props == null) {
        props = {};
      }
    }

    JasmineConverter.prototype.createDescribeToken = function(arg) {
      var depth, text;
      depth = arg.depth, text = arg.text;
      return {
        type: "describe",
        depth: depth,
        text: text
      };
    };

    JasmineConverter.prototype.createVarsToken = function(arg) {
      var depth, vars;
      depth = arg.depth, vars = arg.vars;
      return {
        type: "vars",
        depth: depth,
        vars: vars
      };
    };

    JasmineConverter.prototype.createBeforeEachToken = function(arg) {
      var code, depth;
      depth = arg.depth, code = arg.code;
      return {
        type: "beforeEach",
        depth: depth,
        code: code
      };
    };

    JasmineConverter.prototype.createItToken = function(arg) {
      var depth, text;
      depth = arg.depth, text = arg.text;
      return {
        type: "it",
        depth: depth,
        text: text
      };
    };

    JasmineConverter.prototype.createAssertionToken = function(arg) {
      var code, depth;
      depth = arg.depth, code = arg.code;
      return {
        type: "assertion",
        depth: depth,
        code: code
      };
    };

    JasmineConverter.prototype.getVariableNames = function(code) {
      var tokens;
      tokens = require("coffee-script").tokens(code);
      tokens = tokens.filter(function(token) {
        return token[0] === "IDENTIFIER" && token.variable;
      });
      return tokens.map(function(token) {
        return token[1];
      });
    };

    JasmineConverter.prototype.convert = function(tokens) {
      var currentContext, currentDepth, reduceTokens;
      currentDepth = 0;
      currentContext = null;
      reduceTokens = (function(_this) {
        return function(tokens, token) {
          var vars;
          if (token.depth != null) {
            currentDepth = token.depth;
          }
          if (token.type === "context") {
            currentContext = "describe";
            tokens.push(_this.createDescribeToken(token));
          }
          if (token.type === "example") {
            currentContext = "it";
            tokens.push(_this.createItToken(token));
          }
          if (token.type === "code" && currentContext === "describe") {
            vars = _this.getVariableNames(token.text);
            tokens.push(_this.createVarsToken({
              vars: vars,
              depth: currentDepth + 1
            }));
            tokens.push(_this.createBeforeEachToken({
              code: token.text,
              depth: currentDepth + 1
            }));
          }
          if (token.type === "code" && currentContext === "it") {
            tokens.push(_this.createAssertionToken({
              code: token.text,
              depth: currentDepth + 1
            }));
          }
          return tokens;
        };
      })(this);
      return tokens.reduce(reduceTokens, []);
    };

    return JasmineConverter;

  })();
  JasmineCoffeeParser = (function() {
    function JasmineCoffeeParser(props) {
      if (props == null) {
        props = {};
      }
    }

    JasmineCoffeeParser.prototype.parse = function(tokens) {
      var addAssertionDone, addSnippet, declared, indent, replaceAssertionComments, snippets;
      declared = ['require', 'console', 'module', 'process'];
      snippets = [];
      indent = function(code, depth) {
        var i, indentation, j, ref;
        indentation = "";
        for (i = j = 1, ref = depth; 1 <= ref ? j < ref : j > ref; i = 1 <= ref ? ++j : --j) {
          indentation += "  ";
        }
        return code.replace(/^/gm, indentation);
      };
      addSnippet = function(code, depth) {
        code = indent(code, depth);
        return snippets.push(code);
      };
      replaceAssertionComments = function(code) {
        var pattern;
        pattern = /( +)(.*) # => (.*)/;
        return code.replace(pattern, "$1expect($2).toEqual($3)");
      };
      addAssertionDone = function(code) {
        var lastSpacing, match, pattern;
        pattern = /^( +)([^ ]+)/gm;
        while (match = pattern.exec(code)) {
          lastSpacing = match[1];
        }
        return code += "\n" + lastSpacing + "done()";
      };
      tokens.forEach(function(token) {
        var code, vars;
        if (token.type === "describe") {
          code = "describe \"" + token.text + "\", ->";
          addSnippet(code, token.depth);
        }
        if (token.type === "vars") {
          vars = [];
          token.vars.forEach(function(v) {
            if (!(indexOf.call(vars, v) >= 0 || indexOf.call(declared, v) >= 0)) {
              vars.push(v);
            }
            if (indexOf.call(declared, v) < 0) {
              return declared.push(v);
            }
          });
          code = "[" + (vars.join(",")) + "] = []";
          addSnippet(code, token.depth);
        }
        if (token.type === "beforeEach") {
          code = "beforeEach ->\n";
          code += indent(token.code, 2);
          addSnippet(code, token.depth);
        }
        if (token.type === "it") {
          code = "it \"" + token.text + "\", (done) ->";
          addSnippet(code, token.depth);
        }
        if (token.type === "assertion") {
          code = replaceAssertionComments(token.code);
          code = addAssertionDone(code);
          return addSnippet(code, token.depth);
        }
      });
      return snippets.join("\n\n");
    };

    return JasmineCoffeeParser;

  })();
  return {
    JasmineCoffeeParser: JasmineCoffeeParser,
    JasmineConverter: JasmineConverter,
    Tokenizer: Tokenizer
  };
};

module.exports = configure();

//# sourceMappingURL=index.js.map