-- 2026-06-20 - cleaned up a lot of old Lua API and fixed some formatting.  Pango formatting randomly fails, so some text is formatted, some isn't, and it isn't consistent; still trying to figure it out...
-- local T = helper.set_wml_tag_metatable {}
local T = wml.tag

function equipment_grid(data)
	return T.grid{
		T.row { T.column { T.label { id = "the_gearlist_title", use_markup = true }}},
		T.row { T.column { vertical_grow = false, horizontal_alignment = "left" , horizontal_grow = false, T.horizontal_listbox { horizontal_scrollbar_mode = "never", id = "the_gearlist" , 
		    T.list_definition { T.row { T.column {
					grow_factor = 1, horizontal_grow = true, vertical_grow = true,
					T.toggle_panel { T.grid {
								T.row { T.column { T.image { id = "the_gearlist_icon"}}},
								T.row { T.column { T.label { use_markup = true, id = "the_gearlist_icon_name", use_markup = true}}}
								}}
				}}} --,
			}}},
		T.row { T.column { T.grid {
					T.row {
					       T.column { T.button { tooltip = "Remove from unit and send to side inventory.  Inactive if unit has no moves left.", id = "inventory_button", label = _"Send to Inventory" , return_value = 4 } },
					       T.column { T.button { tooltip = "Remove from unit and place on map.  Inactive if unit has no moves left.", id = "drop_button", label = _"Drop" , return_value = 3 } }
					       }
					   }}},

-- this spacer is to prevent resizing with change of label text, but might not be the best way
		T.row { T.column { horizontal_grow = true, T.spacer { width = 550 }}},
-- cannot get characters_per_line to be recognized in scroll_label, must not be supported.
		T.row { T.column { horizontal_grow = true, T.grid {
		                        T.row { 
		                               T.column { vertical_grow = false, horizontal_grow = false , horizontal_alignment = "left", T.label { text_alignment = 'left', id = "the_gear_stats", use_markup = true}},
		                               T.column { vertical_grow = false, horizontal_grow = false , T.spacer { width = 8 }},
		                               T.column { vertical_grow = false, horizontal_grow = true , T.label { characters_per_line = 50, wrap = true, id = "the_gear_description", use_markup = true}}
		                               }
		                           }}}
--		T.row { T.column { vertical_grow = false, horizontal_grow = false , horizontal_alignment = "left", T.scroll_label { vertical_scrollbar_mode = "always", characters_per_line = 36, wrap = true, id = "the_gear_description"}}}
		}                                    

end		                                                                                                                                                                                                                                                                                                                                                                                        					

-- to use to insert into a list_data table
function equipment_grid_data(equ_icon, equ_label, equ_tooltip) 
	wesnoth.message(equ_icon)
	return T.column{ 
			T.widget{id = "the_gearlist_icon", label = equ_icon, tooltip = equ_tooltip},
			T.widget{id = "the_gearlist_icon_name", label = equ_label, tooltip = equ_tooltip}
			}
end

function inventory_grid()
	return T.grid{
		T.row { T.column { border = "all", border_size = 5, T.label { id = "the_poollist_title", use_markup = true }}},
		T.row { T.column { horizontal_alignment = "center" , T.listbox { max_height = 80, vertical_scrollbar_mode = "always", id = "the_poollist" , T.list_definition { T.row { T.column {horizontal_grow = true,
						T.toggle_panel { T.grid { T.row { T.column {border = "all", border_size = 2, horizontal_alignment = "center", T.label { wrap = true, characters_per_line = 18, id = "the_poollist_entry", use_markup = true}}}}} 
						  }}}}}},
		T.row { T.column { T.grid {
								  T.row {
								          T.column { T.button { tooltip = "Use or equip item.  Inactive if unit has no moves left.", id = "use_button", label = _"Use" , return_value = 6 } }, 
                                                                          T.column { T.button { tooltip = "Delete item.  Inactive if unit has no moves left.", id = "delete_button", label = _"Delete" , return_value = 5 } }
                                                                         }
                                               }}}

		}
end

function rg_row(header_id,header_label,value_id,bonus_id)
	return T.row { T.column { horizontal_alignment = "left" , vertical_grow = true, T.label {definition = "default_small", id = header_id , label = header_label }}, T.column { T.spacer { width = 10 }}, T.column { horizontal_grow = true , T.label { id = value_id , text_alignment = "center", use_markup = true}}, T.column { horizontal_grow = true , T.label { text_alignment = "left", id = bonus_id , use_markup = true}}}
