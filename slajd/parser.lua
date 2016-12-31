-- textual slide representation parser module

local utils = require 'slajd.utils'

local _M = {}

local processor = {
  image = function (txt)
    return string.sub(txt,2,-2)
  end,
  title = function (txt)
    return string.sub(txt,2,-2)
  end,
  text = function (txt)
    return string.sub(txt, 1, -2)
  end,
  font = function (txt)
    return string.sub(txt,2,-2)
  end,
  color = function (txt) -- either foreground or background
    local location, color
    if string.sub(txt, 2,2) == "f" then
      location = "foreground"
    else
      location = "background"
    end
    color = utils.parse_color(string.sub(txt, 3,-2))
    return color, location
  end
}

function _M.parse(text)
  local data, slide, line_n = {}, {}, 0
  data.theme = {}
  for line in string.gmatch(text, "([^\n]*\n)") do
    line_n = line_n + 1
    if line == "\n" and line_n >= 3 then
      table.insert(data,slide)
      slide = {}
    else
      local fst = string.sub(line, 1, 1)
      if fst == "#" then -- title
        if not slide.title then
          slide.title = {}
        end
        table.insert(slide.title, processor.title(line))
      elseif fst == "&" then -- font
        data.theme.font = processor.font(line)
      elseif fst == "$" then -- image
        slide.image = processor.image(line)
      elseif fst == "%" then -- color
        local color, location = processor.color(line)
        if line_n <= 3 then
          data.theme[location] = color
        else
          slide[location] = color
        end
      else -- text
        if line ~= "\n" then
          if not slide.lines then
            slide.lines = {}
          end
          table.insert(slide.lines, processor.text(line))
        end
      end
    end
  end
  table.insert(data,slide) -- last slide
  return data
end

return _M
