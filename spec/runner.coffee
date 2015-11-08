Jasmine = require "jasmine"
Path = require "path"

exports.run = ->
  jasmine = new Jasmine
  configFilePath = require("path").resolve __dirname, "..", "spec", "support", "jasmine.json"
  jasmine.loadConfigFile configFilePath
  jasmine.execute()

exports.run() unless module.parent?
