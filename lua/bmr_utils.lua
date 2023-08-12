local on_event = wesnoth.require "on_event"

local bmr_utils = {}
if rawget(_G, "bmr_menu_filters") == nil then
        bmr_menu_filters = {}
end

function bmr_utils.menu_item(t)
        local id_nospace = string.gsub(t.id, " ", "_")
        local cfg = {}
        on_event("start", function()
                wesnoth.wml_actions.set_menu_item {
                        id = t.id,
                        description = t.description,
                        image = t.image,
                        synced = t.synced,
                        wml.tag.filter_location {
                                lua_function="bmr_menu_filters." .. id_nospace,
                        },
                }
        end)
        if t.handler then
                on_event("menu_item_" .. t.id, t.handler)
        end
        bmr_menu_filters[id_nospace] = t.filter
end

return bmr_utils