end

function resistances_grid()
	return T.grid {
		T.row { T.column { T.label { id = "the_rg_title", use_markup = true}}},
		T.row { T.column { horizontal_grow = true, T.grid {
		rg_row("header_arcane","Arcane","the_rg_arcane","the_rg_bonus_arcane"),
		rg_row("header_blade","Blade","the_rg_blade","the_rg_bonus_blade"),
		rg_row("header_cold","Cold","the_rg_cold","the_rg_bonus_cold"),
		rg_row("header_fire","Fire","the_rg_fire","the_rg_bonus_fire"),
		rg_row("header_impact","Impact","the_rg_impact","the_rg_bonus_impact"),
		rg_row("header_pierce","Pierce","the_rg_pierce","the_rg_bonus_pierce")
					}}}
			} 
end

function terrain_row(string, header_label)
	return T.row { T.column { horizontal_alignment = "left", T.label { definition = "default_small", id = "header_"..string , label = header_label }} , T.column { horizontal_grow = true, T.label { text_alignment = 'center', id = "the_mcg_"..string, use_markup = true}} , T.column { horizontal_grow = true, T.label { text_alignment = 'center', id = "the_dg_"..string, use_markup = true}}}
end


function movementcost_grid()
	return T.grid {
		T.row { T.column { T.spacer { id = "mc_spacer" }} , T.column { T.label { id = "the_mcg_title", use_markup = true }} , T.column { T.label { id = "the_dg_title", use_markup = true }}},
                terrain_row("shallow_water","Shallow Water"),
                terrain_row("reef","Reef"),
                terrain_row("swamp_water","Swamp Water"),
                terrain_row("deep_water","Deep Water"),
                terrain_row("flat","Flat"),
                terrain_row("frozen","Frozen"),
                terrain_row("sand","Sand"),
                terrain_row("fungus","Fungus"),
                terrain_row("forest","Forest"),
                terrain_row("cave","Cave"),
                terrain_row("castle","Castle"),
                terrain_row("village","Village"),
                terrain_row("hills","Hills"),
                terrain_row("mountains","Mountains")
			} 
end

function misc_status_grid() 
 	return T.grid { 
	 T.row { T.column { border= "all", border_size= 5, T.grid {  -- left grid
-- this causes errors	         	T.row { T.column { horizontal_alignment = "center" , horizontal_grow = true, T.image { id = "the_icon"}}},
	         	T.row { T.column { horizontal_alignment = "center" , horizontal_grow = false, T.image { id = "the_icon"}}},
	         	T.row { T.column { horizontal_grow = true, T.label { id = "the_unit_type", use_markup = true}}},
		 	T.row { T.column { T.grid {
			         	T.row { T.column { horizontal_grow = true, T.label { id = "the_unit_level", use_markup = true}}, T.column { horizontal_grow = true, T.label { id = "the_unit_alignment", use_markup = true}}},
			         	T.row { T.column { horizontal_grow = true, T.label { id = "the_unit_HP", use_markup = true}}, T.column { horizontal_grow = true, T.label { id = "the_first_trait", use_markup = true}}},
			         	T.row { T.column { horizontal_grow = true, T.label { id = "the_unit_XP", use_markup = true}}, T.column { horizontal_grow = true, T.label { id = "the_second_trait", use_markup = true}}},  
			         	T.row { T.column { horizontal_grow = true, T.label { id = "the_unit_WT", use_markup = true, tooltip = "Equipment Weight: lowers defense values (except for village and castle) and every ten points costs one movement point."}}, T.column { horizontal_grow = true, T.spacer { id = "WT_spacer"}}}
				}}}				
			  }},
                 T.column { resistances_grid()} -- right grid
               },
	  
	  }
end

function set_simple_grid_values(unit,self)
	local u_vars = wml.get_child(unit, "variables")
        local total_xp = u_vars.total_xp
--        total_xp = tonumber(total_xp)
	local unit_hp = unit.hitpoints
	unit_hp = unit_hp / unit.max_hitpoints
