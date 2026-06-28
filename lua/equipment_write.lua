
-- this will check for a unit that has a unit.variables.gear.<item_name>=new, and check it against equipment_list.list_by_name.  If it matches something, apply the effects and set =old.
-- later, when we need to access the values of the equipment, we can refer to the lua file, retrieving the name from unit.variables.gear_old
-- want to make this a tag
bmr_equipment = {}
-- result is string:
--   "not found" if getting unit failed
--   "wrong type" if nothing matches in equipment type field and unit type
--   "no room" if unit already has equipment for that usage type
--   "is ai" if unit cannot accept equipment and is ai controlled side
--   "pass" if unit can accept equipment



bmr_equipment.lookup = function(gear_id)
    local result = {}
    for j in ipairs(equipment_list.the_list) do  
        if equipment_list.the_list[j].id == gear_id then
            result = equipment_list.the_list[j]
            return result
        end
    end
end

bmr_equipment.unit = function(unit_id)
    local units = {}  
    units = wesnoth.units.find_on_map({ id = unit_id })
    if units[1] then
    else
        units = wesnoth.get_recall_units({ id = unit_id })
        if units[1] then
        else
            wml.error("unit not found")
            return nil
        end
    end
    return units[1]
end

-- in the following functions, gear_item is the output of the above lookup function (an element of the equipment list)

