Inventory = {}
Inventory.Type = nil

if GetResourceState('ox_inventory') == 'started' then
    Inventory.Type = "ox"

    function Inventory.AddItem(src, item, amount)
        return exports.ox_inventory:AddItem(src, item, amount)
    end

elseif GetResourceState('qb-inventory') == 'started' or GetResourceState('ps-inventory') == 'started' then
    Inventory.Type = "qb"

    function Inventory.AddItem(src, item, amount)
        if Framework.Type == "qb" or Framework.Type == "qbox" then
            local Player = Framework.Object.Functions.GetPlayer(src)
            if Player then
                return Player.Functions.AddItem(item, amount)
            end
        elseif Framework.Type == "esx" then
            local xPlayer = Framework.Object.GetPlayerFromId(src)
            if xPlayer then
                xPlayer.addInventoryItem(item, amount)
            end
        end
    end
end
