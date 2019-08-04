
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
bmr_equipment.filter = function(unit_id, gear_id)    
      local result = "wrong type"
      local units = {}  
      units = wesnoth.get_units({ id = unit_id })
      if units[1] then
      else
        units = wesnoth.get_recall_units({ id = unit_id })
	if units[1] then
        else
          result = "not found"
--          wesnoth.message("Filter_debugging4", string.format("bmr_equipment.filter returns result= %s", result))
          return result
	end
      end
      if wesnoth.sides[units[1].side].controller == "ai" then
        result = "is ai"
--        wesnoth.message("Filter_debugging5", string.format("bmr_equipment.filter returns result= %s", result))
      end
--      if wesnoth.sides[units[1].side].controller == "human" then
--        wesnoth.message("Filter_debugging5", string.format("bmr_equipment.filter returns result= %s", result))
--      end
      local gear_usage = ""
      local gear_name = ""
      local gear_cost = ""
      local gear_image = ""
      local gear_text = ""
      local gear_position = ""
      local gear_weight = ""
      local eq_eff = ""
      -- find the gear usage for gear_id in equipment_list.the_list (not eqipment_list.list_usage)
      for j in ipairs(equipment_list.the_list) do  
        if equipment_list.the_list[j].id == gear_id then
          gear_usage = equipment_list.the_list[j].usage
          -- make sure the unit has an open position before continuing
          gear_position = equipment_list.the_list[j].position
--          wesnoth.message("Filter_debugging", string.format("gear_position= %s", gear_position))
--        FLAG: This part isn't quite right, I need to figure out/remember how to access the length of unit.variables.gear array
--          local gear_index_max = #units[1].variables["gear"] -- this isn't working, maybe I need to use the get_child stuff?
          local gear_index_max = 9 -- this is temporary fix.
          local gear_index = 0
--          wesnoth.message("Filter_debugging", string.format("gear_index_max= %i", gear_index_max))
          while gear_index < gear_index_max do
--            gear_pos_temp = units[1].variables["gear["..gear_index.."].position"]
--            wesnoth.message("Filter_debugging_Iteration", string.format("bmr_equipment.filter returns result= %s", gear_pos_temp))
            local gear_position_iter = units[1].variables["gear["..gear_index.."].position"]
--            wesnoth.message("Filter_debugging_loop", string.format("gear_position_iter= %s", gear_position_iter))
--            wesnoth.message("Filter_debugging_loop", string.format("gear_index %i out of %i", gear_index, gear_index_max))
            if gear_position_iter then
            else
	      break
	    end
            if gear_position_iter == gear_position then
--            if units[1].variables["gear["..gear_index.."].position"] == gear_position then
              if result ~= "is ai" then
                result = "no room"
              end
--              wesnoth.message("Filter_debugging3", string.format("bmr_equipment.filter returns result= %s", result))
              return result
            end
            -- this is a wml array, not lua, so it starts at [0]
            gear_index=gear_index + 1 
          end
          eq_eff = equipment_list.the_list[j].eq_effect
          gear_name = equipment_list.the_list[j].name
          gear_cost = equipment_list.the_list[j].cost
          gear_image = equipment_list.the_list[j].image
          gear_text = equipment_list.the_list[j].text
          gear_weight = equipment_list.the_list[j].weight
          break
        end
      end
      -- make sure the unit is the right unit_type to use this thing
      for j in ipairs(equipment_list.list_usage) do
        if equipment_list.list_usage[j].usage == gear_usage then
          for k in ipairs(equipment_list.list_usage[j].types) do 
            if equipment_list.list_usage[j].types[k] == units[1].type then
              result = "pass"
              wesnoth.fire("store_unit", { variable="my_unit", { "filter", { id = unit_id } } })
	      local gindex = wesnoth.get_variable("my_unit.variables.gear.length")
              wesnoth.set_variable("my_unit.variables.gear[" .. gindex .. "]", {
      		name = gear_name,
		cost = gear_cost,
      		image = gear_image,
      		text = gear_text,
      		id = gear_id,
      		position = gear_position,
      		weight = gear_weight
      	      })
              local old_weight = wesnoth.get_variable("my_unit.variables.weight")
              if old_weight then
              else
                  old_weight = 0
              end
              temp_weight = old_weight + gear_weight
