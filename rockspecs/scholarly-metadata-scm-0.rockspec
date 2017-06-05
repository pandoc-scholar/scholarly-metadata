package = "scholarly-metadata"
version = "scm-0"

source = {
  url = "git://github.com/pandoc-scholar/scholarly-metadata"
}

description = {
  summary = "Utilities for scientific publishing with pandoc",
  homepage = "https://github.com/pandoc-scholar/scholarly-metadata",
  license = "ISC",
}

dependencies = {
  "lua >= 5.1",
  "panlunatic >= 1.0.0",
  "dkjson >= 1.0",
}

build = {
  type = "builtin",
  modules = {
    ["scholarlymeta"] = "src/scholarlymeta.lua",
    ["cito"] = "src/cito.lua",
    ["titleblocks"] = "src/titleblocks.lua",
  },
}