bmr_equipment.filter = function(unit_id, gear_item)
    local result = "wrong type"
    local units = {}  
    units = wesnoth.units.find_on_map({ id = unit_id })
    if units[1] then
    else
        units = wesnoth.get_recall_units({ id = unit_id })
        if units[1] then
        else
            result = "not found"
            return result
        end
    end
    -- If it is a potion, we don't need to check the unit info, aside from side controller, we are done
    if gear_item.usage == "potion" then
        if wesnoth.sides[units[1].side].controller == "ai" then
            result = "is ai"
        else
            result = "potion"
        end
        return result
    end
    -- check that the unit can use this item
    if gear_item.usage == "all" then
        result = "pass"
    else
        for j in ipairs(equipment_list.list_usage) do
            if equipment_list.list_usage[j].usage == gear_item.usage then
                for k in ipairs(equipment_list.list_usage[j].types) do
                    if equipment_list.list_usage[j].types[k] == units[1].type then
                        result = "pass"
                        break
                    end
                end
            end
            if result == "pass" then
                break
            end
        end
    end
    -- if the unit is the right type...
    if result == "pass" then
        local u_vars = wml.get_child(units[1].__cfg, "variables")
        -- ... check that XP is enough ...
        local total_xp = u_vars.total_xp
        if total_xp then
            total_xp = u_vars.total_xp + units[1].experience
        else 
            total_xp = units[1].experience
        end
        if total_xp < gear_item.xp_needed then
            result = "low XP"
        end
        -- ... that it's not too much weight ...
        local u_weight = u_vars.weight
        local total_weight = gear_item.weight
        if u_weight then
            total_weight = total_weight + u_weight
        end
        local weight_limit = units[1].level * 4
        weight_limit = weight_limit + 4
        if total_weight > weight_limit then
            result = "no room"
        end
        -- ... and that there is free space to equip it (we can't find the position pattern in the gear_positions variable string)
        local position_text = u_vars.gear_positions
        if position_text then
            local position_text_begin,position_text_end = string.find(position_text, gear_item.position)
            if position_text_begin then
                result = "no room"
            end
        end
    end
    -- I'm not sure there is a distinction, but maybe there should be
    if result == "no room" and wesnoth.sides[units[1].side].controller == "ai" then
        result = "is ai"
    elseif result == "low XP" and wesnoth.sides[units[1].side].controller == "ai" then
        result = "is ai"
    elseif result == "wrong type" and wesnoth.sides[units[1].side].controller == "ai" then
        result = "is ai"
    end
    return result
end

bmr_equipment.apply = function(unit_var, gear_item)

    local accuracy_specials = "accuracy_ws"..gear_item.accuracy -- break out the weapon accuracy from any general accuracy boost, and these specials are defined in WML elsewhere
    -- for updating the attack dialog icon - only applies to blades (axes + swords), spears and bows.
    -- Everything else gets its own "new attack", so we don't worry about it here
    local blade_icons_effects = {
    -- combine everything into one object
        wml.tag.effect {
            apply_to = "attack",
            range = "melee",
            type = "blade",
            increase_damage = gear_item.damage,
            { "set_specials", { specials_list = accuracy_specials, mode = "append" }},
            set_icon = gear_item.image
        }
    }
    local spear_icons_effects = {
        wml.tag.effect {
            apply_to = "attack",
            name = "spear",
            increase_damage = gear_item.damage,
            { "set_specials", { specials_list = accuracy_specials, mode = "append" }},
            set_icon = gear_item.image
        }
    }
    local bow_icons_effects = {
        wml.tag.effect {
            apply_to = "attack",
                {"and", {
                    range = "ranged",
                    type = "pierce"
                }},
            increase_damage = gear_item.damage,
            { "set_specials", { specials_list = accuracy_specials, mode = "append" }},
            set_icon = gear_item.image
        }
    }
    local accuracy_effects =
        wml.tag.effect {
            apply_to = "attack", { "set_specials", { specials_list = accuracy_specials, mode = "append" }}
        }
    local general_effects = {
        id = "object_"..gear_item.id, 
        wml.tag.effect {
            apply_to = "hitpoints",
            increase_total = gear_item.hp,
            heal_full = "no"
            },
        wml.tag.effect {
            apply_to = "defense",
            replace = "no",
            {"defense", {
                shallow_water= gear_item.dodge,
                deep_water= gear_item.dodge,
                reef= gear_item.dodge,
                swamp_water= gear_item.dodge,
                flat= gear_item.dodge,
                sand= gear_item.dodge,
                forest= gear_item.dodge,
                hills= gear_item.dodge,
                mountains= gear_item.dodge,
                cave= gear_item.dodge,
                frozen= gear_item.dodge,
                fungus= gear_item.dodge,
                castle= gear_item.dodge,
                village= gear_item.dodge
                }}
            },
        wml.tag.effect {
            apply_to = "resistance",
            replace = "no",
            {"resistance", {
                arcane = -gear_item.resist_arcane,
                blade = -gear_item.resist_blade,
                cold = -gear_item.resist_cold,
                fire = -gear_item.resist_fire,
                impact = -gear_item.resist_impact,
                pierce = -gear_item.resist_pierce
                }}
            }
        }
    -- collect all the equipment effects, if there are any, into general effects
    if gear_item.eq_effect then
        local tabi_a = #gear_item.eq_effect
        for i=1,tabi_a do
            table.insert(general_effects, gear_item.eq_effect[i])
        end
    end
            -- next insert the general effects into the weapon effects, if appropriate
              --table.insert(general_effects, wt_effects)
    if gear_item.position == "weapon" then
        local tabi_b = #general_effects
        for i=1,tabi_b do
            table.insert(blade_icons_effects, general_effects[i])
            table.insert(spear_icons_effects, general_effects[i])
            table.insert(bow_icons_effects, general_effects[i])
        end
        if gear_item.usage == "axe" or gear_item.usage == "sword" then
	    wesnoth.units.add_modification(unit_var, "object", blade_icons_effects)
	elseif gear_item.usage == "spear" then
            wesnoth.units.add_modification(unit_var, "object", spear_icons_effects)
	elseif gear_item.usage == "bow" then
            wesnoth.units.add_modification(unit_var, "object", bow_icons_effects)
        else
            wesnoth.units.add_modification(unit_var, "object", general_effects)
        end
    else
        if gear_item.accuracy ~= 0 then
            table.insert(general_effects, accuracy_effects)
        end
	wesnoth.units.add_modification(unit_var, "object", general_effects)
    end
    -- we've applied the effects, now we deal with the bookkeeping
    wml.fire("store_unit", { variable="my_unit", { "filter", { id = unit_var.id } } })
    local gindex = wml.variables["my_unit.variables.gear.length"] -- we aren't iterating, we just want to add to the end
    wml.variables["my_unit.variables.gear[" .. gindex .. "]"] = {
    -- on the one hand, we don't want to bloat the save files with these things
    -- on the other hand, if we have to look everything up from the id, is that really an improvement?
    -- for now, I keep the image and name because they are so frequently used in GUI <- might be a mistaken assumption
           name = gear_item.name,
           image = gear_item.image,
           id = gear_item.id,
           position = gear_item.position,
           luck = gear_item.luck
       }
    if wml.variables["my_unit.variables.weight"] then
        wml.variables["my_unit.variables.weight"] = wml.variables["my_unit.variables.weight"] + gear_item.weight
    else
        wml.variables["my_unit.variables.weight"] = gear_item.weight
    end
    if wml.variables["my_unit.variables.luck"] then
        wml.variables["my_unit.variables.luck"] = wml.variables["my_unit.variables.luck"] + gear_item.luck
    else
        wml.variables["my_unit.variables.luck"] = gear_item.luck
    end
    if wml.variables["my_unit.variables.gear_positions"] then
        wml.variables["my_unit.variables.gear_positions"] = wml.variables["my_unit.variables.gear_positions"].."_"..gear_item.position
    else
        wml.variables["my_unit.variables.gear_positions"] = "_"..gear_item.position
    end
    wml.fire("unstore_unit", { variable="my_unit", find_vacant = "no"})
   return
end

bmr_equipment.remove = function(unit_var, gear_item)
    if unit_var and gear_item.id then
        local gindex = 0
        local old_gear_id = ""
        wml.fire("store_unit", { variable="my_unit", { "filter", { id = unit_var.id } } })
        -- first check that the unit really has the gear 
        while wml.variables["my_unit.variables.gear["..gindex.."]"] do
	    old_gear_id = wml.variables["my_unit.variables.gear["..gindex.."].id"]
	    if old_gear_id == gear_item.id then
	        break
	    end
	    -- old_gear_id = nil
            gindex = gindex + 1
        end
        -- then delete the gear variables, if they exist...
        if old_gear_id then
            wml.variables["my_unit.variables.gear[" .. gindex .. "]"] = nil
            if wml.variables["my_unit.variables.weight"] > gear_item.weight then
                wml.variables["my_unit.variables.weight"] = wml.variables["my_unit.variables.weight"] - gear_item.weight
            else
                wml.variables["my_unit.variables.weight"] = 0
            end
            local gear_positions = wml.variables["my_unit.variables.gear_positions"]
            local substring = "_"..gear_item.position
            wml.variables["my_unit.variables.gear_positions"] = string.gsub(gear_positions, substring, "")
            wml.fire("unstore_unit", { variable="my_unit", find_vacant = "no"})
            -- ... and remove the gear [object]
            wml.fire("remove_object", { id = unit_var.id, object_id = "object_"..gear_item.id})

-- a hack to fix what may be a core bug with remove_object?
-- let's make sure this is really needed...  Yes, it is, but I'm not sure it's a bug with core [remove_object] etc.; I can't reproduce this in a simple test-case
--[[
	  local hack_HP_fix_pre = wml.variables["my_unit.hitpoints"]
	  local hack_u = wesnoth.units.find_on_map({id = unit_id})[1]
	  if hack_u.max_hitpoints < hack_HP_fix_pre then
	      hack_u.hitpoints = hack_u.max_hitpoints
	  else
	      hack_u.hitpoints = hack_HP_fix_pre
	  end
	  bmr_helper.modify_unit({ id = unit_id }, { hitpoints = hack_u.hitpoints })
]]
-- this does not work	  
--          wesnoth.units.modify({ id = unit_id }, { hitpoints = hack_u.hitpoints })
        else
            wesnoth.message(string.format("%s does not posses %s", unit_var.id, gear_item.id))      
        end
    end
    return
end

-- adds the gear id to a list that can be used by another unit on the recall list
bmr_equipment.pool_add = function(gear_id) -- no need to use the whole gear data
    if gear_id then
      gear_number = wml.variables["gear_pool[0]."..gear_id] -- these variables have integer values for quantity of given item
      if gear_number == nil then gear_number = 0 end
      gear_number = gear_number + 1
      wml.variables["gear_pool[0]."..gear_id] = gear_number
    end 
   return gear_number
end

-- removes the thing from the pool
bmr_equipment.pool_remove = function(gear_id) -- no need to use the whole gear data
    local gear_number = wml.variables["gear_pool[0]."..gear_id]
    if gear_number == nil or gear_number == 0 then
       wesnoth.message(string.format("%s is not in the pool, cannot remove", gear_id))
    else 
    gear_number = gear_number - 1
    wml.variables["gear_pool[0]."..gear_id] = gear_number
    end    
   return gear_number
end

-- places gear items on map
bmr_equipment.item_drop = function(x_1, y_1, gear_item)
    local icon = gear_item.icon
    if icon == nil then 
        icon = "misc/qmark.png"
        wesnoth.message(string.format("%s not found to drop image on map.", gear_item.id))
    else    
        wesnoth.interface.add_item_image(x_1, y_1, icon) 
        item_index = wml.variables["gear_map_items.length"] -- since first item is [0], no need to add +1
        if item_index == nil then item_index = 0 end
        wml.variables["gear_map_items["..item_index.."].id"] = gear_item.id
        wml.variables["gear_map_items["..item_index.."].cost"] = gear_item.cost
        wml.variables["gear_map_items["..item_index.."].x"] = x_1
        wml.variables["gear_map_items["..item_index.."].y"] = y_1
    end    
   return icon
end

-- does not actually apply the gear, just takes the items off the map, and removes the WML variables
bmr_equipment.item_take = function(x_1, y_1, gear_id)
    local item_index = 0
    local icon = ""
    local id_temp = ""
    local x_temp = ""
    local y_temp = ""
    item_max_index = wml.variables["gear_map_items.length"]
    while item_index < item_max_index do
        id_temp = wml.variables["gear_map_items["..item_index.."].id"]
        if id_temp == gear_id then
            x_temp = wml.variables["gear_map_items["..item_index.."].x"]
            y_temp = wml.variables["gear_map_items["..item_index.."].y"]
            icon = wml.variables["gear_map_items["..item_index.."].icon"]
	    if x_temp == x_1 and y_temp == y_1 then
	        -- delete the WML record
	        wml.variables["gear_map_items["..item_index.."]"] = nil
	        -- remove the image from the map
	        wesnoth.interface.remove_item(x_1, y_1, icon)
	    end
        end
        item_index = item_index + 1    
    end
    return icon
end

bmr_equipment.consume = function(unit_var, gear_item)
      if gear_item.usage == "potion" then
	      wesnoth.units.add_modification(unit_var, "object", gear_item.eq_effect)
              --wesnoth.message(string.format("%s tried to use %s", unit_var.id, gear_item.id))
      end
end

return bmr_equipment
