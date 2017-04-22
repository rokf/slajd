package = "slajd"
version = "dev-3"

source = {
  url = "git://github.com/rokf/slajd.git"
}

description = {
  summary = "A tiny slideshow application",
  homepage = "https://github.com/rokf/slajd",
  maintainer = "Rok Fajfar <snewix7@gmail.com>",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
  "lgi",
  "lfs"
}

build = {
  type = "builtin",
  modules = {
    ["slajd.slajd"] = "slajd/slajd.lua",
    ["slajd.utils"] = "slajd/utils.lua",
    ["slajd.lpeg_parser"] = "slajd/lpeg_parser.lua",
  },
  install = {
    bin = { "bin/slajd" }
  }
}
