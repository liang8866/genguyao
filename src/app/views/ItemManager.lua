
local ItemManager = {}

function ItemManager:getItemNum(itemID)
    return UserData.Bag.items[itemID] ~= nil and UserData.Bag.items[itemID] or 0
end

return ItemManager