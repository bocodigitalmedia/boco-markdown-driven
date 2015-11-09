Jasmine = require "jasmine"
Path = require "path"
argv = require("yargs")
  .default("specDir", "spec")
  .argv

specFiles = argv._ unless argv._.length is 0
specFiles ?= ["**/*[Ss]pec.?(coffee|js)"]

exports.run = ->
  jasmine = new Jasmine

  jasmine.loadConfig
    spec_dir: argv.specDir
    spec_files: specFiles

  jasmine.execute()

exports.run() unless module.parent?
