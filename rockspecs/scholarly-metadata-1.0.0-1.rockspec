package = "scholarly-metadata"
version = "1.0.0-1"

source = {
  url = "git://github.com/pandoc-scholar/scholarly-metadata",
  tag = "v1.0.0",
}

description = {
  summary = "Utilities for scientific metadata handing with pandoc",
  homepage = "https://github.com/pandoc-scholar/scholarly-metadata",
  license = "ISC",
}

dependencies = {
  "lua >= 5.1",
  "dkjson >= 1.0",
  "panlunatic >= 0.2.1",
}

build = {
  type = "builtin",
  modules = {
    ["scholarlymeta"] = "src/scholarlymeta.lua",
    ["cito"] = "src/cito.lua",
  },
}
