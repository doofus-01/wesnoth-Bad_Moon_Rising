
-----------------------------------------------
-- WML tags for items/gear
------------------------------------------------

-- adds gear with gear_id to unit with id
-- if unit and gear were on map, it removes the gear
--[[

[apply_gear]
  id=
  gear_id=
  show_text= (optional)
[/apply_gear]

]]--

function wesnoth.custom_synced_commands.apply_gear(cfg)
        local unit_id = cfg.id or wml.error "[apply_gear] expects an id= attribute."
        local gear_id = cfg.gear_id or wml.error "[apply_gear] expects a gear_id= attribute."
        local result = bmr_equipment.unit(unit_id, gear_id)
        -- pass if the unit could equip the item, or was a player side that had a pool
        -- fail if the unit couldn't equip and was ai, or was not found
        if result == "pass" or result == "potion" then
--           wesnoth.message(string.format("%s on map", unit_id))
--           wesnoth.message(string.format("%s on map", gear_id))
            local eq_unit = wesnoth.units.find_on_map({ id = unit_id })
            -- this fails to store anything if id is something like "Primevalist Fighter-21", from underlying ID of generic unit, 
            -- then generates errors when eq_unit[1] is referenced
--           wesnoth.message(string.format("%s on map (array)", eq_unit[1].id))
--            local take_result = bmr_equipment.item_take(eq_unit[1].x, eq_unit[1].y, gear_id)
--            if take_result == "pass" then
            if eq_unit[1] then
              bmr_equipment.item_take(eq_unit[1].x, eq_unit[1].y, gear_id)
              if cfg.show_text == "yes" then 
                  wesnoth.interface.float_label(eq_unit[1].x, eq_unit[1].y, "<span color='#99aaaa'> Takes item...</span>")
              end
            end
            local eq_side = eq_unit[1].side
            -- this known_items variable is initialized in one of the INIT macros in utils/inventory.cfg
            local k_i = wml.variables["known_items["..eq_side.."].s"]
            if k_i == "dummy" or (not k_i) then
                wml.variables["known_items["..eq_side.."].s"] = string.format("%s", gear_id)
            else
                if not string.find(k_i,gear_id) then
                    wml.variables["known_items["..eq_side.."].s"] = string.format("%s,", k_i)..string.format("%s", gear_id)
                end
            end
        end
end

function wesnoth.wml_actions.apply_gear(cfg)
    wesnoth.sync.invoke_command("apply_gear",cfg)
end

-- removes gear with gear_id from unit with id
--[[

[remove_gear]
  id=
  gear_id=
[/remove_gear]

]]--

function wesnoth.custom_synced_commands.remove_gear(cfg)
        local unit_id = cfg.id or wml.error "[remove_gear] expects an id= attribute."
        local gear_id = cfg.gear_id or wml.error "[remove_gear] expects a gear_id= attribute."
        local result = bmr_equipment.remove(unit_id, gear_id)
        if result == "on_map" then
          local eq_unit = wesnoth.units.find_on_map({ id = unit_id })
          bmr_equipment.item_drop(eq_unit[1].x, eq_unit[1].y, gear_id)
--          wesnoth.message(string.format("%s on map", unit_id))
        elseif result == "on_recall" then
          bmr_equipment.pool_add(gear_id)
--          wesnoth.message(string.format("%s on recall", unit_id))
        else
          wesnoth.message(string.format("%s does not have %s", unit_id, gear_id))
        end
end

function wesnoth.wml_actions.remove_gear(cfg)
    wesnoth.sync.invoke_command("remove_gear",cfg)
end


-- places gear on map, like [item] does for images
--[[

[gear_item]
  gear_id=
  x,y=
[/gear_item]

]]--

function wesnoth.custom_synced_commands.gear_item(cfg)
        local x_1 = cfg.x or wml.error "[gear_item] expects an x= attribute."
        local y_1 = cfg.y or wml.error "[gear_item] expects an y= attribute."
        local gear_id = cfg.gear_id or wml.error "[gear_item] expects a gear_id= attribute."
        bmr_equipment.item_drop(x_1, y_1, gear_id)
end

function wesnoth.wml_actions.gear_item(cfg)
    wesnoth.sync.invoke_command("gear_item",cfg)
end     
        
-- deletes gear on map, like [remove_item] does for images
--[[

[remove_gear_item]
  gear_id=
  x,y=
[/remove_gear_item]

]]--

function wesnoth.custom_synced_commands.remove_gear_item(cfg)
        local x_1 = cfg.x or wml.error "[remove_gear_item] expects an x= attribute."
        local y_1 = cfg.y or wml.error "[remove_gear_item] expects an y= attribute."
        local gear_id = cfg.gear_id or wml.error "[remove_gear_item] expects a gear_id= attribute."
        bmr_equipment.item_take(x_1, y_1, gear_id)
end

function wesnoth.wml_actions.remove_gear_item(cfg)
    wesnoth.sync.invoke_command("remove_gear_item",cfg)
end     
        
----------------------------------------
-- shopping tags, WIP
----------------------------------------

function wesnoth.custom_synced_commands.sell_gear_menu(cfg)
    local side_number = cfg.side or wml.error "[sell_gear_menu] expects a side= attribute." -- trying to get away from hardcoded side=1, but not fully implemented yet
    Trader_Menus.seller(side_number)
end

function wesnoth.wml_actions.sell_gear_menu(cfg)
    wesnoth.sync.invoke_command("sell_gear_menu",cfg)
end     

function wesnoth.custom_synced_commands.sell_gear_menu(cfg)
    local side_number = cfg.side or wml.error "[buy_gear_menu] expects a side= attribute." -- trying to get away from hardcoded side=1, but not fully implemented yet
    local list_id = cfg.list_id or wml.error "[buy_gear_menu] expects a list_id= attribute." 
    Trader_Menus.buyer(side_number,list_id)
end

function wesnoth.wml_actions.buy_gear_menu(cfg)
    wesnoth.sync.invoke_command("buy_gear_menu",cfg)
end     

------------------------------------------
--  Interface tags
------------------------------------------
-- moving this to Archaic_Era
--[[ WML tag for the pop-up dialog

-- local _ = wesnoth.textdomain "wesnoth-Bad_Moon_Rising"
-- need to figure out how to deal with translations on the "message"

function wesnoth.wml_actions.center_message(cfg)
	local message = tostring(cfg.message or "No message available")
	local title = tostring(cfg.title or "")
        local image = cfg.image
        if image == nil then image = "wesnoth-icon.png" end

	gui.show_popup(title,message,image)
end
]]
