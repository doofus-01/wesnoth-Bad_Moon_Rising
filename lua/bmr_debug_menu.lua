-- to help balance the dynamic difficulty grading; whether that's me or the player doing the balancing
    
bmr_debug_menu = {}
bmr_debug_menu.new = function()
        local self = {}      
        self.factor = 1         
	local i_progression = wml.variables["BMR_progression"]
	local i_resistance = wml.variables["aaa"]
	local i_HP = wml.variables["bbb"]
	local i_damage = wml.variables["ccc"]
	if (type(i_progression) ~= 'number') or (type(i_resistance) ~= 'number' or (type(i_HP) ~= 'number') or type(i_damage) ~= 'number') then
            std_print("BMR dynamic scaling not initialized, setting default values")
            i_progression = 1
            i_resistance = 0.3
            i_HP = 0.4
            i_damage = 0.4
        end
-- main dialog content
        local dialog = {
        	T.tooltip { id = "tooltip_large" },
        	T.helptip { id = "tooltip_large" },
-- these linked groups don't do anything, probably not using them correctly
		T.linked_group {
			id = "call_buttons",
			fixed_width = "true",
			fixed_height = "true"
			},
		T.linked_group {
			id = "icons",
			fixed_width = "true",
			fixed_height = "true"
			},
		maximum_height = 500,
		maximum_width = 680,
		T.grid { 
			 T.row { 
			    T.column { T.spacer{ id = "tl_spacer" }},
			    T.column { T.label { id = "the_title", label = "BMR Enemy Scaling Factors", definition = "title", tooltip = "Adjust how fast units strength scales" }},
			    T.column { T.spacer{ id = "tr_spacer" }}
				},                                                                                                                                                
			 T.row { 
			    T.column { T.spacer{ id = "tl_spacer2" }},
			    T.column { border = 'all', border_size = 5, T.grid { 
			        T.row { 
			            T.column { T.spacer{ id = "tl2_spacer" }},
			            T.column { T.label { id = "the_new_value_title", label = "New Value"}},
			            T.column { T.label { id = "the_current_value_title", label = "Current Value"}}
				       },                                                                                                                                                
			        T.row { 
			            T.column { T.label { id = "the_progression_title" }},
			            T.column { T.text_box { id = "the_progression_value" }},
			            T.column { T.label { id = "the_old_progression_value" }}
				       },                                                                                                                                                
			        T.row { 
			            T.column { T.label { id = "the_resistance_title"}},
			            T.column { T.text_box { id = "the_resistance_value" }},
			            T.column { T.label { id = "the_old_resistance_value" }}
				       },                                                                                                                                                
			        T.row { 
			            T.column { T.label { id = "the_HP_title"}},
			            T.column { T.text_box { id = "the_HP_value" }},
			            T.column { T.label { id = "the_old_HP_value" }}
				       },                                                                                                                                                
			        T.row { 
			            T.column { T.label { id = "the_damage_title"}},
			            T.column { T.text_box { id = "the_damage_value" }},
			            T.column { T.label { id = "the_old_damage_value" }}
			               }
			             }},
			    T.column { T.spacer{ id = "tr_spacer" }}
				},                                                                                                                                                
			 T.row { 
                            -- devdocs say it's wierd to use both id and return value, 
                            -- but since the id:return_values aren't list, I spell it out
			    T.column { T.button { id = "ok", label = _"OK", return_value = 1 }},
			    T.column { T.spacer{ id = "bc_spacer" }},
			    T.column { T.button { id = "cancel", label = _"Cancel", return_value = -3 }}
				}
			}
		}
		
    local function preshow(self)
