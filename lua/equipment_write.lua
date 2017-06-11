
-- this will check for a unit that has a unit.variables.gear.<item_name>=new, and check it against equipment_list.list_by_name.  If it matches something, apply the effects and set =old.
-- later, when we need to access the values of the equipment, we can refer to the lua file, retrieving the name from unit.variables.gear_old
-- want to make this a tag
bmr_equipment = {}
-- this .filter function returns "on_map" if unit on map, "on_recall" if on recall list, but "not found" if unit is not found or "wrong type" if it is wrong type for gear
bmr_equipment.filter = function(unit_id, gear_id)    
      local result = "wrong type"
      local units = {}  
      local l_usage = ""
      units = wesnoth.get_units({ id = unit_id })
      if units[1] then
--	result = "on_map"
      else
        units = wesnoth.get_recall_units({ id = unit_id })
	if units[1] then
--	  result = "on_recall"
        else
          result = "not found"
          return result
	end
      end
      -- find the equipment in the list
      for j in ipairs(equipment_list.the_list) do  
        if equipment_list.the_list[j].id == gear_id then
          l_usage = equipment_list.the_list[j].usage
--          wesnoth.message(string.format("l_usage is %s", l_usage))
          break
        end
      end
--          wesnoth.message(string.format("l_usage for %s using %s is %s", unit_id, gear_id, l_usage))
      -- find the usage rule in the list_usage
      for j in ipairs(equipment_list.list_usage) do
        if equipment_list.list_usage[j].usage == l_usage then
          -- wesnoth.message(string.format("unit type is %s", units[1].type))
          for k in ipairs(equipment_list.list_usage[j].types) do                                                                                                               
            -- if found, nothing changes, otherwise, set result = "false"
            if equipment_list.list_usage[j].types[k] == units[1].type then
              result = "pass"
              break
            end
          end  
        end  
      end     
return result
end

-- moved up from below
-- adds the gear id to a list that can be used by another unit on the recall list
bmr_equipment.pool_add = function(gear_id) 
    local gear_number = wesnoth.get_variable("gear_pool[0]."..gear_id)
    if gear_number == nil then gear_number = 0 end
    gear_number = gear_number + 1
    wesnoth.set_variable("gear_pool[0]."..gear_id, gear_number)
--to do: have a check if gear_id is not valid        
return gear_number
end

-- this function applies the gear, returns "pass" if successful, "fail" if not                                                                          
bmr_equipment.unit = function(unit_id, gear_id)

      local result = "fail"
      local gear_name = ""
      local gear_cost = ""
      local gear_image = ""
      local gear_text = ""
      local gear_position = ""
      local eq_eff = ""
      local units = {}
--      local gear_index = 1
      units = wesnoth.get_units({ id = unit_id })      
      if units[1] then
      else
        units = wesnoth.get_recall_units({ id = unit_id })      
      end  
      local filter_result = bmr_equipment.filter(unit_id, gear_id)
      if filter_result == "wrong type" then
-- sending to inventory, for cases where item is coming from the map or a WML tag.  If it is coming from inventory, it is problem
-- see also line 168, similar problem.  I think this is fixed now, in Status_Test.lua line 139
	  bmr_equipment.pool_add(gear_id)
	  result = "no room"
          wesnoth.message("Notice", gear_id)      
--          wesnoth.message("Notice", "This unit cannot use this item.")      
	  return result
      elseif filter_result == "not found" then
--          wesnoth.message(string.format("%s is not found for the %s", unit_id, gear_id))      
	  return result
      elseif filter_result == "pass" then
--          wesnoth.message(string.format("%s is going to wear the %s", unit_id, gear_id))      
--------------------------------------------------------------------------------
-- local event_context = wesnoth.current.event_context
-- local event_name = string.format("%s", event_context.name)

--    if event_name == "prestart" then
-- eventually, make it so that this side = 1 is not hard-coded, but it is a catchall, so shouldn't matter too much.
--       units = wesnoth.get_units({ side = 1 })
--    else
--       table.insert(units, wesnoth.get_unit(event_context.x1, event_context.y1))
--    end
    
-- check the equipment in unit.variables.gear against the equipment_list.the_list
-- we are just going to use one unit, don't need this ipairs
--    for i in ipairs(units) do
-- need to find the item in the list
      for j in ipairs(equipment_list.the_list) do
	if equipment_list.the_list[j].id == gear_id then
		  eq_eff = equipment_list.the_list[j].eq_effect
		--  debug_utils.dbms(units[1], true, "units[1] ", true)
--		  wesnoth.add_modification(units[1], "object", eq_eff)
		  gear_name = equipment_list.the_list[j].name
		  gear_cost = equipment_list.the_list[j].cost
		  gear_image = equipment_list.the_list[j].image
		  gear_text = equipment_list.the_list[j].text
		  gear_position = equipment_list.the_list[j].position
		  break
	end
      end