-- 20190803 -- seems there is some bad logic here, change the <= to >= ?
	local hp_color = "color ='#34db00'"
	if unit_hp < 0.2 then
	    hp_color = "color ='#c80000'"
	elseif unit_hp <= 0.2 and unit_hp < 0.6 then
	    hp_color = "color ='#ffc000'"
	elseif unit_hp <= 0.6 and unit_hp < 0.9 then
	    hp_color = "color ='#dedede'"
	end
	local unit_xp = unit.experience
	unit_xp = unit_xp / unit.max_experience
	local xp_color = "color ='#8855ff'"
	if unit_xp < 0.2 then
	    xp_color = "color ='#550088'"
	elseif unit_xp <= 0.2 and unit_xp < 0.6 then
	    xp_color = "color ='#5511aa'"
	elseif unit_xp <= 0.6 and unit_xp < 0.9 then
	    xp_color = "color ='#5533bb'"
	end
    local widget_handle = self:find('the_unit_type')
    widget_handle.marked_up_text = string.format("<span size='large' color='#88dddd'> %s </span>", unit.type)
    widget_handle = self:find('the_unit_level')
    widget_handle.marked_up_text = string.format("<span size='small' color='#88dddd'> Level: %d </span>", unit.level)
    widget_handle = self:find('the_unit_alignment')
    widget_handle.marked_up_text = string.format("<span size='small' color='#88dddd'> %s </span>", unit.alignment)
    widget_handle = self:find('the_unit_HP')
    widget_handle.marked_up_text = string.format("<span size='small' "..hp_color.."> HP: %s / %s </span>", unit.hitpoints, unit.max_hitpoints)
    widget_handle = self:find('the_unit_XP')
    widget_handle.marked_up_text = string.format("<span size='small' "..xp_color.."> XP: %s / %s </span>", total_xp + unit.experience, total_xp + unit.max_experience)
    widget_handle = self:find('the_image')
    widget_handle.marked_up_text = string.format("portraits/status_pane.webp~SCALE(220,220)~BLIT(%s~SCALE(220,220))~BLIT(portraits/status_pane_top.webp~SCALE(220,220))", unit.profile)
    widget_handle = self:find('the_icon')
    widget_handle.label = unit.image
end

function set_child_grid_values(unit, self)
-- traits - hard coded for two, and using male_name with name as fallback.  This can be improved
	local traits_strings = {}
	local u_mods = wml.get_child(unit, "modifications")
	local c_i = 1
	for trait in wml.child_range( u_mods, "trait") do
	    traits_strings[c_i] = trait.male_name
	    if traits_strings[c_i] then
            else
                traits_strings[c_i] = trait.name
            end
	    c_i = c_i + 1
	end
	if traits_strings[2] then
	   else
	   traits_strings[2] = "."
	end
       widget_handle = self:find('the_first_trait')
       widget_handle.marked_up_text = string.format("<span size='small' color='#889999'> %s </span>", traits_strings[1])
       widget_handle = self:find('the_second_trait')
       widget_handle.marked_up_text = string.format("<span size='small' color='#889999'> %s </span>", traits_strings[2])
    -- weight
	local unit_var = wml.get_child(unit, "variables")
	local unit_wt = unit_var.weight
        if unit_wt then
        else
           unit_wt = 0
        end
	local wt_color = "color ='#2ac600'"
	if unit_wt > -10 and unit_wt < 10 then
	    wt_color = "color ='#e5e5e5'"
	elseif unit_wt >= 10 and unit_wt < 20 then
	    wt_color = "color ='#ffc600'"
	elseif unit_wt >= 20 and unit_wt < 30 then
	    wt_color = "color ='#ff0000'"
	end
        widget_handle = self:find('the_unit_WT')
        widget_handle.marked_up_text = string.format("<span size='small' "..wt_color.."> Equ.Wt.: %s </span>", unit_wt)
