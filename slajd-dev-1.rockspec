package = "slajd"
version = "dev-1"

source = {
  url = "git://github.com/ruml/slajd.git"
}

description = {
  summary = "A tiny slideshow application",
  homepage = "https://github.com/ruml/slajd",
  maintainer = "Rok Fajfar <snewix7@gmail.com>",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
  "lgi"
}

build = {
  type = "builtin",
  modules = {
    ["slajd.slajd"] = "slajd/slajd.lua",
    ["slajd.utils"] = "slajd/utils.lua"
    ["slajd.parser"] = "slajd/parser.lua",
  },
  install = {
    bin = { "bin/slajd" }
  }
}
