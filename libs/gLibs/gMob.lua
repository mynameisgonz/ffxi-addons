require('gLibs/gHelpers')

-- returns a complete target object
function mob(val)
	local mob = nil
	
	if type(val) == "string" then
		if val == 't' then 
			mob = windower.ffxi.get_mob_by_target('t')
		elseif val == 'pet' then
			mob = windower.ffxi.get_mob_by_target('pet')
		elseif val == 'bt' then
			mob = windower.ffxi.get_mob_by_target('bt')
		elseif val == 'me' then
			mob = windower.ffxi.get_mob_by_target('me')
		else
			local mob_by_name = windower.ffxi.get_mob_by_name(val)
			if mob_by_name then
				mob = mob_by_name
			end
		end
	elseif type(val) == "number" then
		local mob_by_id = windower.ffxi.get_mob_by_id(val)
		if mob_by_id then
			mob = mob_by_id
		else
			local mob_by_index = windower.ffxi.get_mob_by_index(val)
			if mob_by_index then
				mob = mob_by_index
			end
		end
	end
	
	return mob
end