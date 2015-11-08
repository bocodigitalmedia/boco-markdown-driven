jasmine = new (require("jasmine"))

jasmine.loadConfig
  "spec_dir": "spec",
  "spec_files": ["**/*-spec.coffee"]

jasmine.execute()
