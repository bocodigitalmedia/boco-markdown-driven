MarkdownDriven = require './source'
parser = new MarkdownDriven.Parser nativeLanguages: ["coffee"]
lexer = new (require("marked")).Lexer 
tokens = lexer.lex require("fs").readFileSync("example.md").toString()
tree = parser.parse tokens
console.log JSON.stringify(tree, null, 2)
