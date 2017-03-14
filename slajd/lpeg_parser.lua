
local lpeg = require 'lpeg'

local P,R,S,V =
  lpeg.P,
  lpeg.R,
  lpeg.S,
  lpeg.V

local C,Ct,Cp,Cg,Cc =
  lpeg.C,
  lpeg.Ct,
  lpeg.Cp,
  lpeg.Cg,
  lpeg.Cc

local capture = {}
function capture.cloc(char)
  if char == "b" then
    return "background"
  else
    return "foreground"
  end
end

function capture.title(txt)
  return { type = "title", txt }
end

function capture.font(txt)
  return { type = "font", txt }
end

function capture.image(txt)
  return { type = "image", txt }
end

function capture.text(txt)
  return { type = "text", txt }
end

local grammar = P {
  "presentation",
  presentation = Ct((V('slide') * (P('\n') + P(-1)))^1),
  slide = Ct(V('line')^1),
  line = (V('title') + V('font') + V('color') + V('image') + V('text')) * (P('\n') + P(-1)),
  title = P('#') * P(' ')^0 * ((P(1) - P('\n'))^1 / capture.title),
  font = P('&') * P(' ')^0 * ((P(1) - P('\n'))^1 / capture.font),
  color = P('%') * Ct(Cg((S('bf') / capture.cloc), "type") * P(' ')^0 * Ct((C(V('number')) * P(' ')^0)^-3)),
  image = P('$') * P(' ')^0 * ((P(1) - P('\n'))^1 / capture.image),
  text = ((P(1) - P('\n'))^1 / capture.text),
  number = ((V('float') + V('integer') + P('0')) / tonumber),
  float = (S('0') + V('integer')) * P('.') * R('09')^1,
  integer = R('19') * R('09')^0,
  ws = S(' \n\r\t')^0,
}

local PARSER = {}

function PARSER.parse(txt)
  return grammar:match(txt)
end

return PARSER
