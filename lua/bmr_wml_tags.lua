
-----------------------------------------------
-- WML tags for items/gear
------------------------------------------------

-- adds gear with gear_id to unit with id
-- if unit and gear were on map, it removes the gear
--[[

[apply_gear]
  id=
  gear_id=
[/apply_gear]

]]--

function wesnoth.wml_actions.apply_gear(cfg)
        local unit_id = cfg.id or helper.wml_error "[apply_gear] expects an id= attribute."
        local gear_id = cfg.gear_id or helper.wml_error "[apply_gear] expects a gear_id= attribute."
        local result = bmr_equipment.unit(unit_id, gear_id)
        -- pass if the unit could equip the item, or was a player side that had a pool
        -- fail if the unit couldn't equip and was ai, or was not found
        if result == "pass" then
            local eq_unit = wesnoth.get_units({ id = unit_id })
            bmr_equipment.item_take(eq_unit[1].x, eq_unit[1].y, gear_id)
        end
end


-- removes gear with gear_id from unit with id
--[[

[remove_gear]
  id=
  gear_id=
[/remove_gear]

]]--

function wesnoth.wml_actions.remove_gear(cfg)
        local unit_id = cfg.id or helper.wml_error "[remove_gear] expects an id= attribute."
        local gear_id = cfg.gear_id or helper.wml_error "[remove_gear] expects a gear_id= attribute."
        if bmr_equipment.remove(unit_id, gear_id) == "on_map" then
          local eq_unit = wesnoth.get_units({ id = unit_id })
          bmr_equipment.item_drop(eq_unit[1].x, eq_unit[1].y, gear_id)
--          wesnoth.message(string.format("%s on map", unit_id))
        elseif bmr_equipment.remove(unit_id, gear_id) == "on_recall" then
          bmr_equipment.pool_add(gear_id)
--          wesnoth.message(string.format("%s on recall", unit_id))
        else
          wesnoth.message(string.format("%s does not have %s", unit_id, gear_id))
        end
end


-- places gear on map, like [item] does for images
--[[

[gear_item]
  gear_id=
  x,y=
[/gear_item]

]]--

function wesnoth.wml_actions.gear_item(cfg)
        local x_1 = cfg.x or helper.wml_error "[gear_item] expects an x= attribute."
        local y_1 = cfg.y or helper.wml_error "[gear_item] expects an y= attribute."
        local gear_id = cfg.gear_id or helper.wml_error "[gear_item] expects a gear_id= attribute."
        bmr_equipment.item_drop(x_1, y_1, gear_id)
end     
        
-- deletes gear on map, like [remove_item] does for images
--[[

[remove_gear_item]
  gear_id=
  x,y=
[/remove_gear_item]

]]--

function wesnoth.wml_actions.remove_gear_item(cfg)
        local x_1 = cfg.x or helper.wml_error "[remove_gear_item] expects an x= attribute."
        local y_1 = cfg.y or helper.wml_error "[remove_gear_item] expects an y= attribute."
        local gear_id = cfg.gear_id or helper.wml_error "[remove_gear_item] expects a gear_id= attribute."
        bmr_equipment.item_take(x_1, y_1, gear_id)
end     
        
----------------------------------------
-- shopping tags, WIP
----------------------------------------

function wesnoth.wml_actions.sell_gear_menu(cfg)
    local side_number = cfg.side or helper.wml_error "[sell_gear_menu] expects a side= attribute." -- trying to get away from hardcoded side=1, but not fully implemented yet
    Trader_Menus.seller(side_number)
end     

function wesnoth.wml_actions.buy_gear_menu(cfg)
    local side_number = cfg.side or helper.wml_error "[buy_gear_menu] expects a side= attribute." -- trying to get away from hardcoded side=1, but not fully implemented yet
    local list_id = cfg.list_id or helper.wml_error "[buy_gear_menu] expects a list_id= attribute." 
    Trader_Menus.buyer(side_number,list_id)
end     

------------------------------------------
--  Interface tags
------------------------------------------

-- WML tag for the pop-up dialog

-- local _ = wesnoth.textdomain "wesnoth-Bad_Moon_Rising"
-- need to figure out how to deal with translations on the "message"

function wesnoth.wml_actions.center_message(cfg)
	local message = tostring(cfg.message or "No message available")
	local title = tostring(cfg.title or "")
        local image = cfg.image
        if image == nil then image = "wesnoth-icon.png" end

	wesnoth.show_popup_dialog(title,message,image)
end



-- is this needed?  maybe it should be removed
--[[
-- simple GUI dialog, adapted from top_message.lua in After_the_Storm

-- Displays a simple transient message at the top, without any
-- captions or images.
--
-- [top_message]
--     message=(tstring)
-- [/top_message]
--
function wesnoth.wml_actions.top_message(cfg)
	local dd = {
		definition = "message",
		vertical_placement = "top",
                horizontal_placement = "center",
                                                                                                                                                                                                                                                               


                -- TODO: we can't use manual placement yet because then the
                -- width and height
                --       become static and the game fails if the text
                -- doesn't fit later.
                --
                -- automatic_placement = false,
                -- x = "(screen_width / 2)",
                -- the menu bar height (26 px) plus the standard margin size
                -- y = "(26 + 5)",
                -- width = 200, 
                -- height = 100,

                maximum_width = 800, 
                maximum_height = 600,

                click_dismiss = true,

                T.helptip { id="tooltip_large" },
                T.tooltip { id="tooltip_large" },

                T.grid {
                        T.row {
                                T.column {
                                        border = "all", border_size = 20,
                                        horizontal_alignment = "center",
                                        vertical_alignment = "center",
                                        T.label { id = "message", definition = "default" }
                                }
                        }
                }
        }

        local message = cfg.message
        if message == nil then message = "" end

        local function preshow()
                wesnoth.set_dialog_value(message, "message")
                wesnoth.set_dialog_markup(true, "message")
        end

        wesnoth.show_dialog(dd, preshow, nil)
end

function wesnoth.wml_actions.top_message_spacer(cfg)
	local function stack_my_widget() 
		return T.stacked_widget{
			T.stack{
			T.layer{
				T.row{
					T.column{
						T.spacer{
						width= 120,
						height= 120,
						id = "boxy_spacer"
						}
					}
				}
			},
			T.layer{
				T.row{
					grow_factor = 1,
					T.column{
                                        border = "all", border_size = 20,
                                        horizontal_alignment = "center",
                                        vertical_alignment = "center",
                                        T.label { id = "message", definition = "default" }
					}
				}
			}
			}
		}
	end
	local ddst = {
		definition = "message_stack",
		vertical_placement = "top",
                horizontal_placement = "center",
                                                                                                                                                                                                                                                               


                -- TODO: we can't use manual placement yet because then the
                -- width and height
                --       become static and the game fails if the text
                -- doesn't fit later.
                --
                -- automatic_placement = false,
                -- x = "(screen_width / 2)",
                -- the menu bar height (26 px) plus the standard margin size
                -- y = "(26 + 5)",
                -- width = 200, 
                -- height = 100,

                maximum_width = 800, 
                maximum_height = 600,

                click_dismiss = true,

                T.helptip { id="tooltip_large" },
                T.tooltip { id="tooltip_large" },

                T.grid {
                        T.row {
                                T.column { stack_my_widget()
                                }
                        }
                }
        }

        local message = cfg.message
        if message == nil then message = "" end

        local function preshow()
                wesnoth.set_dialog_value(message, "message")
                wesnoth.set_dialog_markup(true, "message")
        end

        wesnoth.show_dialog(ddst, preshow, nil)
end

]]