--	uor = wesnoth.units.find_on_recall( { side = "1", {"filter_wml", {{"variables", { on_call = "yes"} } }}})
	    
        local widget_handle = self:find('the_new_value_title')
        widget_handle.use_markup = true
        widget_handle.label = string.format("<span weight='bold' color='#a8afbf'>New Value</span>")
        widget_handle = self:find('the_current_value_title')
        widget_handle.use_markup = true
        widget_handle.label = string.format("<span weight='bold' color='#a8afbf'>Current Value</span>")
        widget_handle = self:find('the_progression_title')
        widget_handle.use_markup = true
        widget_handle.label = string.format("<span size='small' color='#aaaaaa'>Progression Value (0 - 10): </span>")
        widget_handle = self:find('the_old_progression_value')
        widget_handle.use_markup = true
        widget_handle.label = string.format("<span size='small' color='#a2a2b2'> %.1f </span>", i_progression)
        -- this is missing in the API
            widget_handle = self:find('the_progression_value')
            widget_handle.use_markup = true
            widget_handle.text = i_progression
    
        widget_handle = self:find('the_resistance_title')
        widget_handle.use_markup = true
        widget_handle.label = string.format("<span size='small' color='#aaaaaa'>Resistance (0.0 - 1.0): </span>")
        widget_handle = self:find('the_old_resistance_value')
        widget_handle.use_markup = true
        widget_handle.label = string.format("<span size='small' color='#a2a2b2'> %.2f </span>", i_resistance)
            widget_handle = self:find('the_resistance_value')
            widget_handle.use_markup = true
            widget_handle.text = i_resistance

        widget_handle = self:find('the_HP_title')
        widget_handle.use_markup = true
        widget_handle.label = string.format("<span size='small' color='#aaaaaa'>Hitpoints (0.0 - 1.0): </span>")
        widget_handle = self:find('the_old_HP_value')
        widget_handle.use_markup = true
        widget_handle.label = string.format("<span size='small' color='#a2a2b2'> %.2f </span>", i_HP)
            widget_handle = self:find('the_HP_value')
            widget_handle.use_markup = true
            widget_handle.text = i_HP

        widget_handle = self:find('the_damage_title')
        widget_handle.use_markup = true
        widget_handle.label = string.format("<span size='small' color='#aaaaa0'>Damage (0.0 - 1.0): </span>")
        widget_handle = self:find('the_old_damage_value')
        widget_handle.use_markup = true
        widget_handle.label = string.format("<span size='small' color='#a2a2b2'> %.2f </span>", i_damage)
            widget_handle = self:find('the_damage_value')
            widget_handle.use_markup = true
            widget_handle.text = i_damage
    end

    local function clean_value(val, limit, alt_val)
        local new_val = val
        new_val = tonumber(new_val)
        -- not sure how 'fail' is handled in lua 5.4, it's not listed as a special keyword...
        if (new_val == 'fail') or (not new_val) then
           -- std_print("Invalid value, restoring old value")
           new_val = alt_val
        end
        if new_val < 0.01 then new_val = 0.01 end
        if new_val > limit then new_val = limit end
        return new_val
    end
    
    local bv_progression = 0
    local bv_resistance = 0
    local bv_HP = 0
    local bv_damage = 0
-- read the text_box and button values ...  
    local function postshow(self)        
        widget_handle = self:find('the_progression_value')
        bv_progression = clean_value(widget_handle.text, 10, i_progression)

        widget_handle = self:find('the_resistance_value')
        bv_resistance = clean_value(widget_handle.text, 1, i_resistance)

        widget_handle = self:find('the_HP_value')
        bv_HP = clean_value(widget_handle.text, 1, i_HP)

        widget_handle = self:find('the_damage_value')
        bv_damage = clean_value(widget_handle.text, 1, i_damage)
    end

-- Assign values if OK selected (1) or return key hit (-1), don't do anything if cancel was selected or escape key hit    
--[[ then assign to persistent variables
   [set_global_variable]
     namespace=my_addon
     from_local=foo
     to_global=my_variable_name
     side=1
     immediate=no
   [/set_global_variable]
]]
    local rv = gui.show_dialog(dialog, preshow, postshow)
    if rv == 1 or rv == -1 then
        wml.variables['BMR_progression'] = bv_progression
        wml.fire("set_global_variable", { namespace = 'Bad_Moon_Rising', from_local = 'BMR_progression', to_global = 'XPS_BMR_progression', immediate = 'yes'})
        wml.variables['aaa'] = bv_resistance
        wml.fire("set_global_variable", { namespace = 'Bad_Moon_Rising', from_local = 'aaa', to_global = 'XPS_aaa', immediate= 'yes'})
        wml.variables['bbb'] = bv_HP
        wml.fire("set_global_variable", { namespace = 'Bad_Moon_Rising', from_local = 'bbb', to_global = 'XPS_bbb', immediate= 'yes'})
        wml.variables['ccc'] = bv_damage
        wml.fire("set_global_variable", { namespace = 'Bad_Moon_Rising', from_local = 'ccc', to_global = 'XPS_ccc', immediate= 'yes'})
    end
                                                                                                       
return bmr_debug_menu
end                                                                                                
