_addon.author = 'Mynameisgonz'
_addon.commands = {'gGEO','ggeo'}
_addon.name = 'gGEO'
_addon.version = '1.0'

-- dependancies
require('luau')
require('gLibs/gPlayer')
require('gLibs/gMob')
require('gLibs/gHelpers')
images = require('images')

-- used to debug. should be normally set to false
debugging = false
local moving = false
local loaded = false
local me = player()

-- create default settings
def = {
	window_pos = {x = (windower.get_windower_settings().ui_x_res / 2 ) - 60,y = (windower.get_windower_settings().ui_y_res / 2) - 8},
	active = true,
	current = "default",
	minimized = false,
	profiles = { default = {
		indi = {luopan="Voidance",active=true},
		geo = {luopan = "Precision",target=me.name,range=8,active=true},
		entrust = {luopan = "Regen",target=me.name,active=true},
		life_cycle = {player_hp=75,luopan_hp=50,active=true},
		dematerialize = {hp=75,active=true},
		follow = {target=me.name,range=1,active=true},
		combat_check = {target=me.name,active=true}
	}}
}
settings = config.load(def)

-- variables saved to memory
local options = {
	x = settings.window_pos.x,
	y = settings.window_pos.y,
	current_profile = settings.current,
	indi_luopan = settings.profiles.default.indi.luopan,
	geo_luopan = settings.profiles.default.geo.luopan,
	geo_target = settings.profiles.default.geo.target,
	geo_range = settings.profiles.default.geo.range,
	entrust_luopan = settings.profiles.default.entrust.luopan,
	entrust_target = settings.profiles.default.entrust.target,
	lc_player_hp = settings.profiles.default.life_cycle.player_hp,
	lc_pet_hp = settings.profiles.default.life_cycle.luopan_hp,
	dematerialize_hp = settings.profiles.default.dematerialize.hp,
	follow_target = settings.profiles.default.follow.target,
	follow_range = settings.profiles.default.follow.range,
	combat_target = settings.profiles.default.combat_check.target,
}

