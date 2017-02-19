package = "panmeta"
version = "scm-0"

source = {
  url = "git://github.com/formatting-science/panmeta"
}

description = {
  summary = "Utilities for scientific publishing with pandoc",
  homepage = "https://github.com/formatting-science/panmeta",
  license = "ISC",
}

dependencies = {
  "lua >= 5.1",
  "panlunatic >= 1.0",
  "dkjson >= 1.0",
}

build = {
  type = "builtin",
  modules = {
    panmeta = "src/panmeta.lua",
  },
}
