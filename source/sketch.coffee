JDD = require "./"
tokenizer = new JDD.Tokenizer
sourcePath = require("path").resolve __dirname, "..", "docs", "math.coffee.md"
sourceData = require("fs").readFileSync(sourcePath).toString()
tokens = tokenizer.tokenize sourceData

console.log tokens

converter = new JDD.JasmineConverter
tokens = converter.convert tokens

console.log tokens

parser = new JDD.JasmineCoffeeParser
jasmine = parser.parse tokens

console.log jasmine
