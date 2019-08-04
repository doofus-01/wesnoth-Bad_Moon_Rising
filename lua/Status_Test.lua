z_require("status_components")
--z_require("gui_hacks")
Status_test  = {}
Status_test.new = function()
local select_gear_id = {}
local select_pool_id = {}
local dr_x = 0
local dr_y = 0
local unit_id = 0
--local equipment_grid_list_data = {}
--local event_context = wesnoth.current.event_context
--local unit_cfg = wesnoth.get_unit(event_context.x1,event_context.y1).__cfg
--local u_gear = helper.get_child(unit_cfg, "variables")
--local function equip_data_table_f()
--    for gear in helper.child_range(u_gear, "gear") do	
--	local equip_data = equipment_grid_data(string.format("%s~SCALE(60,60)", gear.image), string.format("<span size='xx-small'>%s</span>", gear.name), gear.text)
--	if equipment_grid_list_data[1] == nil then
--	wesnoth.message("first...")
--	equipment_grid_list_data = {"row", {equip_data}}
--	end
--	wesnoth.message("iterating...")
--	table.insert(equipment_grid_list_data, {"row", {equip_data}})
--	wesnoth.message(equip_data[4])
--    end
--    return equipment_grid_list_data
--end


--[[local equipment_grid_list_data = T.row{ T.column{
	T.widget{id = "the_gearlist_icon", label = "misc/empty.png~SCALE(60,60)"},
	T.widget{id = "the_gearlist_icon_name", label = "dummy label", tooltip = "dummy tooltip"}
}}
]]
--[[	{"row" , {"column" ,
		{"widget" , {id = "the_gearlist_icon", label = "misc/empty.png"}}, 
		{"widget" , {id = "the_gearlist_icon_name", label = "dummy label", tooltip = "dummy tooltip"}}
		}
		}
]]

