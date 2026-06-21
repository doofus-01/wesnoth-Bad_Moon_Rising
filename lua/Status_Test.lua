z_require("status_components")
--z_require("gui_hacks")
Status_test  = {}
Status_test.new = function()
local select_gear_id = {}
local select_pool_id = {}
local dr_x = 0
local dr_y = 0
local unit_id = 0

--[[ update 6-2026: starting to remove "callback" and "value_compat", as it doesn't look like they are documented]]

local dialog = {
  T.tooltip { id = "tooltip_large" },
  T.helptip { id = "helptip_large" },
  maximum_height = 800, maximum_width = 1100,   -- the only way to keep the scroll_label from spreading really wide, as far as I can tell                                                                   
  -- automatic_placement = false,                                             
  -- height = 850, width = 850, 
  T.grid { 
  	   T.row { T.column { T.label { id = "the_panel_title", use_markup = true}}},
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
			    	   	   						T.row { T.column { T.label { id = "the_title", use_markup = true 
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



local function preshow(self)
    event_context = wesnoth.current.event_context
    unit_cfg = wesnoth.units.get(event_context.x1,event_context.y1).__cfg
    local can_move = true
    if unit_cfg.moves == 0 then can_move = false end
    dr_x = event_context.x1
    dr_y = event_context.y1
    unit_id = unit_cfg.id
    unit_type = unit_cfg.type
    local u_vars = wml.get_child(unit_cfg, "variables")
    local total_xp = u_vars.total_xp
    total_xp = total_xp + unit_cfg.experience
    local the_unit = wesnoth.units.find_on_map({ id = unit_id })
    if the_unit[1] then
      else
          wesnoth.message("Filter_debugging4", string.format("status dialog preshow failed to find unit"))
    end

    local widget_handle = self:find('use_button')
    widget_handle.enabled = can_move
    widget_handle = self:find('delete_button')
    widget_handle.enabled = can_move
    widget_handle = self:find('drop_button')
    widget_handle.enabled = can_move
    widget_handle = self:find('inventory_button')
    widget_handle.enabled = can_move
    widget_handle = self:find('the_panel_title')
    widget_handle.marked_up_text = "<span size='xx-large' color='#eeffb7'> Unit Status </span>"
    widget_handle = self:find('the_title')
    widget_handle.marked_up_text = string.format("<span size='x-large' color='#eeffb7'> %s </span>", unit_cfg.name)
    widget_handle = self:find('the_gearlist_title')
    widget_handle.marked_up_text = "<span size='large' color='#eeffb7' underline='single'> Equipment </span>"
    widget_handle = self:find('the_poollist_title')
    widget_handle.marked_up_text = "<span size='large' color='#ddeea6' underline='single'> Inventory </span>"
--    set_simple_grid_values(unit_cfg, self)
--    set_child_grid_values(unit_cfg, self)
---------------------------------
-- the equipment list
    local gear_text = {}
    local gear_stat = {}
    local g_i = 1
    local u_gear = wml.get_child(unit_cfg, "variables")
-- changed gear.image SCALE(60,60) to 50,50
    for gear in wml.child_range(u_gear, "gear") do
        -- try getting the gear data from the big lua table, so we don't carry this around in the unit & savefile WML data
        for j in ipairs(equipment_list.the_list) do  
            if equipment_list.the_list[j].id == gear.id then
                widget_handle = self:find("the_gearlist", g_i, "the_gearlist_icon")
--                widget_handle.value_compat = string.format("%s~SCALE(60,60)", gear.image)
                widget_handle.marked_up_text = string.format("%s~SCALE(60,60)", equipment_list.the_list[j].image)
                widget_handle = self:find("the_gearlist", g_i, "the_gearlist_icon_name")
                widget_handle.marked_up_text = string.format("<span size='xx-small'>%s</span>", equipment_list.the_list[j].name)
	        gear_stat[g_i] = string.format("<span size='small'>Weight: %d \n +HP: %d \n Luck: %d \n Dodge: %d \n Accuracy: %d \n Damage: %d \n Cost %d g </span>", 	            
	            equipment_list.the_list[j].weight,
	            equipment_list.the_list[j].hp,
	            equipment_list.the_list[j].luck,
	            equipment_list.the_list[j].dodge,
	            equipment_list.the_list[j].accuracy,
	            equipment_list.the_list[j].damage,
	            equipment_list.the_list[j].cost
	            )
	        gear_text[g_i] = string.format("%s \n <span size='small' style='italic'> %s </span>", equipment_list.the_list[j].name, equipment_list.the_list[j].text)
                break
            end
        end
    -- wesnoth.set_dialog_value(string.format("<span size='xx-small'>%s</span>", gear.name), "the_gearlist", g_i, "the_gearlist_icon_name")
    -- wesnoth.set_dialog_markup(true, "the_gearlist", g_i, "the_gearlist_icon_name")
--	gear_text[g_i] = string.format("<span size='large'> %s </span> (Wt: %s) - %s", gear.name, gear.weight, gear.text)
	select_gear_id[g_i] = gear.id
	g_i = g_i + 1
--  wesnoth.message(equipment_grid_list_data)
    end
    set_simple_grid_values(unit_cfg, self)
    set_child_grid_values(unit_cfg, self)
--    set_simple_grid_values(unit_cfg, self)
--    set_child_grid_values(unit_cfg, self)

--    wesnoth.message(equipment_grid_list_data[3])
--remove the initial dummy list_data
--    table.remove(equipment_grid_list_data,1)
 --   table.remove(equipment_grid_list_data,2)
    if g_i == 1 then
	    -- wesnoth.set_dialog_active(false, "drop_button")
        widget_handle = self:find('drop_button')
        widget_handle.enabled = can_move
	    -- wesnoth.set_dialog_active(false, "inventory_button")
        widget_handle = self:find('inventory_button')
        widget_handle.enabled = can_move
    end
    local p_i = 1
    for j in ipairs(equipment_list.the_list) do -- can this be streamlined, or is there a reason we go through everything?
    -- set markp for pool list entry to red italic, then check unit can use it and change markup if yes
        local gpf_style = "italic"    
        local gpf_color = "#bf6655"    
        local gpf_weight = "light"
        local gpf_xp = " "
	local gear_pool_id = equipment_list.the_list[j].id
	local gear_pool_name = equipment_list.the_list[j].name
	local gear_pool_usage = equipment_list.the_list[j].usage
	local gear_pool_position = equipment_list.the_list[j].position
        local gear_pool_xp = equipment_list.the_list[j].xp_needed
--	local gear_pool_tooltip = equipment_list.the_list[j].tooltip
    -- local gear_pool_number = wesnoth.get_variable("gear_pool[0]."..gear_pool_id)
        local gear_pool_number = wml.variables["gear_pool[0]."..gear_pool_id]
	if gear_pool_number == nil then gear_pool_number = 0 end
        if gear_pool_usage == "potion" then
                  gpf_style = "normal"    -- normal and light orange if useable
                  gpf_color = "#cfffaa"
                  gpf_weight = "ultrabold"
        end
        if gear_pool_number > 0 then
            for k in ipairs(equipment_list.list_usage) do
                if equipment_list.list_usage[k].usage == gear_pool_usage then
                  for l in ipairs(equipment_list.list_usage[k].types) do 
                    if equipment_list.list_usage[k].types[l] == unit_type  and gear_pool_xp <= total_xp then
                      gpf_style = "normal"    -- normal and light blue if useable
                      gpf_color = "#cfdfff"
                      gpf_weight = "bold"
                      -- now check that the position isn't already taken
                      local gp_index = 0
                      local gp_index_max = 9 -- this should be improved on
                      while gp_index < gp_index_max do
                        local gear_position_iter = the_unit[1].variables["gear["..gp_index.."].position"]
                        if gear_position_iter then
                        else
                          break
                        end
                        if gear_position_iter == gear_pool_position then
                          gpf_color = "#44a9cb" -- darker and oblique if position is not available
                          gpf_style = "oblique"
                          gpf_weight = "normal"
                        end
                        gp_index = gp_index + 1
                      end
                    elseif equipment_list.list_usage[k].types[l] == unit_type  and gear_pool_xp > total_xp then
                      gpf_style = "normal"
                      gpf_color = "#cfdfff"
                      gpf_xp = gear_pool_xp - total_xp
                      gpf_xp = "</span><span size='xx-small' style='oblique' color='#ffaa33'> "..tostring(gpf_xp).."xp"
                    end
                  end -- for l
                end
            end -- for k
--	     wesnoth.add_dialog_tree_node("node1", i, "the_poollist")
	     -- wesnoth.set_dialog_value(string.format("<span size='x-small' font-style='%s' color='%s'>%s  ( %d )</span>", gpf_style, gpf_color, gear_pool_name, gear_pool_number), "the_poollist", p_i, "the_poollist_entry")
         widget_handle = self:find('the_poollist', p_i, 'the_poollist_entry')
         widget_handle.marked_up_text = string.format("<span size='x-small' font-style='%s' weight='%s' color='%s'>%s  ( %d ) %s</span>", gpf_style, gpf_weight, gpf_color, gear_pool_name, gear_pool_number, gpf_xp)
         -- wesnoth.set_dialog_markup(true, "the_poollist", p_i, "the_poollist_entry")
	     select_pool_id[p_i] = gear_pool_id
	     p_i = p_i + 1
        end
    end
    if p_i == 1 then
	    -- wesnoth.set_dialog_active(false, "use_button")
        widget_handle = self:find('use_button')
        widget_handle.enabled = can_move
	    -- wesnoth.set_dialog_active(false, "delete_button")
        widget_handle = self:find('delete_button')
        widget_handle.enabled = can_move
    end                                    

--
    local function select()
	-- so, index [i] is refering to the item selected
        -- local i = wesnoth.get_dialog_value "the_gearlist"
        widget_handle = self:find('the_gearlist')
        -- local i = widget_handle.value_compat
        local i = widget_handle.selected_index
	-- wesnoth.set_dialog_markup(true, "the_gear_description")
	if gear_text[i] then
	  else
	  gear_text[i] = "No description available."
	end
	if gear_stat[i] then
	  else
	  gear_stat[i] = "No equipment \n data available."
	end
	-- wesnoth.set_dialog_value(gear_text[i], "the_gear_description")
        local function bonus_format(widget,value)
            value = tonumber(value)
            widget_handle = self:find(widget)
            if value == 0 or value == nil then
                widget_handle.marked_up_text = " "
            else
                widget_handle.marked_up_text = string.format("<span color = '#909090' size = 'x-small'> (%d)</span>", value)
            end                
            return
        end
        widget_handle = self:find('the_gear_stats')
        widget_handle.marked_up_text = gear_stat[i]
        widget_handle = self:find('the_gear_description')
        widget_handle.marked_up_text = gear_text[i]
        --[[widget_handle = self:find('the_rg_arcane')
        widget_handle.marked_up_text = string.format("<span size='x-small'>%s </span>", select_gear_id[i])]] --successful test
        for j in ipairs(equipment_list.the_list) do  
            if equipment_list.the_list[j].id == select_gear_id[i] then
                local bonus = 0
                bonus = equipment_list.the_list[j].resist_arcane
                bonus_format("the_rg_bonus_arcane",bonus)
                bonus = equipment_list.the_list[j].resist_blade
                bonus_format("the_rg_bonus_blade",bonus)
                bonus = equipment_list.the_list[j].resist_cold
                bonus_format("the_rg_bonus_cold",bonus)
                bonus = equipment_list.the_list[j].resist_fire
                bonus_format("the_rg_bonus_fire",bonus)
                bonus = equipment_list.the_list[j].resist_impact
                bonus_format("the_rg_bonus_impact",bonus)
                bonus = equipment_list.the_list[j].resist_pierce
                bonus_format("the_rg_bonus_pierce",bonus)
                break
            end
        end        
        return select_gear_id[i]
    end
    -- wesnoth.set_dialog_callback(select, "the_gearlist")
    widget_handle = self:find('the_gearlist')
    widget_handle.on_modified = select
--    widget_handle.callback = select
    select() -- this is to give an initial value
end

local li = 0
local function postshow(self)
    -- li = wesnoth.get_dialog_value "the_gearlist"
    local widget_handle = self:find('the_gearlist')
    li = widget_handle.value_compat
    -- pli = wesnoth.get_dialog_value "the_poollist"
    widget_handle = self:find('the_poollist')
    pli = widget_handle.value_compat
 -- this is very inefficient, but replays do seem to work now.
    uli = unit_id
    dxli = dr_x
    dyli = dr_y
    sgli = select_gear_id[li]
    spli = select_pool_id[pli]
    wesnoth.interface.clear_chat_messages()
end

------------------------------------------------------------------------
-- for these three pool functions, need to have a position filter, eventually
------------------------------------------------------------------------

local function call_to_pool(u_i,sg_i)
  bmr_equipment.remove(u_i, sg_i)
  bmr_equipment.pool_add(sg_i)
end

local function call_from_pool(u_i,sp_i)
  local pter = bmr_equipment.unit(u_i, sp_i)
  if pter == "pass" or pter == "no room" then
    bmr_equipment.pool_remove(sp_i)
  end
  if pter == "potion" then
    bmr_equipment.pool_remove(sp_i)
    bmr_equipment.pool_remove(sp_i) -- this is to get rid of the copy made by bmr_equipment.unit, there is probably a better way to do this
    bmr_equipment.consume(u_i,sp_i)
  end
end

local function delete_from_pool(sp_i)
  bmr_equipment.pool_remove(sp_i)
end

local function call_drop(u_i,d_x,d_y,sg_i)
  bmr_equipment.remove(u_i, sg_i)
  bmr_equipment.item_drop(d_x, d_y, sg_i)
end

local result = wesnoth.sync.evaluate_single(
  function()
    local rv = gui.show_dialog(dialog, preshow, postshow)
    return { rvs = rv, lis = li, plis = pli, ulis = uli, dxlis = dxli, dylis = dyli, sglis = sgli, splis = spli} -- keys end in 's' for 'synchronized'
  end,
  function()
    error("status_meu called by ai?")
  end)
 while result.rvs > 0 do
  if result.rvs == 3 then  --dropping: needs unit_id, context (x,y), and selected gear_id
    call_drop(result.ulis,result.dxlis,result.dylis,result.sglis)
  elseif result.rvs == 4 then  -- sending to inventory: needs unit_id, selected gear_id
    call_to_pool(result.ulis,result.sglis)
  elseif result.rvs == 6 then  -- calling from inventory: needs unit_id, selected pool-item_id
    call_from_pool(result.ulis,result.splis)
  elseif result.rvs == 5 then  -- delete from inventory: needs selected pool-item_id
    delete_from_pool(result.splis)
  end
    result = wesnoth.sync.evaluate_single(
    function()
      local rv = gui.show_dialog(dialog, preshow, postshow) -- called a second time because we are in a loop now
      return { rvs = rv, lis = li, plis = pli, ulis = uli, dxlis = dxli, dylis = dyli, sglis = sgli, splis = spli}
    end,
    function()
      error("status_meu called by ai?")
    end)
 end

end

return Status_test
