local lgi = require 'lgi'
local Gtk = lgi.require 'Gtk'
local cairo = lgi.cairo
local Gdk = lgi.Gdk

local parser = require 'slajd.parser'
local utils = require 'slajd.utils'

local window, header, canvas, data, slide

-- initially show the first slide
slide = 1

-- load slide data from suplied file name

if #arg < 1 then
  print("Needs one argument (the file to open).")
  return
end

if string.sub(arg[1], -3, -1) == "lua" then
  data = dofile(arg[1])
else
  local file = io.open(arg[1])
  local txt = file:read("*all")
  file:close()
  data = parser.parse(txt)
end

-- create Gtk.HeaderBar instance
header = Gtk.HeaderBar {
  title = 'slajd',
  show_close_button = true
}

-- create Gtk.DrawingArea instance
canvas = Gtk.DrawingArea {
  expand = true
}

-- take image source string and create a ImageSurface from that source
function load_images()
  for i,v in pairs(data) do
    if v.image ~= nil then
      data[i].cairo_image = cairo.ImageSurface.create_from_png(v.image)
    end
  end
end

-- when the data is loaded, append images
load_images()

-- drawing on DrawingArea
function canvas:on_draw(cr)
  local width = self.width
  local height = self.height

  -- check if background color is overriden for current slide
  if data[slide].background then
    cr:set_source_rgb(data[slide].background[1],data[slide].background[2],data[slide].background[3])
  else
    cr:set_source_rgb(data.theme.background[1],data.theme.background[2],data.theme.background[3])
  end

  cr:fill()
  cr:paint()

  -- the slide contains an image
  if data[slide].image ~= nil then
    cr:save()
    local image_w, image_h = data[slide].cairo_image.width, data[slide].cairo_image.height
    -- cr:scale(width/image_w, height/image_h)
    cr:set_source_surface(data[slide].cairo_image, (width - image_w)/2,(height - image_h)/2)
    cr:paint()
    cr:restore() -- reset transformations to latest save
  end

  -- check if the foreground color is overriden by the current slide
  if data[slide].foreground then
    cr:set_source_rgb(data[slide].foreground[1],data[slide].foreground[2],data[slide].foreground[3])
  else
    cr:set_source_rgb(data.theme.foreground[1],data.theme.foreground[2],data.theme.foreground[3])
  end

  -- set font
  if data.theme.font then
    cr.font_face = cairo.ToyFontFace.create(data.theme.font, cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL)
  else
    cr.font_face = cairo.ToyFontFace.create("Arial", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL)
  end

  if data[slide].title and (not (data[slide].text or data[slide].lines)) then -- title only
    cr:save()
    local t_lines
    if type(data[slide].title) == "string" then
      t_lines = utils.split(data[slide].title)
    elseif type(data[slide].title) == "table" then
      t_lines = data[slide].title
    end
    local llen, li = utils.lll(t_lines)
    local fsize = height/(llen/2)
    cr:set_font_size(fsize)
    local lext = cr:text_extents(t_lines[li])
    for j,str in pairs(t_lines) do
      local extents = cr:text_extents(str)
      local horiz_pos = width/2 - (extents.width/2 + extents.x_bearing)
      cr:move_to(horiz_pos, height/2 + j*fsize - (#t_lines * fsize)/2)
      cr:show_text(str)
    end
    cr:restore()
  elseif data[slide].title and (data[slide].text or data[slide].lines) then -- text and title
    cr:save()
    -- cr.font_face = cairo.ToyFontFace.create("Fira Code Light", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL)
    -- title part
    if type(data[slide].title) == "string" then
      t_lines = utils.split(data[slide].title)
    elseif type(data[slide].title) == "table" then
      t_lines = data[slide].title
    end
    local llen, li = utils.lll(t_lines)
    local fsize = (height * (1/4))/(llen/2)
    cr:set_font_size(fsize)
    local lext = cr:text_extents(t_lines[li])
    for j,str in pairs(t_lines) do
      local extents = cr:text_extents(str)
      local horiz_pos = width/2 - (extents.width/2 + extents.x_bearing)
      cr:move_to(horiz_pos, (height * 1/4)/2 + j*fsize - (#t_lines * fsize)/2)
      cr:show_text(str)
    end
    -- text part
    local split_strs
    if data[slide].lines ~= nil then
      split_strs = data[slide].lines
    else
      split_strs = utils.split(data[slide].text)
    end
    llen, li = utils.lll(split_strs)
    local fsize = height / (llen/2)
    cr:set_font_size(fsize)
    lext = cr:text_extents(split_strs[li]) -- get extents after setting the font size!
    for j, str in pairs(split_strs) do
      local extents = cr:text_extents(str)
      local horiz_pos = width/2 - (lext.width/2 + lext.x_bearing)
      cr:move_to(horiz_pos, (height / 2) + j*fsize - (#split_strs * fsize)/2)
      cr:show_text(str)
    end
    cr:restore()
  elseif (not data[slide].title) and (data[slide].text or data[slide].lines) then -- text only
    cr:save()
    -- cr.font_face = cairo.ToyFontFace.create("Fira Code Light", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL)
    local split_strs
    if data[slide].lines ~= nil then
      split_strs = data[slide].lines
    else
      split_strs = utils.split(data[slide].text)
    end
    local llen, li = utils.lll(split_strs)
    local fsize = height/(llen/2)
    cr:set_font_size(fsize)
    local lext = cr:text_extents(split_strs[li]) -- get extents after setting the font size!
    for j, str in pairs(split_strs) do
      local extents = cr:text_extents(str)
      local horiz_pos = width/2 - (lext.width/2 + lext.x_bearing)
      cr:move_to(horiz_pos, height/2 + j*fsize - (#split_strs * fsize)/2)
      cr:show_text(str)
    end
    cr:restore()
  end

  return true
end

-- create window
window = Gtk.Window {
  default_width = 600,
  default_height = 500,
  canvas
}

-- headerbar
window:set_titlebar(header)

-- destruction
function window:on_destroy()
  Gtk.main_quit()
end

-- keyboard events
function window:on_key_press_event(event)
  -- check for shift and control key
  local ctrl_on = event.state.CONTROL_MASK
  local shift_on = event.state.SHIFT_MASK
  if event.keyval == Gdk.KEY_Left then -- previous slide
    if slide > 1 then
      slide = slide - 1
      canvas:queue_draw()
    end
  elseif event.keyval == Gdk.KEY_Right then -- next slide
    if slide < #data then
      slide = slide + 1
      canvas:queue_draw()
    end
  elseif event.keyval == Gdk.KEY_F5 then -- refresh slides
    if string.sub(arg[1], -1, -3) == "lua" then
      data = dofile(arg[1])
    else
      local file = io.open(arg[1])
      local txt = file:read("*all")
      file:close()
      data = parser.parse(txt)
    end
    load_images()
    canvas:queue_draw()
  end
  return true
end

window:show_all()
Gtk:main()
