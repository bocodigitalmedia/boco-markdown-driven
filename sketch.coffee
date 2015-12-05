filename = process.argv[2] ? "example.md"
MarkdownDriven = require '.'
parser = new MarkdownDriven.Parser nativeLanguages: ["coffee"]
lexer = new (require("marked")).Lexer 
tokens = lexer.lex require("fs").readFileSync(filename).toString()
tree = parser.parse tokens
console.log JSON.stringify(tree, null, 2)