--              if temp_weight < 0 then -- should not happen, but ...
--                  temp_weight = 0
--              end
              wesnoth.set_variable("my_unit.variables.weight", temp_weight) 
              local temp_movep_change_old = 0
              local temp_movep_change_new = 0
              while old_weight >= 10 do
                  temp_movep_change_old = temp_movep_change_old + 1
                  old_weight = old_weight - 10
              end
              while temp_weight >= 10 do
                  temp_movep_change_new = temp_movep_change_new + 1
                  temp_weight = temp_weight - 10
              end
              if temp_movep_change_new ~= temp_movep_change_old then
                  local change_movep = temp_movep_change_old - temp_movep_change_new
                  local movep = wesnoth.get_variable("my_unit.max_moves") 
                  wesnoth.set_variable("my_unit.max_moves", movep + change_movep) 
              end
              local dco = helper.get_child(units[1].__cfg, "defense")
              local dwt = -1*gear_weight
              local dco_deep_water = 100
              if dco.deep_water then
                  dco_deep_water = dco.deep_water
              end                 
              wesnoth.set_variable("my_unit.defense", {
                shallow_water= dco.shallow_water - dwt,
                deep_water= dco_deep_water - dwt,  -- special case
                reef= dco.reef - dwt,
                swamp_water= dco.swamp_water - dwt,
                flat= dco.flat - dwt,
                sand= dco.sand - dwt,
                forest= dco.forest - dwt,
                hills= dco.hills - dwt,
                mountains= dco.mountains - dwt,
--                village= dco.village - dwt,
--                castle= dco.castle - dwt,
                cave= dco.cave -dwt,
                frozen= dco.frozen -dwt,
                fungus= dco.fungus - dwt
              })
              wesnoth.fire("unstore_unit", { variable="my_unit", find_vacant = "no"})
	      wesnoth.add_modification(units[1], "object", eq_eff)
--              wesnoth.message("Filter_debugging2", string.format("bmr_equipment.filter returns result= %s", result))
              return result
            end
          end
        end
      end
--  wesnoth.message("Filter_debugging1", string.format("bmr_equipment.filter returns result= %s", result))
   return result
end

-- adds the gear id to a list that can be used by another unit on the recall list
bmr_equipment.pool_add = function(gear_id) 
    local gear_number = 0
    local gear_id_test = false
    for j in ipairs(equipment_list.the_list) do  
      if equipment_list.the_list[j].id == gear_id then
        gear_id_test = true
      end
    end
    if gear_id_test then
      gear_number = wesnoth.get_variable("gear_pool[0]."..gear_id)
      if gear_number == nil then gear_number = 0 end
      gear_number = gear_number + 1
      wesnoth.set_variable("gear_pool[0]."..gear_id, gear_number)
    end 
   return gear_number
end

-- this function calls bmr_equipment.filter and if the gear cannot be applied, we figure out what to do with it.
-- returns pass/fail
bmr_equipment.unit = function(unit_id, gear_id)
    local output = ""
    local filter_result = bmr_equipment.filter(unit_id, gear_id)
    if filter_result == "is ai" or filter_result == "not found" then
      output = "fail"
    elseif filter_result == "pass" then
      output = "pass"
    elseif filter_result == "no room" or filter_result == "wrong type" then
      bmr_equipment.pool_add(gear_id)
      output = "pass"
    else
      output = "error"
    end
--  wesnoth.message("unit_debugging1", string.format("bmr_equipment.unit returns output= %s", output))
   return output
end

bmr_equipment.remove = function(unit_id, gear_id)
      local result = ""
      local old_gear = ""
      local old_gear_id = ""
      local old_gear_weight = 0
      local units = {}
      local gindex = 0
--      local gear_index = 1
      units = wesnoth.get_units({ id = unit_id })      
      if units[1] then
	result = "on_map"
      else
        units = wesnoth.get_recall_units({ id = unit_id })      
	result = "on_recall"
      end  
-- th effects need to be moved into the filter below...

      wesnoth.fire("store_unit", { variable="my_unit", { "filter", { id = unit_id } } })
-- first check that the unit really has the gear 
      while wesnoth.get_variable("my_unit.variables.gear["..gindex.."]") do
	  old_gear_id = wesnoth.get_variable("my_unit.variables.gear["..gindex.."].id")
	  old_gear_weight = tonumber(wesnoth.get_variable("my_unit.variables.gear["..gindex.."].weight"))
	  if old_gear_id == gear_id then
	    break
	  end
	  old_gear_id = nil
          gindex = gindex + 1
      end
-- then delete the gear variables
      if old_gear_id then
          wesnoth.set_variable("my_unit.variables.gear[" .. gindex .. "]", nil)
          old_weight = wesnoth.get_variable("my_unit.variables.weight")
          if old_weight then
          else
             old_weight = 1
          end
          if old_gear_weight then
          else
             old_gear_weight = 1
          end
          temp_weight = old_weight - old_gear_weight