-- movement costs
        widget_handle = self:find('the_mcg_title')
        widget_handle.marked_up_text = "<span color='#eeffb7'>  Movement Costs  </span>"
	local costs = wml.get_child(unit, "movement_costs")
	local function mcg_format_row(value,widget)
            value = tonumber(value)
	    if value == nil then value = 99 end
	    local val_color = "color ='#ffc000'"
	    if value == 1 then
	        val_color = "color = '#dedede'"
	    elseif value > 3 and value < 6 then
	        val_color = "color = '#e56111'"
	    elseif value >= 6 then
	        val_color = "color ='#c80000' style ='italic'"
	    end
            widget_handle = self:find(widget)
            widget_handle.marked_up_text = string.format("<span "..val_color.." size = 'small'>%d </span>", value)
            return
	end
	mcg_format_row(costs.forest,"the_mcg_forest")
	mcg_format_row(costs.fungus,"the_mcg_fungus")
	mcg_format_row(costs.sand,"the_mcg_sand")
	mcg_format_row(costs.frozen,"the_mcg_frozen")
	mcg_format_row(costs.flat,"the_mcg_flat")
	mcg_format_row(costs.cave,"the_mcg_cave")
	mcg_format_row(costs.castle,"the_mcg_castle")
	mcg_format_row(costs.village,"the_mcg_village")
	mcg_format_row(costs.hills,"the_mcg_hills")
	mcg_format_row(costs.mountains,"the_mcg_mountains")
	mcg_format_row(costs.swamp_water,"the_mcg_swamp_water")
	mcg_format_row(costs.shallow_water,"the_mcg_shallow_water")
	mcg_format_row(costs.deep_water,"the_mcg_deep_water")
	mcg_format_row(costs.reef,"the_mcg_reef")
-- defense
        widget_handle = self:find('the_dg_title')
        widget_handle.marked_up_text = "<span color='#eeffb7'>  Terrain Defense  </span>"
	local defense = wml.get_child(unit, "defense")
	local function dg_format_row(string)
            local value = defense[string]
            value = tonumber(value)
            if value == nil or value > 100 then value = 100 end
	    value = 100 - value
	    local val_color = "color ='#ffc000'"
	    if value >= 70 then
	    	val_color = "color ='#34db00'"
	    elseif value < 70 and value >= 50 then
	        val_color = "color = '#dedede'"
	    elseif value <= 30 and value > 10 then
	        val_color = "color = '#e56111'"
	    elseif value <= 10 then
	        val_color = "color ='#c80000' style ='italic'"
	    end
            local widget = "the_dg_"..string
            widget_handle = self:find(widget)
            widget_handle.marked_up_text = string.format("<span "..val_color.." size = 'small'>%d </span>", value)
            return
        end
	dg_format_row("reef")
	dg_format_row("forest")
	dg_format_row("fungus")
	dg_format_row("sand")
	dg_format_row("frozen")
	dg_format_row("flat")
	dg_format_row("swamp_water")
	dg_format_row("shallow_water")
	dg_format_row("deep_water")
	dg_format_row("hills")
	dg_format_row("mountains")
	dg_format_row("cave")
	dg_format_row("castle")
	dg_format_row("village")
-- resistances
        widget_handle = self:find('the_rg_title')
        widget_handle.marked_up_text = "<span size='large' color='#eeffb7' underline='single' >  Resistances  </span>"
        local resistance = wml.get_child(unit, "resistance")
	local f_r = 100 - resistance.fire
	local c_r = 100 - resistance.cold
	local a_r = 100 - resistance.arcane
	local b_r = 100 - resistance.blade
	local i_r = 100 - resistance.impact
	local p_r = 100 - resistance.pierce
	local function rg_format_row(value,widget,widget2)
            local placeholder = 0
            value = tonumber(value)
            if value == nil or value > 100 then value = 100 end -- sets bad values to zero
	    local val_color = "color ='#ffc000'"
	    if value >= 40 then
	    	val_color = "color ='#34db00'"
	    elseif value < 40 and value >= 10 then
	        val_color = "color = '#dedede'"
	    elseif value <= -10 and value > -40 then
	        val_color = "color = '#e56111'"
	    elseif value <= -40 then
	        val_color = "color ='#c80000' style ='italic'"
	    end
            widget_handle = self:find(widget)
            widget_handle.marked_up_text = string.format("<span "..val_color.." size='small'> %d </span>", value)
            widget_handle = self:find(widget2)
            widget_handle.marked_up_text = string.format("<span color='#00aaff' size='x-small'> (%d)</span>", placeholder)
            return
        end
	rg_format_row(a_r,"the_rg_arcane","the_rg_bonus_arcane")
	rg_format_row(b_r,"the_rg_blade","the_rg_bonus_blade")
	rg_format_row(c_r,"the_rg_cold","the_rg_bonus_cold")
	rg_format_row(f_r,"the_rg_fire","the_rg_bonus_fire")
	rg_format_row(i_r,"the_rg_impact","the_rg_bonus_impact")
	rg_format_row(p_r,"the_rg_pierce","the_rg_bonus_pierce")


end
