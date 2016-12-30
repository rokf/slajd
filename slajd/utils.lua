
local _M = {}

_M.split = function(str)
  local t = {}
  for line in str:gmatch("([^\n]+)") do
    table.insert(t,line)
  end
  return t
end

_M.lll = function (t)
  local l, li = 0, 0
  for i,v in pairs(t) do
    if #v > l then l = #v; li = i end
  end
  return l, li
end

_M.parse_color = function (txt)
  local nums = {}
  for numstr in string.gmatch(txt, "[^%s]+") do
    local num = tonumber(numstr)
    if num <= 1 and num >= 0 then
      table.insert(nums, num)
    elseif num > 1 and num < 256 then
      table.insert(nums, num/255)
    else
      error("parse_color: A color number was either too big or negative.")
    end
  end
  assert(#nums == 3, "parse_color: A color must consist of 3 floats [0,1] or 3 integers (1,255].")
  return nums
end

return _M
