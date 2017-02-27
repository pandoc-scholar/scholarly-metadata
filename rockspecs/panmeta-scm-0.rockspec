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
  "panlunatic >= 0.2.1",
  "dkjson >= 1.0",
}

build = {
  type = "builtin",
  copy_directories = { "writers" },
  modules = {
    ["panmeta"] = "src/panmeta.lua",
    ["cito"] = "src/cito.lua",
  },
}