--          if temp_weight < 0 then -- should not happen, but ...
--              temp_weight = 0
--          end
          wesnoth.set_variable("my_unit.variables.weight", temp_weight) 
          local temp_movep_change_old = 0
          local temp_movep_change_new = 0
          while old_weight >= 10 do
              temp_movep_change_old = temp_movep_change_old + 1
              old_weight = old_weight - 10
          end
          while temp_weight >= 10 do
              temp_movep_change_new = temp_movep_change_new + 1
              temp_weight = temp_weight - 10
          end
          if temp_movep_change_new ~= temp_movep_change_old then
              local change_movep = temp_movep_change_old - temp_movep_change_new
              local movep = wesnoth.get_variable("my_unit.max_moves") 
              wesnoth.set_variable("my_unit.max_moves", movep + change_movep) 
          end
          local dco = helper.get_child(units[1].__cfg, "defense")
          local dwt = old_gear_weight
          local dco_deep_water = 100
          if dco.deep_water then
              dco_deep_water = dco.deep_water
          end                 
          wesnoth.fire("unstore_unit", { variable="my_unit", find_vacant = "no"})
          wesnoth.fire("remove_object", { id = unit_id, object_id = gear_id}) -- this resets many things, we need to restore the unit to modify [defense] values
          wesnoth.fire("store_unit", { variable="my_unit", { "filter", { id = unit_id } } })
          wesnoth.set_variable("my_unit.defense", {
            shallow_water= dco.shallow_water - dwt,
            deep_water= dco_deep_water - dwt, -- special case
            reef= dco.reef - dwt,
            swamp_water= dco.swamp_water - dwt,
            flat= dco.flat - dwt,
            sand= dco.sand - dwt,
            forest= dco.forest - dwt,
            hills= dco.hills - dwt,
            mountains= dco.mountains - dwt,
--                village= dco.village - dwt,
--                castle= dco.castle - dwt,
            cave= dco.cave - dwt,
            frozen= dco.frozen - dwt,
            fungus= dco.fungus - dwt
      	  })
          wesnoth.fire("unstore_unit", { variable="my_unit", find_vacant = "no"})
-- a hack to fix what may be a core bug with remove_object?
-- let's make sure this is really needed...  Yes, it is, but I'm not sure it's a bug with core [remove_object] etc.; I can't reproduce this in a simple test-case

	  local hack_HP_fix_pre = wesnoth.get_variable("my_unit.hitpoints")
	  local hack_u = wesnoth.get_units({id = unit_id})[1]
	  if hack_u.max_hitpoints < hack_HP_fix_pre then
	      hack_u.hitpoints = hack_u.max_hitpoints
	  else
	      hack_u.hitpoints = hack_HP_fix_pre
	  end
	  helper.modify_unit({ id = unit_id }, { hitpoints = hack_u.hitpoints })
      else
          wesnoth.message(string.format("%s does not posses %s", unit_id, gear_id))      
      end
   return result      
end

-- removes the thing from the pool
bmr_equipment.pool_remove = function(gear_id)
    local gear_number = wesnoth.get_variable("gear_pool[0]."..gear_id)
    if gear_number == nil or gear_number == 0 then
       wesnoth.message(string.format("%s is not in the pool, cannot remove", gear_id))
    else 
    gear_number = gear_number - 1
    wesnoth.set_variable("gear_pool[0]."..gear_id, gear_number)
    end    
   return gear_number
end

-- this, and its counterpart .item_take, can be moved above the .unit function, and used in it, to filter properly for clearing the map.
bmr_equipment.item_drop = function(x_1, y_1, gear_id)
    local icon = ""
    for j in ipairs(equipment_list.the_list) do  
      if equipment_list.the_list[j].id == gear_id then
          icon = equipment_list.the_list[j].icon
          cost = equipment_list.the_list[j].cost
          break
      end
    end
--      wesnoth.message(string.format("icon path is %s", icon))
    if icon == nil then 
	icon = "misc/qmark.png"
      wesnoth.message(string.format("%s not found to drop image on map.", gear_id))
    else    
    items.place_image(x_1, y_1, icon) 
    item_index = wesnoth.get_variable("gear_map_items.length")
    if item_index == nil then item_index = 0 end
    wesnoth.set_variable("gear_map_items["..item_index.."].id", gear_id)
    wesnoth.set_variable("gear_map_items["..item_index.."].cost", cost)
    wesnoth.set_variable("gear_map_items["..item_index.."].x", x_1)
    wesnoth.set_variable("gear_map_items["..item_index.."].y", y_1)
    end
    
   return icon
end

-- does not actually apply the gear, just takes the items off the map, and removes the WML variables
bmr_equipment.item_take = function(x_1, y_1, gear_id)
    local result = "fail"
    local item_index = 0
    local id_temp = ""
    local x_temp = ""
    local y_temp = ""
    item_max_index = wesnoth.get_variable("gear_map_items.length")
    while item_index < item_max_index do
      id_temp = wesnoth.get_variable("gear_map_items["..item_index.."].id")
      if id_temp == gear_id then
          x_temp = wesnoth.get_variable("gear_map_items["..item_index.."].x")
          y_temp = wesnoth.get_variable("gear_map_items["..item_index.."].y")
	  if x_temp == x_1 and y_temp == y_1 then
	    -- delete the WML record
	    wesnoth.set_variable("gear_map_items["..item_index.."]", nil)
	    -- remove the image from the map
	    local icon = ""
	    for j in ipairs(equipment_list.the_list) do  
	      if equipment_list.the_list[j].id == gear_id then
	          icon = equipment_list.the_list[j].icon
	          break
	      end
	    end
	    items.remove(x_1, y_1, icon) 	    
	    result = "pass"
	  end
      end
      item_index = item_index + 1    
    end
   return result
end

return bmr_equipment
