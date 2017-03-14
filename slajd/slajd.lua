local lgi = require 'lgi'
local Gtk = lgi.require 'Gtk'
local cairo = lgi.cairo
local Gdk = lgi.Gdk

local parser = require 'slajd.lpeg_parser'
local utils = require 'slajd.utils'

local window, header, canvas
local slide = 1
local data = {}
local images = {}
local theme = {}

if #arg < 1 then
  print('Run with: slajd _path_to_file_')
  return
end

local file = io.open(arg[1])
local txt = file:read("*all")
file:close()
data = parser.parse(txt)

-- create Gtk.HeaderBar instance
header = Gtk.HeaderBar {
  title = 'slajd',
  show_close_button = true
}

-- create Gtk.DrawingArea instance
canvas = Gtk.DrawingArea {
  expand = true
}

function load_theme()
  local tslide = data[1]
  for _,line in ipairs(tslide) do
    if line.type == "background" then
      theme.background = line[1]
    elseif line.type == "foreground" then
      theme.foreground = line[1]
    elseif line.type == "font" then
      theme.font = line[1]
    end
  end
  table.remove(data,1)
end

function load_images()
  for _,s in ipairs(data) do
    for _,l in ipairs(s) do
      if l.type == "image" then
        if images[l[1]] == nil then
          images[l[1]] = cairo.ImageSurface.create_from_png(l[1])
        end
      end
    end
  end
end

load_theme()
load_images()

function canvas:on_draw(cr)
  local width = self.width
  local height = self.height
  local sd = {}

  for _,line in ipairs(data[slide]) do
    if line.type == "background" then
      sd.background = line[1]
    elseif line.type == "foreground" then
      sd.foreground = line[1]
    elseif line.type == "text" then
      if sd.text == nil then
        sd.text = {}
      end
      table.insert(sd.text,line[1])
    elseif line.type == "title" then
      if sd.title == nil then
        sd.title = {}
      end
      table.insert(sd.title,line[1])
    elseif line.type == "image" then
      sd.image = line[1]
    end
  end

  if sd.background then
    cr:set_source_rgb(sd.background[1],sd.background[2],sd.background[3])
  else
    cr:set_source_rgb(theme.background[1],theme.background[2],theme.background[3])
  end

  cr:fill()
  cr:paint()

  if sd.image ~= nil then
    cr:save()
    local image_w, image_h = images[sd.image].width, images[sd.image].height
    -- cr:scale(width/image_w, height/image_h)
    cr:set_source_surface(images[sd.image], (width - image_w)/2,(height - image_h)/2)
    cr:paint()
    cr:restore()
  end

  if sd.foreground then
    cr:set_source_rgb(sd.foreground[1],sd.foreground[2],sd.foreground[3])
  else
    cr:set_source_rgb(theme.foreground[1],theme.foreground[2],theme.foreground[3])
  end

  if theme.font then
    cr.font_face = cairo.ToyFontFace.create(theme.font, cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL)
  else
    cr.font_face = cairo.ToyFontFace.create("Arial", cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL)
  end

  if sd.title and (not sd.text) then -- title only
    cr:save()
    local t_lines
    t_lines = sd.title
    local llen, li = utils.lll(t_lines)
    local fsize = height/(llen/3)
    cr:set_font_size(fsize)
    local lext = cr:text_extents(t_lines[li])
    for j,str in pairs(t_lines) do
      local extents = cr:text_extents(str)
      local horiz_pos = width/2 - (extents.width/2 + extents.x_bearing)
      cr:move_to(horiz_pos, height/2 + j*fsize - (#t_lines * fsize)/2)
      cr:show_text(str)
    end
    cr:restore()
  elseif sd.title and sd.text then -- text and title
    cr:save()
    t_lines = sd.title
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

    local split_strs
    split_strs = sd.text
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
  elseif (not sd.title) and sd.text then -- text only
    cr:save()
    local split_strs = sd.text
    local llen, li = utils.lll(split_strs)
    local fsize = height/(llen/3)
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
    load_theme()
    load_images()
    canvas:queue_draw()
  end
  return true
end

window:show_all()
Gtk:main()