local dialog = {
  T.tooltip { id = "tooltip_large" },
  T.helptip { id = "helptip_large" },
  maximum_height = 800, maximum_width = 800,   -- the only way to keep the scroll_label from spreading really wide, as far as I can tell                                                                   
  -- automatic_placement = false,                                             
  -- height = 850, width = 850, 
  T.grid { 
  	   T.row { T.column { T.label { id = "the_panel_title"}}},
           T.row { T.column { T.grid {
			           T.row { 
			           		T.column {  horizontal_alignment = "left" , T.grid { --left grid
			           								T.row { T.column { misc_status_grid()},
			           			 					       },
			           			 					T.row { T.column { movementcost_grid()},
			           			 					       },
			           			 					T.row { T.column { border = "all", border_size = 5, horizontal_alignment = "center", vertical_alignment = "center",
			           			 								T.drawing { id = "left_line", width = 300, height = 30, T.draw { 
			           			 										T.line { x1 = 1, y1 = 15, x2 = 299, y2 = 15, color = "255,255,255,255", thickness = 3}, T.text { font_size = 1 } }}
			           			 							}
			           			 					       },
			           			 					T.row { T.column { inventory_grid()}
			           			 					       }
			           			  }},
			    	   	   	T.column {vertical_alignment = "top" , T.grid { --right grid
			    	   	   						T.row { T.column { T.spacer { height = 20 
			    	   	   						}}},
			    	   	   						T.row { T.column { T.image { id = "the_image" 
			    	   	   						}}},
			    	   	   						T.row { T.column { T.label { id = "the_title" 
			    	   	   						}}},
			           			 				T.row { T.column { border = "all", border_size = 5, horizontal_alignment = "center", vertical_alignment = "center",
			           			 							T.drawing { id = "left_line", width = 300, height = 60, T.draw { 
			           			 								T.line { x1 = 1, y1 = 15, x2 = 299, y2 = 15, color = "255,255,255,255", thickness = 3}, T.text { font_size = 1 } }}
			           			 							}
			           			 					       },
			    	   	   						T.row { T.column { vertical_alignment = "top" , T.panel { --[[definition = "wml_message",]] id = "the_equipment_panel" , height = 500, width = 400, equipment_grid() 
--			    	   	   						T.row { T.column { vertical_alignment = "top" , T.panel { --[[definition = "wml_message",]] id = "the_equipment_panel" , height = 500, width = 400, equipment_grid(equipment_grid_list_data) 
			    	   	   						}}}
			    	   	   		  }}
					  }
	          }}},
	   T.row { T.column { T.spacer { height = 24 }}},
      	   T.row { 
      	          T.column { T.grid { T.row {
			          T.column { T.button { id = "ok", label = _"OK" } },
		 	}}}
		 }
	   }

}



local function preshow()
    event_context = wesnoth.current.event_context
    unit_cfg = wesnoth.get_unit(event_context.x1,event_context.y1).__cfg
    local can_move = true
    if unit_cfg.moves == 0 then can_move = false end
    dr_x = event_context.x1
    dr_y = event_context.y1
    unit_id = unit_cfg.id
    wesnoth.set_dialog_active(can_move, "use_button")
    wesnoth.set_dialog_active(can_move, "delete_button")
    wesnoth.set_dialog_active(can_move, "drop_button")
    wesnoth.set_dialog_active(can_move, "inventory_button")
    wesnoth.set_dialog_markup(true, "the_panel_title")
    wesnoth.set_dialog_value("<span size='xx-large' color='#eeffb7'> Unit Status </span>" , "the_panel_title")
    wesnoth.set_dialog_markup(true, "the_title")
    wesnoth.set_dialog_value(string.format("<span size='x-large' color='#eeffb7'> %s </span>", unit_cfg.name) , "the_title")
    wesnoth.set_dialog_markup(true, "the_gearlist_title")
    wesnoth.set_dialog_value("<span size='large' color='#eeffb7' underline='single'> Equipment </span>" , "the_gearlist_title")
    wesnoth.set_dialog_markup(true, "the_poollist_title")
    wesnoth.set_dialog_value("<span size='large' color='#ddeea6' underline='single'> Inventory </span>" , "the_poollist_title")
    set_simple_grid_values(unit_cfg)
    set_child_grid_values(unit_cfg)
    -- the equipment list
    local gear_text = {}
    local g_i = 1
    local u_gear = helper.get_child(unit_cfg, "variables")
-- changed gear.image SCALE(60,60) to 50,50
--    wesnoth.message(equipment_grid_list_data[1])
--    wesnoth.message(equipment_grid_list_data[2][1])
    for gear in helper.child_range(u_gear, "gear") do
--	table.insert(equipment_grid_list_data,equipment_grid_data(string.format("%s~SCALE(60,60)", gear.image), string.format("<span size='xx-small'>%s</span>", gear.name), gear.text))
	wesnoth.set_dialog_value(string.format("%s~SCALE(60,60)", gear.image), "the_gearlist", g_i, "the_gearlist_icon")
	wesnoth.set_dialog_value(string.format("<span size='xx-small'>%s</span>", gear.name), "the_gearlist", g_i, "the_gearlist_icon_name")
	wesnoth.set_dialog_markup(true, "the_gearlist", g_i, "the_gearlist_icon_name")
	gear_text[g_i] = string.format("<span size='large'> %s </span> (Wt: %s) - %s", gear.name, gear.weight, gear.text)
	select_gear_id[g_i] = gear.id
	g_i = g_i + 1
--  wesnoth.message(equipment_grid_list_data)
    end
--    wesnoth.message(equipment_grid_list_data[3])
--remove the initial dummy list_data
--    table.remove(equipment_grid_list_data,1)
 --   table.remove(equipment_grid_list_data,2)
    if g_i == 1 then
	    wesnoth.set_dialog_active(false, "drop_button")
	    wesnoth.set_dialog_active(false, "inventory_button")
    end
    local p_i = 1
    for j in ipairs(equipment_list.the_list) do
	local gear_pool_id = equipment_list.the_list[j].id
	local gear_pool_name = equipment_list.the_list[j].name
--	local gear_pool_tooltip = equipment_list.the_list[j].tooltip
	local gear_pool_number = wesnoth.get_variable("gear_pool[0]."..gear_pool_id)
	if gear_pool_number == nil then gear_pool_number = 0 end
        if gear_pool_number > 0 then
--	     wesnoth.add_dialog_tree_node("node1", i, "the_poollist")
	     wesnoth.set_dialog_value(string.format("<span size='x-small'>%s  ( %d )</span>", gear_pool_name, gear_pool_number), "the_poollist", p_i, "the_poollist_entry")
	     wesnoth.set_dialog_markup(true, "the_poollist", p_i, "the_poollist_entry")
	     select_pool_id[p_i] = gear_pool_id
	     p_i = p_i + 1
        end
    end
    if p_i == 1 then
	    wesnoth.set_dialog_active(false, "use_button")
	    wesnoth.set_dialog_active(false, "delete_button")
    end                                    

--
    local function select()
	-- so, index [i] is refering to the item selected
        local i = wesnoth.get_dialog_value "the_gearlist"
	wesnoth.set_dialog_markup(true, "the_gear_description")
	if gear_text[i] then
	  else
	  gear_text[i] = "No equipment available."
	end
-- testing -> fail, there is no such widget as "tooltip"
--	wesnoth.set_dialog_value(string.format(" testing : %s ", gear_text[i]), "the_tooltip")
-- /testing
	wesnoth.set_dialog_value(gear_text[i], "the_gear_description")
	return select_gear_id[i]
    end
    wesnoth.set_dialog_callback(select, "the_gearlist")
    select()
end

local li = 0
local function postshow()
    li = wesnoth.get_dialog_value "the_gearlist"
    pli = wesnoth.get_dialog_value "the_poollist"
    wesnoth.clear_messages()
end

------------------------------------------------------------------------
-- for these three pool functions, need to have a position filter, eventually
------------------------------------------------------------------------

local function call_to_pool(r,i)
--  wesnoth.message(string.format("Button %d pressed.  Item selected for send to pool was %s", r, select_gear_id[i]))
  bmr_equipment.remove(unit_id, select_gear_id[i])
  bmr_equipment.pool_add(select_gear_id[i])
end

local function call_from_pool(r,i)
-- 20150712 - I think this is the problem...  Trying to equip an item from inventory for the wrong unit type causes number of items to increase by one
-- we are currently only pool_remove if filter passed, but maybe that should change...
-- would placing "wrong type" in the if filter solve this?  See equipment_write.lua line 79.
--  wesnoth.message(string.format("Button %d pressed.  Item selected for call from pool was %s", r, select_pool_id[i]))
  local pter = bmr_equipment.unit(unit_id, select_pool_id[i])
--  if pter == "pass" then
  if pter == "pass" or pter == "no room" then
    bmr_equipment.pool_remove(select_pool_id[i])
  end
end

local function delete_from_pool(r,i)
--  wesnoth.message(string.format("Button %d pressed.  Item selected for delete was %s, item %d", r, select_pool_id[i], i))
  bmr_equipment.pool_remove(select_pool_id[i])
end

local function call_drop(r,i)
--  local sg_id = select_gear_id[i]
--wesnoth.message(string.format("Button %d pressed.  Item selected for drop was %s", r, select_gear_id[i]))
--wesnoth.message(string.format("Standing in %d x-position.  Unit selected was %s", dr_x, unit_id))
  bmr_equipment.remove(unit_id, select_gear_id[i])
  bmr_equipment.item_drop(dr_x, dr_y, select_gear_id[i])
end

-- I have no idea if this sync'ing actually works, but it didn't seem to break anything
local result = wesnoth.synchronize_choice(
--  wesnoth.message(equipment_grid_list_data)
  function()
--    event_context = wesnoth.current.event_context
--    unit_cfg = wesnoth.get_unit(event_context.x1,event_context.y1).__cfg
--    local u_gear = helper.get_child(unit_cfg, "variables")
--    for gear in helper.child_range(u_gear, "gear") do	
--	local equip_data = equipment_grid_data(string.format("%s~SCALE(60,60)", gear.image), string.format("<span size='xx-small'>%s</span>", gear.name), gear.text)
--	table.insert(equipment_grid_list_data, equip_data)
--	wesnoth.message(equip_data[4])
--    end
    local rv = wesnoth.show_dialog(dialog, preshow, postshow)
    return { rvs = rv, lis = li, plis = pli}
  end,
  function()
    error("status_meu called by ai?")
  end)
--if can_move== true then
 while result.rvs > 0 do
--call_assign(rv,li)
--droppin
  if result.rvs == 3 then
    call_drop(result.rvs,result.lis)
  elseif result.rvs == 4 then
-- sending to inventory
    call_to_pool(result.rvs,result.lis)
-- calling from inventory - no button yet
  elseif result.rvs == 6 then
    call_from_pool(result.rvs,result.plis)
-- delete from inventory
  elseif result.rvs == 5 then  
    delete_from_pool(result.rvs,result.plis)
  end
    result = wesnoth.synchronize_choice(
    function()
--    event_context = wesnoth.current.event_context
--    unit_cfg = wesnoth.get_unit(event_context.x1,event_context.y1).__cfg
--    local u_gear = helper.get_child(unit_cfg, "variables")
--    for gear in helper.child_range(u_gear, "gear") do
--	table.insert(equipment_grid_list_data,equipment_grid_data(string.format("%s~SCALE(60,60)", gear.image), string.format("<span size='xx-small'>%s</span>", gear.name), gear.text))
--	wesnoth.message(gear.name)
--    end
      local rv = wesnoth.show_dialog(dialog, preshow, postshow)
      return { rvs = rv, lis = li, plis = pli}
    end,
    function()
      error("status_meu called by ai?")
    end)
 end
--else
--  if rv > 0 then wesnoth.show_dialog(dialog2, preshow2, postshow2) end
--end

--
end

return Status_test
