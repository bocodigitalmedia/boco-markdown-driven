  describe "Tokenizer", ->
    
    [MarkDownDriven, tokenizer] = []
    
    beforeEach (done) ->
      MarkDownDriven = require "boco-mdd"
      tokenizer = new MarkDownDriven.Tokenizer
      done()
    describe "Tokenizing Markdown", ->
      
      [markdown, tokens] = []
      
      beforeEach (done) ->
        markdown =
          """
          # Mather
        
          Mather is a library for doing math.
        
              Mather = require "mather"
              mather = new Mather
        
          ## example: adding numbers
        
              mather.add a, b # => 3
              mather.add c, d # => 7
          """
        
        tokens = tokenizer.tokenize markdown
        
        done()
      
      it "a heading is a context token", (done) ->
        expect(tokens[0].type).toEqual("context")
        expect(tokens[0].depth).toEqual(1)
        expect(tokens[0].text).toEqual("Mather")
        done()
      
      it "code is a code token", (done) ->
        expect(tokens[1].type).toEqual("code")
        expect(tokens[1].text[0...25]).toEqual('Mather = require "mather"')
        done()
      
      it "a heading, starting with \"example\" is an example token", (done) ->
        expect(tokens[2].type).toEqual("example")
        expect(tokens[2].depth).toEqual(2)
        expect(tokens[2].text).toEqual("example: adding numbers")
        done()
      
      it "code sections within examples are still just code tokens", (done) ->
        expect(tokens[3].type).toEqual("code")
        expect(tokens[3].text[0...22]).toEqual('mather.add a, b # => 3')
        done()
