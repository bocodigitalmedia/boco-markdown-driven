Jasmine = require "jasmine"
Path = require "path"
argv = require("yargs").argv

specDir = argv.specDir ? "spec"
specFiles = argv._ unless argv._.length is 0
specFiles ?= ["**/*[Ss]pec.?(coffee|js)"]

exports.run = ->
  jasmine = new Jasmine

  jasmine.loadConfig
    "spec_dir": specDir,
    "spec_files": specFiles

  jasmine.execute()

exports.run() unless module.parent?
