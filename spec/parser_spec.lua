
local serpent = require 'serpent'
local parser = require 'slajd.lpeg_parser'

local file = assert(io.open("examples/example.txt"))
local data = file:read("*all")
file:close()

local slides = parser.parse(data)

print(serpent.block(slides, {comment = false}))
