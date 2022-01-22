local res = require('resources')
require('gLibs/gHelpers')

local busy = false

-- returns a complete player object
function player()
	local player = windower.ffxi.get_player()
	
	if player then
		local player_mob = windower.ffxi.get_mob_by_target('me')
		if player_mob then
			player['mob'] = player_mob
		end
		
		local abilities = windower.ffxi.get_abilities()
		if abilities then
			player['abilities'] = abilities
			
			local recasts = windower.ffxi.get_ability_recasts()
			
			if recasts then
				player['abilities']['recasts'] = recasts
			end
		end
		
		local spells = windower.ffxi.get_spells()
		if spells then
			player['spells'] = spells
			
			local recasts = windower.ffxi.get_spell_recasts()
			
			if recasts then
				player['spells']['recasts'] = recasts
			end
		end
		
		return player
	else
		return false
	end
end

function is_player_busy()
	return busy
end

function set_busy_to_false()
	if busy == true then
		busy = false
		debug("No Longer Busy")
	end
end

-- determine if player is busy
windower.register_event('action', function(act)
	if act.actor_id == player().id then
		-- BEGIN job ability
		if act.category == 06 then
			busy = true
			debug("Using Job Ability")
			coroutine.schedule(set_busy_to_false, 2)
		-- BEGIN weaponskill
		elseif act.category == 07 then
			busy = true
			debug("Using WS/TP Move")
		-- END weaponskill
		elseif act.category == 03 then
			debug("Finished WS")
			coroutine.schedule(set_busy_to_false, 2)
		-- END tp move
		elseif act.category == 11 then
			debug("Finished TP Move")
			coroutine.schedule(set_busy_to_false, 2)
		-- BEGIN spell
		elseif act.category == 08 then
			busy = true
			debug("Using Spell")

		-- END spell
		elseif act.category == 04 then
			debug("Finished Spell")
			coroutine.schedule(set_busy_to_false, 2)
		-- BEGIN item
		elseif act.category == 09 then
			busy = true
			debug("Using Item")

		-- END item
		elseif act.category == 05 then
			debug("Finished Item")
			coroutine.schedule(set_busy_to_false, 2)
		-- BEGIN ranged attack
		elseif act.category == 12 then
			busy = true
			debug("Using Ranged Attack")
		-- END ranged attack
		elseif act.category == 02 then
			debug("Finished Ranged Attack")
			coroutine.schedule(set_busy_to_false, 2)
		end
	end
end)

function has_buff(buffs,buff)
	for key,value in ipairs(buffs) do
		if value == buff then
			return true
		end
	end	
	return false
end

function player_can_cast(pl,spell_name)
	-- is the player busy casting
	if is_player_busy() then
		debug("Player is Busy")
		return false
	else
		local spell = res.spells:with('en',spell_name)
		-- does the spell exist?
		if spell then
			debug("Spell Exists")
			-- does the player have the spell learned?
			if player_has_spell(pl,spell) then
				debug("Player Learned Spell")
				-- is player on the appropriate job/level?
		
				local right_job = false
				for job,level in pairs(spell.levels) do
					if (job == pl.main_job_id and pl.main_job_level >= level) or (job == pl.sub_job_id and pl.sub_job_level >= level) then
						debug("Player Is The Appropriate Job/Level")
						right_job = true
					end
				end
				
				if right_job then
					if pl.vitals["mp"] >= spell.mp_cost then
						debug("Player Has MP to Cast")
						-- is the spell on recast?
						if pl.spells.recasts[spell.recast_id] == 0 then
							return true
						else
							debug("Player Spell Is Not Ready")
							return false
						end
					else
						debug("Player Does Not Have Enough MP")
						return false
					end	
				end
			else
				debug("Player Hasn't Learned Spell")
				return false
			end
		else
			debug("Spell Doesn't Exist")
			return false
		end
	end
end

function player_has_spell(pl,spell)
	for key,value in ipairs(pl.spells) do
		if key == spell.id then
			return value
		end
	end	
	return false
end

function player_has_spell_by_name(spell_name)
	local spell = res.spells:with('en',spell_name)
	local spells = windower.ffxi.get_spells()
	
	if spell then
		for key,value in ipairs(spells) do
			if key == spell.id then
				return value
			end
		end
	end
	
	return false
end

function cast_spell(pl,target,spell)
	if player_can_cast(pl,spell,target) then
		windower.send_command("ma \"" .. spell .. "\" <" .. target .. ">")
	end
end

function player_can_use(pl,ability_name)
	-- is the player busy
	if is_player_busy() then
		debug("Player is Busy")
		return false
	else
		local ability = res.job_abilities:with('en',ability_name)
		-- does the spell exist?
		if ability then
			debug("Ability Exists")
    			-- is player on the appropriate job/level?
				if player_has_ability(pl,ability.id) then
					if pl.abilities.recasts[ability.recast_id] == 0 then
						return true
					else
						debug("Ability Not Ready")
						return false
					end
				else
					debug("Player Cant Use Ability")
					return false
				end
		else
			debug("Ability Doesn't Exist")
			return false
		end
	end
end

function player_has_ability(pl,ability_id)
	for key,value in pairs(pl.abilities.job_abilities) do
		if value == ability_id then
			return true
		end
	end	
	return false
end


function use_ability(pl,target,ability)
	if player_can_use(pl,ability,target) then
		windower.send_command("ja \"" .. ability .. "\" <" .. target .. ">")
	end
end

function in_range(target,player,range)
	if target and target.x and target.y and target.z and distance_from(target, player) <= range then
		return true
	else
		return false
	end
end

function runto(pl,target,action_distance)
	if target and pl and target.name ~= pl.name then  -- Please note if you target yourself you will run Due East
		local angle = (math.atan2((target.y - pl.y), (target.x - pl.x))*180/math.pi)*-1
		windower.ffxi.run((angle):radian())
	end
end