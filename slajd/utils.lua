
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
  for float in string.gmatch(txt, "[^%s]+") do
    table.insert(nums, tonumber(float))
  end
  assert(#nums == 3, "parse_color: A color must consist of 3 floats between 0 and 1(inclusive).")
  return nums
end

return _M
