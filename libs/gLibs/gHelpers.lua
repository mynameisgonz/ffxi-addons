
texts = require('texts')
images = require('images')

function print(addonName,msg)
	windower.add_to_chat(8, addonName .. ": " .. tostring(msg))
end

function debug(msg)
	if debugging then
		windower.add_to_chat(8, tostring(msg))
	end
end

function new_image(pos_x,pos_y,size_w,size_h,path,c,drag)
	local new_image = images.new({
		pos = {x=pos_x,y=pos_y},
		visible = true,
		color = c,
		size = {width=size_w,height=size_h},
		texture = {path=windower.addon_path.. path,fit=true},
		repeatable = {x=1,y=1},
		draggable = drag
	})
	
	return new_image
end

function new_text_list_item(t,pos_x,pos_y)
	local new_text = texts.new(t, {
		pos = {x=pos_x,y=pos_y},
		text = {size=10,font='sans-serif',stroke={width=2,alpha=255,red=0,green=0,blue=0},red=215,green=215,blue=215},
		flags = {bold=false,draggable=false,italic=false},
		bg = {visible=false,red=0,green=0,blue=0,alpha=200,},
		padding = 3
	})
	return new_text
end

function new_text_title(t,pos_x,pos_y)
	local new_text = texts.new(t, {
		pos = {x=pos_x,y=pos_y},
		text = {size=12,font='sans-serif',stroke={width=0,alpha=0,red=0,green=0,blue=0},red=255,green=255,blue=255},
		flags = {bold=true,draggable=true,italic=false},
		bg = {visible=false,red=0,green=0,blue=0,alpha=200,},
		padding = 3
	})
	return new_text
end

function distance_from(A, B)
  local dx = B.x-A.x
  local dy = B.y-A.y
  return math.sqrt(dx*dx + dy*dy)
end	

function color_text(str,r,g,b)
	local text = "\\cs(" .. r .. "," .. g .. "," .. b .. ")" .. str .. "\\cr":format(str)
    return text
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function removeSubString(s,txt)
    return s:gsub("%" .. txt, "")
end

function IsNumeric(str)
  return not (str == "" or str:find("%D"))  -- str:match("%D") also works
end