function draw_gui()
	gui = {}
	gui[1] = {object=new_image(0,0,200,37,'img/header.png',{0,0,0},false),toggled=false}										-- header
	gui[2] = {object=new_text_title("gGEO",options.x,options.y),toggled=false}															-- title
	gui[3] = {object=new_image(0,0,48,27,'img/on_large.png',{0,0,0},false),toggled=true}										-- toggle_bot
	gui[4] = {object=new_image(0,0,48,27,'img/min.png',{0,0,0},false),toggled=false}											-- resize
	gui[5] = {object=new_image(options.x,options.y,200,513,'img/body.png',{0,0,0},false),toggled=false}									-- body
	gui[6] = {object=new_image(options.x,options.y,200,380,'img/footer.png',{0,0,0},false),toggled=false}								-- footer
	gui[7] = {object=new_text_list_item("Profile: [" .. color_text(options.current_profile,255,255,255) .. "]",0,0),toggled=false}		-- current profile
	
	for _,ele in ipairs(gui) do
		ele.object:show()
	end
	
	text = {}
	text[1] = new_text_list_item("INDI",0,0)
	text[2] = new_text_list_item("Luopan: [" .. color_text(options.indi_luopan,255,255,255) .. "]",0,0)
	text[3] = new_text_list_item("GEO",0,0)
	text[4] = new_text_list_item("Luopan: [" .. color_text(options.geo_luopan,255,255,255) .. "]",0,0)
	text[5] = new_text_list_item("Target: [" .. color_text(options.geo_target,255,255,255) .. "]",0,0)
	text[6] = new_text_list_item("Resummon Range: [" .. color_text(options.geo_range,255,255,255) .. "]",0,0)
	text[7] = new_text_list_item("ENTRUST",0,0)
	text[8] = new_text_list_item("Luopan: [" .. color_text(options.entrust_luopan,255,255,255) .. "]",0,0)
	text[9] = new_text_list_item("Target: [" .. color_text(options.entrust_target,255,255,255) .. "]",0,0)
	text[10] = new_text_list_item("LIFE CYCLE",0,0)
	text[11] = new_text_list_item("HP Threshold: [" .. color_text(options.lc_player_hp,255,255,255) .. "]",0,0)
	text[12] = new_text_list_item("Pet HP Threshold: [" .. color_text(options.lc_pet_hp,255,255,255) .. "]",0,0)
	text[13] = new_text_list_item("DEMATERIALIZE",0,0)
	text[14] = new_text_list_item("Pet HP Threshold: [" .. color_text(options.dematerialize_hp,255,255,255) .. "]",0,0)
	text[15] = new_text_list_item("FOLLOW",0,0)
	text[16] = new_text_list_item("Target: [" .. color_text(options.follow_target,255,255,255) .. "]",0,0)
	text[17] = new_text_list_item("Range: [" .. color_text(options.follow_range,255,255,255) .. "]",0,0)
	text[18] = new_text_list_item("IN-COMBAT ONLY",0,0)
	text[19] = new_text_list_item("Target: [" .. color_text(options.combat_target,255,255,255) .. "]",0,0)
	
	for _,txt in ipairs(text) do
		txt:show()
	end
	
	toggles = {}
	toggles[1] = {object=new_image(0,0,25,15,'img/on.png',{0,0,0},false),anchor=1,toggled=true}		-- indi
	toggles[2] = {object=new_image(0,0,25,15,'img/on.png',{0,0,0},false),anchor=3,toggled=true}		-- geo
	toggles[3] = {object=new_image(0,0,25,15,'img/on.png',{0,0,0},false),anchor=7,toggled=true}		-- entrust
	toggles[4] = {object=new_image(0,0,25,15,'img/on.png',{0,0,0},false),anchor=10,toggled=true}	-- life cycle
	toggles[5] = {object=new_image(0,0,25,15,'img/on.png',{0,0,0},false),anchor=13,toggled=true}	-- dematerialize
	toggles[6] = {object=new_image(0,0,25,15,'img/off.png',{0,0,0},false),anchor=15,toggled=true}	-- follow
	toggles[7] = {object=new_image(0,0,25,15,'img/on.png',{0,0,0},false),anchor=18,toggled=true}	-- in-combat only
	
	for _,btn in ipairs(toggles) do
		btn.object:show()
	end
end

function update_values()
	text[2]:text("Luopan: [" .. color_text(options.indi_luopan,255,255,255) .. "]")
	text[4]:text("Luopan: [" .. color_text(options.geo_luopan,255,255,255) .. "]")
	text[5]:text("Target: [" .. color_text(options.geo_target,255,255,255) .. "]")
	text[6]:text("Resummon Range: [" .. color_text(options.geo_range,255,255,255) .. "]")
	text[8]:text("Luopan: [" .. color_text(options.entrust_luopan,255,255,255) .. "]")
	text[9]:text("Target: [" .. color_text(options.entrust_target,255,255,255) .. "]")
	text[11]:text("HP Threshold: [" .. color_text(options.lc_player_hp,255,255,255) .. "]")
	text[12]:text("Pet HP Threshold: [" .. color_text(options.lc_pet_hp,255,255,255) .. "]")
	text[14]:text("Pet HP Threshold: [" .. color_text(options.dematerialize_hp,255,255,255) .. "]")
	text[16]:text("Target: [" .. color_text(options.follow_target,255,255,255) .. "]")
	text[17]:text("Range: [" .. color_text(options.follow_range,255,255,255) .. "]")
	text[19]:text("Target: [" .. color_text(options.combat_target,255,255,255) .. "]")

	toggle_button(toggles[1],false,'on','off')
	toggle_button(toggles[2],false,'on','off')
	toggle_button(toggles[3],false,'on','off')
	toggle_button(toggles[4],false,'on','off')
	toggle_button(toggles[5],false,'on','off')
	toggle_button(toggles[6],false,'on','off')
	toggle_button(toggles[7],false,'on','off')
	
	gui[7].object:text("Profile: [" .. color_text(options.current_profile,255,255,255) .. "]")
	windower.send_command("fastfollow min " .. options.follow_range)
