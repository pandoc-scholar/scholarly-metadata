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
  "panlunatic >= 0.2.1",
  "dkjson >= 1.0",
}

build = {
  type = "builtin",
  copy_directories = { "writers" },
  modules = {
    ["panmeta"] = "src/scholarlymeta.lua",
    ["cito"] = "src/cito.lua",
  },
}
