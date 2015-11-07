Jasmine = require "jasmine"
jasmine = new Jasmine
configPath = require("path").resolve __dirname, "support", "jasmine.json"
jasmine.loadConfigFile configPath
jasmine.execute()
