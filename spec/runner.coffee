Jasmine = require "jasmine"
Path = require "path"
argv = require("yargs").array("specFiles").argv

specDir = argv.specDir ? "spec"
specFiles = argv.specFiles ? ["**/*-[sS]pec.?(coffee|js)"]

console.log specDir: specDir, specFiles: specFiles

exports.run = ->
  jasmine = new Jasmine

  jasmine.loadConfig
    "spec_dir": specDir,
    "spec_files": specFiles

  jasmine.execute()

exports.run() unless module.parent?