-- might not neeed this...
--      local u_vars = helper.get_child( units[1].__cfg, "variables")
--      for gear in helper.child_range( u_vars, "gear") do
--	gear_index = gear_index + 1
--      end
-- error     table.insert(units[1].__cfg.variables[2], {"gear", {
--		  debug_utils.dbms(units[1].variables[1].variables[1].variables[1].variables[1], true, "unit_variables", true)

-- this works, but goes to a local variable, not the proxy unit	-- local uvar = helper.get_child( units[1].__cfg, "variables")	
      local old_gear = {}
      local old_gear_pos = nil
      local gindex = 0
      wesnoth.fire("store_unit", { variable="my_unit", { "filter", { id = unit_id } } })
--   will this overwrite it? yes, need to find way to get index
--      local muv_i_lua = 0
-- this does not work, you cannot use variable substitution, it seems
--      wesnoth.set_variable("muv_i_wml", muv_i_lua)
--      local g_test =  wesnoth.get_variable("my_unit.variables.gear[$muv_i_wml].id")      
--      while g_test do
--	table.insert(old_gear, wesnoth.get_variable("my_unit.variables.gear[$muv_i_wml]"))
--	wesnoth.message(string.format("old gear = %s", old_gear))
--	muv_i_lua = muv_i_lua + 1
--        wesnoth.set_variable("muv_i_wml", muv_i_lua)
--        g_test = wesnoth.get_variable("my_unit.variables.gear[$muv_i_wml].ido")
--      end
--      wesnoth.set_variable("my_unit.variables.gear[$muv_i_wml]", {
-- nil		  debug_utils.dbms(units[1].variables[1].variables[1].variables[1].variables[1][6], true, "before gear3", true)
-- nil		  debug_utils.dbms(units[1].variables[1].variables[1].variables[1].variables[1].variables[1][6], true, "before gear2", true)
-- nil		  debug_utils.dbms(units[1].variables[1].variables[1].variables[6], true, "before gear1", true)
-- nil		  debug_utils.dbms(units[1][1], true, "before gear0", true)
--      for j in ipairs(units[1].variables.gear) do
--      table.insert(old_gear, units[1].variables.gear[j])
--      end
--		  debug_utils.dbms(old_gear, true, "old_gear", true)
--      helper.set_variable_array("my_unit.variables.gear", {
-- this works, but errors still go out to consol.  need to find out still...
      local gindex_max = wesnoth.get_variable("my_unit.variables.gear.length")
--      while wesnoth.get_variable("my_unit.variables.gear["..gindex.."]") do
      while gindex < gindex_max do
	  old_gear_pos = wesnoth.get_variable("my_unit.variables.gear["..gindex.."].position")
	  if old_gear_pos == gear_position then
	    break
	  end
	  old_gear_pos = nil
          gindex = gindex + 1
      end
-- this 'no room' stuff needs to go to the filter function at some point
      if old_gear_pos then
--          wesnoth.message(string.format("%s has no room to wear the %s", unit_id, gear_id))      
	  bmr_equipment.pool_add(gear_id) --problem is that they can now get new item everytime they try to use in inventory dialog <- think this is fixed
	  result = "no room"
      else
          wesnoth.set_variable("my_unit.variables.gear[" .. gindex .. "]", {
-- iterate over all elements of the table to get the correct index, then use that directly
--		  debug_utils.dbms(units[1].__cfg[6][2], true, "unit_variables_before_gear", true)
-- is not doing anything      
--      table.insert(units[1].__cfg[6], {{"gear", {
--      	name = "test dummy",
      		name = gear_name,
		cost = gear_cost,
      		image = gear_image,
      		text = gear_text,
      		id = gear_id,
      		position = gear_position
      		})
--      }}})
          wesnoth.fire("unstore_unit", { variable="my_unit", find_vacant = "no"})
	  wesnoth.add_modification(units[1], "object", eq_eff)
	  result = "pass"

      end
--------------------------------------------------------------------------------
      end
      
return result
end

bmr_equipment.remove = function(unit_id, gear_id)
-- smplified with the advent of [remove_object]
      local result = ""
      local old_gear = ""
--      local neq_eff = "nothing"
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

--      for j in ipairs(equipment_list.the_list) do
--	 if equipment_list.the_list[j].id == gear_id then
--	    neq_eff = equipment_list.the_list[j].neg_eq_effect
--	 end
--      end
--      if neq_eff == "nothing" then result = nil end --need a better failsafe
      wesnoth.fire("store_unit", { variable="my_unit", { "filter", { id = unit_id } } })
-- first check that the unit really has the gear 
      while wesnoth.get_variable("my_unit.variables.gear["..gindex.."]") do
	  old_gear_id = wesnoth.get_variable("my_unit.variables.gear["..gindex.."].id")
	  if old_gear_id == gear_id then
	    break
	  end
	  old_gear_id = nil
          gindex = gindex + 1
      end
-- then delete the gear variables, and apply the negative object
      if old_gear_id then
          wesnoth.set_variable("my_unit.variables.gear[" .. gindex .. "]", nil)
          wesnoth.fire("unstore_unit", { variable="my_unit", find_vacant = "no"})
--	  wesnoth.add_modification(units[1], "object", neq_eff)
          wesnoth.fire("remove_object", { id = unit_id, object_id = gear_id})

-- then remove the object and anti-object, storing unit again
--[[ no longer needed
          wesnoth.fire("store_unit", { variable="my_unit", { "filter", { id = unit_id } } })
          local o_index_max = wesnoth.get_variable("my_unit.modifications.object.length")
	  local o_index = 0
          while o_index < o_index_max do
	      local obj_temp = wesnoth.get_variable("my_unit.modifications.object["..o_index.."].name")
	      if obj_temp == gear_id then	  	  
	          wesnoth.set_variable("my_unit.modifications.object["..o_index.."]", nil)
	      end
	      o_index = o_index + 1
	  end
	  local o_index = 0
          while o_index < o_index_max do
	      local obj_temp = wesnoth.get_variable("my_unit.modifications.object["..o_index.."].name")
	      if obj_temp == "n_"..gear_id then	  	  
	          wesnoth.set_variable("my_unit.modifications.object["..o_index.."]", nil)
	      end
	      o_index = o_index + 1
	  end
          wesnoth.fire("unstore_unit", { variable="my_unit", find_vacant = "no"})
]]
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



--[[

function wesnoth.wml_actions.apply_gear(cfg)
	local unit_id = cfg.id or helper.wml_error "[apply_gear] expects an id= attribute."
	local gear_id = cfg.gear_id or helper.wml_error "[apply_gear] expects a gear_id= attribute."
	local filter_result = bmr_equipment.filter(unit_id, gear_id)
        local app_unit = bmr_equipment.unit(unit_id, gear_id)
        local eq_unit = wesnoth.get_units({ id = unit_id })
	if eq_unit[1] then
	    bmr_equipment.item_take(eq_unit[1].x, eq_unit[1].y, gear_id)
        end
end
]]

--[[function wesnoth.wml_actions.apply_gear(cfg)
	local unit_id = cfg.id or helper.wml_error "[apply_gear] expects an id= attribute."
	local gear_id = cfg.gear_id or helper.wml_error "[apply_gear] expects a gear_id= attribute."
	local filter_result = bmr_equipment.filter(unit_id, gear_id)
	if filter_result == "on_map" then
          local app_unit = bmr_equipment.unit(unit_id, gear_id)
-- this needs revision
          if app_unit == "pass" then
            local eq_unit = wesnoth.get_units({ id = unit_id })
	    bmr_equipment.item_take(eq_unit[1].x, eq_unit[1].y, gear_id)
          else
            wesnoth.message(string.format("%s cannot use the %s (map)", unit_id, gear_id))
            local eq_unit = wesnoth.get_units({ id = unit_id })
	    bmr_equipment.item_take(eq_unit[1].x, eq_unit[1].y, gear_id)
	  end
	elseif filter_result == "on_recall" then
          local app_unit = bmr_equipment.unit(unit_id, gear_id)
          if app_unit == "pass" then
          else
            wesnoth.message(string.format("%s cannot use the %s (recall)", unit_id, gear_id))
	  end
        else
          wesnoth.message(string.format("%s cannot use the %s (general - %s)", unit_id, gear_id, filter_result))
        end
end]]

--[[
function wesnoth.wml_actions.remove_gear(cfg)
	local unit_id = cfg.id or helper.wml_error "[remove_gear] expects an id= attribute."
	local gear_id = cfg.gear_id or helper.wml_error "[remove_gear] expects a gear_id= attribute."
	if bmr_equipment.remove(unit_id, gear_id) == "on_map" then
          local eq_unit = wesnoth.get_units({ id = unit_id })
	  bmr_equipment.item_drop(eq_unit[1].x, eq_unit[1].y, gear_id)
          wesnoth.message(string.format("%s on map", unit_id))
	elseif bmr_equipment.remove(unit_id, gear_id) == "on_recall" then
	  bmr_equipment.pool_add(gear_id)
          wesnoth.message(string.format("%s on recall", unit_id))
        else
          wesnoth.message(string.format("%s does not have %s", unit_id, gear_id))
        end
end

function wesnoth.wml_actions.gear_item(cfg)
	local x_1 = cfg.x or helper.wml_error "[gear_item] expects an x= attribute."
	local y_1 = cfg.y or helper.wml_error "[gear_item] expects an y= attribute."
	local gear_id = cfg.gear_id or helper.wml_error "[gear_item] expects a gear_id= attribute."
	bmr_equipment.item_drop(x_1, y_1, gear_id)
end	

function wesnoth.wml_actions.remove_gear_item(cfg)
	local x_1 = cfg.x or helper.wml_error "[remove_gear_item] expects an x= attribute."
	local y_1 = cfg.y or helper.wml_error "[remove_gear_item] expects an y= attribute."
	local gear_id = cfg.gear_id or helper.wml_error "[remove_gear_item] expects a gear_id= attribute."
	bmr_equipment.item_take(x_1, y_1, gear_id)
end	
]]

return bmr_equipment