end

function reposition_gui()
	gui[1].object:pos_x(gui[2].object:pos_x()-75)
	gui[1].object:pos_y(gui[2].object:pos_y()-5)
	gui[3].object:pos_x(gui[1].object:pos_x() + 5)
	gui[3].object:pos_y(gui[1].object:pos_y() + 5)	
	gui[4].object:pos_x(gui[1].object:pos_x() + 171)
	gui[4].object:pos_y(gui[1].object:pos_y() + 8)
	gui[5].object:pos_x(gui[1].object:pos_x())
	gui[5].object:pos_y(gui[1].object:pos_y()+37)	
	
	i = 1
	for key,value in ipairs(text) do
		value:pos_x(gui[1].object:pos_x()+35)
		if i == 1 then
			value:pos_y(gui[1].object:pos_y()+37)
		else
			value:pos_y(text[i-1]:pos_y()+27)		
		end
		i = i + 1
	end	

	for _,btn in ipairs(toggles) do
		btn.object:pos_x(text[btn.anchor]:pos_x()-30)
		btn.object:pos_y(text[btn.anchor]:pos_y()+3)
	end	
	
	gui[6].object:pos_x(gui[1].object:pos_x())
		
	if gui[4].toggled then
		gui[6].object:pos_y(gui[1].object:pos_y()+37)
	else
		gui[6].object:pos_y(text[#text]:pos_y()+27)
	end
	
	gui[7].object:pos_x(gui[6].object:pos_x()+5)
	gui[7].object:pos_y(gui[6].object:pos_y())		
end

function resize_gui()
	if gui[4].toggled then
		gui[5].object:hide()
		
		for _,txt in ipairs(text) do
			txt:hide()
		end	
		
		for _,btn in ipairs(toggles) do
			btn.object:hide()
		end
		
		gui[6].object:pos_y(gui[1].object:pos_y()+37)
		gui[7].object:pos_y(gui[6].object:pos_y())	
	else
		gui[5].object:show()
		
		for _,txt in ipairs(text) do
			txt:show()
		end	
		
		for _,btn in ipairs(toggles) do
			btn.object:show()
		end

		gui[6].object:pos_y(text[#text]:pos_y()+27)
		gui[7].object:pos_y(gui[6].object:pos_y())		
	end
end

function do_stuff()
	if loaded then
		if gui[3].toggled then
			coroutine.schedule(do_stuff, 3)
			-- combat engaged check
			if toggles[7].toggled then
				local target = mob(options.combat_target)
				if target and target.status == 1 then
					bot()
				end
			else
				bot()
			end
			
			return
		end
	end
end

local hate_target = {id=nil,on_hate_list=false}
function bot()
	me = player()

	--is an indi luopan up?
	if toggles[1].toggled then
		if has_buff(me.buffs,612) == false then
			cast_spell(me,"me","Indi-" .. options.indi_luopan)
			return
		end
	end
			
	-- is a geo luopan up?
	if toggles[2].toggled then
		local geo_target_mob = mob(options.geo_target)
		local pet = mob('pet')
	
		if pet then
			--is the target far from the luopan?
			if in_range(geo_target_mob,pet,options.geo_range) == false then
				use_ability(me,"me","Full Circle")
				return
			else
				-- is the luopan under the dematerialize hp threshold?
				if toggles[4].toggled then
					if pet.hpp <= options.dematerialize_hp then
						use_ability("me","Dematerialize")
						return
					end
				end
				
				-- is the loupon under the life cycle hp threshold?
				if toggles[5].toggled then
					if me.vitals["hpp"] >= options.lc_player_hp and pet.hpp <= options.lc_pet_hp then
						use_ability(me,"me","Life Cycle")
						return
					end
				end
			end			
		else
			if in_range(geo_target_mob,me.mob,12) then
				-- is the luopan enemy-only?
				local t = options.geo_target
				if options.geo_luopan == "Wilt" or options.geo_luopan == "Frailty" or options.geo_luopan == "Fade" or options.geo_luopan == "Malaise" or options.geo_luopan == "Slip" or options.geo_luopan == "Torpor" or options.geo_luopan == "Vex" or options.geo_luopan == "Languor" or options.geo_luopan == "Slow" or options.geo_luopan == "Paralysis" then 
					local target = mob('bt')
					if target then
						cast_spell(me,'bt',"Geo-" .. options.geo_luopan)
						return
					end
				else
					cast_spell(me,t,"Geo-" .. options.geo_luopan)
					return
				end			
			end
		end
	end
			
	-- does focus have an entrusted bubble?
	if toggles[3].toggled then
		local entrust_target_mob = mob(options.entrust_target)
		
		if player_can_cast(me,"Indi-" .. options.entrust_luopan) and player_can_use(me,"Entrust") and has_buff(me.buffs,584) == false then
			if in_range(entrust_target_mob,me.mob,12) then 
				use_ability(me,"me","Entrust")
				return
			end
		end
		if has_buff(me.buffs,584) then
			if in_range(entrust_target_mob,me.mob,12) then 
				cast_spell(me,options.entrust_target,"Indi-" .. options.entrust_luopan)
				return
			end
		end
	end
	
	local target = mob('bt')
	-- there is a battle target
	if target then
		-- this is a new battle target
		if target.id ~= hate_target.id then
			hate_target.id = target.id
			hate_target.on_hate_list = false 
			-- get on the hate list
			cast_spell(me,options.geo_target,"Cure")
			return
		else
			-- are you on the hate list?
			if hate_target.on_hate_list == false then
				if last_spell ~= 1 then
					cast_spell(me,options.geo_target,"Cure")
				else
					hate_target.on_hate_list = true
				end
			end			
		end
	end
end

function load_profile_settings(node)
	options.indi_luopan = node.indi.luopan
	options.geo_luopan = node.geo.luopan
	options.geo_target = node.geo.target
	options.geo_range = node.geo.range
	options.entrust_luopan = node.entrust.luopan
	options.entrust_target = node.entrust.target
	options.lc_player_hp = node.life_cycle.player_hp
	options.lc_pet_hp = node.life_cycle.luopan_hp
	options.dematerialize_hp = node.dematerialize.hp
	options.follow_target = node.follow.target
	options.follow_range = node.follow.range
	options.combat_target = node.combat_check.target
	
	toggles[1].toggled = node.indi.active
	toggles[2].toggled = node.geo.active
	toggles[3].toggled = node.entrust.active
	toggles[4].toggled = node.life_cycle.active
	toggles[5].toggled = node.dematerialize.active
	toggles[6].toggled = node.follow.active
	toggles[7].toggled = node.combat_check.active
	
	options.current_profile = settings.current

	update_values()
end

function ini()
	-- draw the gui elements
	draw_gui()
	
	-- load the profile settings
	load_profile_settings(settings.profiles[settings.current])
	
	-- reposition the ui accordingly
	reposition_gui()
	
	-- resize the window
	if settings.minimized then
		gui[4].toggled = true
	else
		gui[4].toggled = false
	end
	toggle_button(gui[4],false,'max','min')
	resize_gui()

	-- enable following thread
	if toggles[6].toggled then
		windower.send_command("fastfollow " .. options.follow_target)
	else
		windower.send_command("fastfollow stop")
	end
	
	ac = windower.register_event('addon command', addon_command)
	m = windower.register_event('mouse', mouse)	
	
	print(_addon.name,"gGEO Loaded.")
	loaded = true

	-- set the config status of the 'on' button
	if settings.active then
		gui[3].toggled = true
		do_stuff()
	else
		gui[3].toggled = false
	end	
	toggle_button(gui[3],false,'on_large','off_large')	
end

function destroy()
	if gui then
		for _,ele in ipairs(gui) do
			ele.object:hide()
		end
	end
	if text then
		for _,ele in ipairs(text) do
			ele:hide()
		end	
	end
	if toggles then
		for _,ele in ipairs(toggles) do
			ele.object:hide()
		end	
	end
	gui = nil
	text = nil
	toggles = nil
	moving = false
	
	windower.unregister_event(ac)
	windower.unregister_event(m)
	
	loaded = false
end

windower.register_event('load', function()
	if me.main_job == "GEO" or me.sub_job == "GEO" then
		if loaded == false then
			ini()
		end
	end
end)

windower.register_event('job change', function(main_job_id, main_job_level,sub_job_id,sub_job_level)
	if main_job_id == 21 or sub_job_id == 21 then
		if loaded == false then
			ini()
		end
	else
		destroy()
	end
end)

function mouse(type, x, y, delta, blocked)
	-- the title drag
	if gui[2].object:hover(x,y) then
		if type == 0 then
			reposition_gui()
		end
		if type == 2 then
			options.x = gui[2].object:pos_x()
			options.y = gui[2].object:pos_y()
			settings.window_pos.x = options.x
			settings.window_pos.y = options.y
			settings:save()
		end
	end
	
	-- the overall 'on' button
	if gui[3].object:hover(x,y) then 
		if type == 2 then
			toggle_button(gui[3],true,'on_large','off_large')
			settings.active = gui[3].toggled
			settings:save()
			if gui[3].toggled then
				do_stuff()				
			end
		end
		return true
	end
	
	-- the resize button
	if gui[4].object:hover(x,y) then
		if type == 2 then
			toggle_button(gui[4],true,'max','min')
			resize_gui()
			settings.minimized = gui[4].toggled
			settings:save()			
		end
		return true
	end
	
	-- the toggle buttons
	for _,btn in ipairs(toggles) do
		if btn.object:hover(x,y) then
			if type == 2 then
				toggle_button(btn,true,'on','off')
					
				if btn.anchor == 15 and btn.toggled then
					windower.send_command("fastfollow " .. options.follow_target)
				elseif btn.anchor == 15 and btn.toggled == false then
					windower.send_command("fastfollow stop")
				end
			end
			return true
		end
	end
end

function toggle_button(node,update,img1,img2)
	if update then
		if node.toggled then
			node.toggled = false
			node.object:path(windower.addon_path.. '/img/' .. img2 .. '.png')
		else
			node.toggled = true
			node.object:path(windower.addon_path.. '/img/' .. img1 .. '.png')	
		end
	else
		if node.toggled then
			node.object:path(windower.addon_path.. '/img/' .. img1 .. '.png')	
		else
			node.object:path(windower.addon_path.. '/img/' .. img2 .. '.png')
		end		
	end
end

function current_settings()
	local profile = {
		indi = {luopan=options.indi_luopan,active=toggles[1].toggled},
		geo = {luopan = options.geo_luopan,target=options.geo_target,range=options.geo_range,active=toggles[2].toggled},
		entrust = {luopan = options.entrust_luopan,target=options.entrust_target,active=toggles[3].toggled},
		life_cycle = {player_hp=options.lc_player_hp,luopan_hp=options.lc_pet_hp,active=toggles[4].toggled},
		dematerialize = {hp=options.dematerialize_hp,active=toggles[5].toggled},
		follow = {target=options.follow_target,range=options.follow_range,active=toggles[6].toggled},
		combat_check = {target=options.combat_target,active=toggles[7].toggled}
	}
	
	return profile
end

function sanitize_spell(str)
	if string.find(str, "indi") then
		if string.find(str, "indi-") then
			str = removeSubString(str,"indi")
			str = removeSubString(str,"-")
		elseif string.find(str, "indi") then
			str = removeSubString(str,"indi")	
		end
	elseif string.find(str,"geo") then
		if string.find(str, "geo-") then
			str = removeSubString(str,"geo")
			str = removeSubString(str,"-")
		elseif string.find(str, "geo") then
			str = removeSubString(str,"geo")	
		end
	end
	
	return str
end

help = {}
help["indi"] = {
	"========== AVAILABLE INDI COMMANDS ==========",
	"indi [str] -sets your indi luopan",
}
help["geo"] = {
	"========== AVAILABLE GEO COMMANDS ==========",
	"geo [str]        -sets your geo luopan",
	"geo target [str] -sets your geo target",
	"geo range [str]  -sets the range target can get before recast"		
}
help["entrust"] = {
	"========== AVAILABLE ENTRUST COMMANDS ==========",
	"entrust [str]        -sets your entrust luopan",
	"entrust target [str] -sets your entrust target",
}
help["life_cycle"] = {
	"========== AVAILABLE LIFE CYCLE COMMANDS ==========",
	"lc player [str]  -sets LC player HP threshold",
	"lc pet [str]     -sets LC luopan HP threshold",
}
help["dematerialize"] = {
	"========== AVAILABLE DEMATERIALIZE COMMANDS ==========",
	"dematerialize hp [str] -sets Dematerialize player HP threshold",
}
help["follow"] = {
	"========== AVAILABLE FOLLOW COMMANDS ==========",
	"follow target [str] -set your follow target",
	"follow range [str]  -set your follow range",
}
help["combat"] = {
	"========== AVAILABLE COMBAT COMMANDS ==========",
	"combat target [str] -set your combat check target",
}
help["profile"] = {
	"========== AVAILABLE PROFILE COMMANDS ==========",
	"profile save         -saves to current profile",
	"profile save [str]   -saves to existing profile or creates new",
	"profile load [str]   -loads a profile",
	"profile delete       -deletes the currently profile",
	"profile delete [str] -deletes the specified profile",
	"profile default      -loads the default profile",
}

function addon_command(...)
    local commands = {...}
	if commands[1] == nil or commands[1] == "" or commands[1]:lower() == "help" then
		for _,obj in pairs(help) do
			for _,str in ipairs(obj) do
				print(_addon.name,str)
			end
		end	
	elseif commands[1] and commands[1]:lower() == 'profile' then 
		if commands[2] == nil or commands[2] == "" then
			for type,str in pairs(help["profile"]) do
				print(_addon.name,str)
			end
		elseif commands[2] and commands[2]:lower() == 'save' then
			if commands[3] == nil or commands[3] == "" then
				if settings.profiles[options.current_profile] then
					settings.profiles[options.current_profile] = current_settings()
					settings:save('all')
					print(_addon.name,"SUCCESS! Current settings saved to profile [" .. options.current_profile .. "]!")
				else
					print(_addon.name,"ERROR! Profile [" .. options.current_profile .. "] not found!")
				end
			else
				if settings.profiles[commands[3]:lower()] then
					print(_addon.name,"SUCCESS! Profile [" .. commands[3]:lower() .. "] saved!")
				else
					print(_addon.name,"SUCCESS! Profile [" .. commands[3]:lower() .. "] created!")
				end
				settings.profiles[commands[3]:lower()] = current_settings()
				settings:save('all')
				settings.current = commands[3]:lower()
				settings:save()
				load_profile_settings(settings.profiles[settings.current])				
			end
		elseif commands[2] and commands[2]:lower() == 'load' then
			if commands[3] == nil or commands[3] == "" then
				print(_addon.name,"ERROR! Please provide a profile name!")
			else
				if settings.profiles[commands[3]:lower()] then
					settings.current = commands[3]:lower()
					settings:save()
					load_profile_settings(settings.profiles[settings.current])
					print(_addon.name,"SUCCESS! Profile [" .. settings.current .. "] loaded!")
				else
					print(_addon.name,"ERROR! Profile [" .. commands[3]:lower() .. "] not found!")
				end				
			end		
		elseif commands[2] and commands[2]:lower() == 'delete' then
			if commands[3] == nil then
				print(_addon.name,"ERROR! Please provide a profile name!")
			else
				if commands[3]:lower() == "default" then
					print(_addon.name,"ERROR! Cannot delete default profile!")
				else
					if settings.profiles[commands[3]:lower()] then
						if settings.current == commands[3]:lower() then
							settings.current = "default"
							settings:save()
							load_profile_settings(settings.profiles[settings.current])
							settings.profiles[commands[3]:lower()] = nil
							settings:save('all')
						else
							settings.profiles[commands[3]:lower()] = nil
							settings:save('all')
						end
						print(_addon.name,"SUCCESS! Profile [" .. commands[3]:lower() .. "] deleted!")
					else
						print(_addon.name,"SUCCESS! Profile [" .. commands[3]:lower() .. "] doesn't exist!")
					end
				end
			end
		elseif commands[2] == 'default' then
			settings.current = "default"
			settings:save()
			load_profile_settings(settings.profiles[settings.current])		
		end
	elseif commands[1] and commands[1]:lower() == 'indi' then
		if commands[2] == nil or commands[2] == "" then
			for type,str in pairs(help["indi"]) do
				print(_addon.name,str)
			end
		else
			local str = sanitize_spell(commands[2]:lower())
			if player_has_spell_by_name("Indi-" .. firstToUpper(str)) then
				options.indi_luopan = firstToUpper(str)
				update_values()
				print(_addon.name,"SUCCESS! Indi Luopan set to [" .. options.indi_luopan .. "]!")
			else
				print(_addon.name,"ERROR! Cannot find spell!")
			end
		end
	elseif commands[1] and commands[1]:lower() == 'geo' then
		if commands[2] == nil or commands[2] == "" then
			for type,str in pairs(help["geo"]) do
				print(_addon.name,str)
			end
		elseif commands[2] and commands[2]:lower() == 'target' then
			if commands[3] == nil or commands[3] == "" then
				print(_addon.name,"ERROR! Please include a name!")
			else
				options.geo_target = firstToUpper(commands[3]:lower())
				update_values()
				print(_addon.name,"SUCCESS! Geo luopan target set to [" .. options.geo_target .. "]!")
			end
		elseif commands[2] and commands[2]:lower() == 'range' then
			if commands[3] == nil or commands[3] == "" then
				print(_addon.name,"ERROR! Please include a number!")
			else
				if IsNumeric(commands[3]) then
					options.geo_range = tonumber(commands[3])
					update_values()
					print(_addon.name,"SUCCESS! Geo luopan recast range set to [" .. options.geo_range .. "]!")
				else
					print(_addon.name,"ERROR! Please include a number!")
				end
			end		
		else
			local str = sanitize_spell(commands[2]:lower())
			if player_has_spell_by_name("Geo-" .. firstToUpper(str)) then
				options.geo_luopan = firstToUpper(str)
				update_values()
				print(_addon.name,"SUCCESS! Geo Luopan set to [" .. options.geo_luopan .. "]!")
			else
				print(_addon.name,"ERROR! Cannot find spell!")
			end
		end	
	elseif commands[1] and commands[1]:lower() == 'entrust' then
		if commands[2] == nil or commands[2] == "" then
			for type,str in pairs(help["entrust"]) do
				print(_addon.name,str)
			end
		elseif commands[2] and commands[2]:lower() == 'target' then
			if commands[3] == nil or commands[3] == "" then
				print(_addon.name,"ERROR! Please include a name!")
			else
				options.entrust_target = firstToUpper(commands[3]:lower())
				update_values()
				print(_addon.name,"SUCCESS! Entrust luopan target set to [" .. options.geo_target .. "]!")
			end
		else
			local str = sanitize_spell(commands[2]:lower())
			if player_has_spell_by_name("Indi-" .. firstToUpper(str)) then
				options.entrust_luopan = firstToUpper(str)
				update_values()
				print(_addon.name,"SUCCESS! Entrust Luopan set to [" .. options.entrust_luopan .. "]!")
			else
				print(_addon.name,"ERROR! Cannot find spell!")
			end
		end	
	elseif commands[1] and commands[1]:lower() == 'lc' then
		if commands[2] == nil or commands[2] == "" then
			for type,str in pairs(help["life_cycle"]) do
				print(_addon.name,str)
			end
		elseif commands[2] and commands[2]:lower() == 'player' then
			if commands[3] == nil or commands[3] == "" then
				print(_addon.name,"ERROR! Please include a number!")
			else
				if IsNumeric(commands[3]) then
					options.lc_player_hp = tonumber(commands[3])
					update_values()
					print(_addon.name,"SUCCESS! Life Cycle player HP threshold set to [" .. options.lc_player_hp .. "]!")
				else
					print(_addon.name,"ERROR! Please include a number!")
				end
			end
		elseif commands[2] and commands[2]:lower() == 'pet' then
			if commands[3] == nil or commands[3] == "" then
				print(_addon.name,"ERROR! Please include a number!")
			else
				options.lc_pet_hp = tonumber(commands[3])
				update_values()
				print(_addon.name,"SUCCESS! Life Cycle luopan HP threshold set to [" .. options.lc_pet_hp .. "]!")
			end
		end	
	elseif commands[1] and commands[1]:lower() == 'dematerialize' then
		if commands[2] == nil or commands[2] == "" then
			for type,str in pairs(help["dematerialize"]) do
				print(_addon.name,str)
			end
		elseif commands[2] and commands[2]:lower() == 'hp' then
			if commands[3] == nil or commands[3] == "" then
				print(_addon.name,"ERROR! Please include a number!")
			else
				if IsNumeric(commands[3]) then
					options.dematerialize_hp = tonumber(commands[3])
					update_values()
					print(_addon.name,"SUCCESS! Dematerialize luopan HP threshold set to [" .. options.dematerialize_hp .. "]!")
				else
					print(_addon.name,"ERROR! Please include a number!")
				end
			end		
		end
	elseif commands[1] and commands[1]:lower() == 'follow' then
		if commands[2] == nil or commands[2] == "" then
			for type,str in pairs(help["follow"]) do
				print(_addon.name,str)
			end
		elseif commands[2] and commands[2]:lower() == 'target' then
			if commands[3] == nil or commands[3] == "" then
				print(_addon.name,"ERROR! Please include a name!")
			else
				options.follow_target = firstToUpper(commands[3]:lower())
				update_values()
				print(_addon.name,"SUCCESS! Follow target set to [" .. options.follow_target .. "]!")
			end			
		elseif commands[2] and commands[2]:lower() == 'range' then
			if commands[3] == nil or commands[3] == "" then
				print(_addon.name,"ERROR! Please include a number!")
			else
				if IsNumeric(commands[3]) then
					options.follow_range = tonumber(commands[3])
					update_values()
					print(_addon.name,"SUCCESS! Follow range set to [" .. options.follow_range .. "]!")
				else
					print(_addon.name,"ERROR! Please include a number!")
				end
			end		
		end	
	elseif commands[1] and commands[1]:lower() == 'combat' then
		if commands[2] == nil or commands[2] == "" then
			for type,str in pairs(help["combat"]) do
				print(_addon.name,str)
			end
		elseif commands[2] and commands[2]:lower() == 'target' then
			if commands[3] == nil or commands[3] == "" then
				print(_addon.name,"ERROR! Please include a name!")
			else
				options.combat_target = firstToUpper(commands[3]:lower())
				update_values()
				print(_addon.name,"SUCCESS! Combat-only toggle set to: [" .. options.combat_target .. "]!")
			end		
		end
	end
end