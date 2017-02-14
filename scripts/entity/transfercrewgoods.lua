package.path = package.path .. ";data/scripts/lib/?.lua"

require("utility")
require("stringutility")

local playerTotalCrewBar;
local selfTotalCrewBar;

local playerCrewBars = {}
local playerCrewButtons = {}
local selfCrewBars = {}
local selfCrewButtons = {}

local playerTotalCargoBar;
local selfTotalCargoBar;

local playerCargoBars = {}
local playerCargoButtons = {}
local selfCargoBars = {}
local selfCargoButtons = {}


local playerTotalFighterBar;
local selfTotalFighterBar;


local crewmenByButton = {}
local cargosByButton = {}


-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function interactionPossible(playerIndex, option)

    local player = Player()
    local ship = Entity()
    local other = player.craft

    if ship.index == other.index then
        return false
    end

    -- interaction with drones does not work
    if ship.isDrone or other.isDrone then
        return false
    end

    if Faction().index ~= playerIndex then
        return false
    end

    return true, ""
end

--function initialize()
--
--end

-- create all required UI elements for the client side
function initUI()

    local res = getResolution();
    local size = vec2(700, 600)

    local menu = ScriptUI()
    local window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5));
    menu:registerWindow(window, "Transfer Crew/Cargo/Fighters"%_t);

    window.caption = "Transfer Crew, Cargo and Fighters"%_t
    window.showCloseButton = 1
    window.moveable = 1

    tabbedWindow = window:createTabbedWindow(Rect(vec2(10, 10), size - 10))
    local crewTab = tabbedWindow:createTab("Crew"%_t, "data/textures/icons/backup.png", "Exchange crew"%_t)

    local vSplit = UIVerticalSplitter(Rect(crewTab.size), 10, 0, 0.5)

--    crewTab:createFrame(vSplit.left);
--    crewTab:createFrame(vSplit.right);

    -- have to use "left" twice here since the coordinates are relative and the UI would be displaced to the right otherwise
    local leftLister = UIVerticalLister(vSplit.left, 10, 10)
    local rightLister = UIVerticalLister(vSplit.left, 10, 10)

    leftLister.marginRight = 30
    rightLister.marginRight = 30

    local leftFrame = crewTab:createScrollFrame(vSplit.left)
    local rightFrame = crewTab:createScrollFrame(vSplit.right)

    playerTotalCrewBar = leftFrame:createNumbersBar(Rect())
    leftLister:placeElementCenter(playerTotalCrewBar)

    selfTotalCrewBar = rightFrame:createNumbersBar(Rect())
    rightLister:placeElementCenter(selfTotalCrewBar)

    for i = 1, CrewProfessionType.Number * 4 do

        local rect = leftLister:placeCenter(vec2(leftLister.inner.width, 25))
        local vsplit = UIVerticalSplitter(rect, 7, 0, 0.80)
        local vsplit2 = UIVerticalSplitter(vsplit.right, 3, 0, 0.5)

        local button = leftFrame:createButton(vsplit2.right, ">", "onPlayerTransferCrewPressed")
        local button2 = leftFrame:createButton(vsplit2.left, ">>", "onPlayerTransferCrewPressedx")
        local bar = leftFrame:createStatisticsBar(vsplit.left, ColorRGB(1, 1, 1))
        button.textSize = 12
        button2.textSize = 12

        table.insert(playerCrewButtons, button)
        table.insert(playerCrewButtons, button2)
        table.insert(playerCrewBars, bar)
        crewmenByButton[button.index] = i
        crewmenByButton[button2.index] = i


        local rect = rightLister:placeCenter(vec2(rightLister.inner.width, 25))
        local vsplit = UIVerticalSplitter(rect, 10, 0, 0.20)
        local vsplit2 = UIVerticalSplitter(vsplit.left, 3, 0, 0.5)

        local button = rightFrame:createButton(vsplit2.left, "<", "onSelfTransferCrewPressed")
        local button2 = rightFrame:createButton(vsplit2.right, "<<", "onSelfTransferCrewPressedx")
        local bar = rightFrame:createStatisticsBar(vsplit.right, ColorRGB(1, 1, 1))
        button.textSize = 12
        button2.textSize = 12


        table.insert(selfCrewButtons, button)
        table.insert(selfCrewButtons, button2)
        table.insert(selfCrewBars, bar)
        crewmenByButton[button.index] = i
        crewmenByButton[button2.index] = i

    end

    local cargoTab = tabbedWindow:createTab("Cargo"%_t, "data/textures/icons/trade.png", "Exchange cargo"%_t)

--    cargoTab:createFrame(vSplit.left);
--    cargoTab:createFrame(vSplit.right);


    local leftLister = UIVerticalLister(vSplit.left, 10, 10)
    local rightLister = UIVerticalLister(vSplit.left, 10, 10)

    leftLister.marginRight = 30
    rightLister.marginRight = 30

    local leftFrame = cargoTab:createScrollFrame(vSplit.left)
    local rightFrame = cargoTab:createScrollFrame(vSplit.right)

    playerTotalCargoBar = leftFrame:createNumbersBar(Rect())
    leftLister:placeElementCenter(playerTotalCargoBar)

    selfTotalCargoBar = rightFrame:createNumbersBar(Rect())
    rightLister:placeElementCenter(selfTotalCargoBar)

    for i = 1, 20 do

        local rect = leftLister:placeCenter(vec2(leftLister.inner.width, 25))
        local vsplit = UIVerticalSplitter(rect, 10, 0, 0.80)
        local vsplit2 = UIVerticalSplitter(vsplit.right, 3, 0, 0.5)


        local button = leftFrame:createButton(vsplit2.right, ">", "onPlayerTransferCargoPressed")
        local button2 = leftFrame:createButton(vsplit2.left, ">>", "onPlayerTransferCargoPressedx")
        local bar = leftFrame:createStatisticsBar(vsplit.left, ColorInt(0xa0a0a0))
        button.textSize = 12
        button2.textSize = 12

        table.insert(playerCargoButtons, button)
        table.insert(playerCargoButtons, button2)
        table.insert(playerCargoBars, bar)
        cargosByButton[button.index] = i
        cargosByButton[button2.index] = i


        local rect = rightLister:placeCenter(vec2(rightLister.inner.width, 25))
        local vsplit = UIVerticalSplitter(rect, 10, 0, 0.20)
        local vsplit2 = UIVerticalSplitter(vsplit.left, 3, 0, 0.5)


        local button = rightFrame:createButton(vsplit2.left, "<", "onSelfTransferCargoPressed")
        local button2 = rightFrame:createButton(vsplit2.right, "<<", "onSelfTransferCargoPressedx")
        local bar = rightFrame:createStatisticsBar(vsplit.right, ColorInt(0xa0a0a0))
        button.textSize = 12
        button2.textSize = 12

        table.insert(selfCargoButtons, button)
        table.insert(selfCargoButtons, button2)
        table.insert(selfCargoBars, bar)
        cargosByButton[button.index] = i
        cargosByButton[button2.index] = i

    end

    local fightersTab = tabbedWindow:createTab("Fighters"%_t, "data/textures/icons/fighter.png", "Exchange fighters"%_t)
    
    
    
    local leftLister = UIVerticalLister(vSplit.left, 10, 10)
    local rightLister = UIVerticalLister(vSplit.left, 10, 10)

    leftLister.marginRight = 30
    rightLister.marginRight = 30

    local leftFrame = fightersTab:createScrollFrame(vSplit.left)
    local rightFrame = fightersTab:createScrollFrame(vSplit.right)
    
    playerTotalFightersBar = leftFrame:createNumbersBar(Rect())
    leftLister:placeElementCenter(playerTotalFightersBar)

    selfTotalFightersBar = rightFrame:createNumbersBar(Rect())
    rightLister:placeElementCenter(selfTotalFightersBar)
    
    for i = 1, 12 do
        local rect = leftLister:placeCenter(vec2(leftLister.inner.width, 50))
        local sel = leftFrame:createSelection(rect, 6)
        sel.padding = 2
        sel.dropIntoEnabled = 1
        sel.entriesSelectable = 0



        local rect = rightLister:placeCenter(vec2(rightLister.inner.width, 50))
        local sel = rightFrame:createSelection(rect, 6)
        sel.padding = 2
        sel.dropIntoEnabled = 1
        sel.entriesSelectable = 0
    end
end


function getSortedCrewmen(entity)

    function compareCrewmen(pa, pb)
        local a = pa.crewman
        local b = pb.crewman

        if a.profession.value == b.profession.value then
            if a.specialist == b.specialist then
                return a.level < b.level
            else
                return (a.specialist and 1 or 0) < (b.specialist and 1 or 0)
            end
        else
            return a.profession.value < b.profession.value
        end
    end

    local crew = entity.crew

    local sortedMembers = {}
    for crewman, num in pairs(crew:getMembers()) do
        table.insert(sortedMembers, {crewman = crewman, num = num})
    end

    table.sort(sortedMembers, compareCrewmen)

    return sortedMembers
end

function updateData()
    local playerShip = Player().craft
    local ship = Entity()

    -- update crew info
    playerTotalCrewBar:clear()
    selfTotalCrewBar:clear()

    playerTotalCrewBar:setRange(0, playerShip.maxCrewSize)
    selfTotalCrewBar:setRange(0, ship.maxCrewSize)

    for _, bar in pairs(playerCrewBars) do bar.visible = false end
    for _, bar in pairs(selfCrewBars) do bar.visible = false end
    for _, bar in pairs(playerCargoBars) do bar.visible = false end
    for _, bar in pairs(selfCargoBars) do bar.visible = false end
    for _, button in pairs(playerCrewButtons) do button.visible = false end
    for _, button in pairs(selfCrewButtons) do button.visible = false end
    for _, button in pairs(playerCargoButtons) do button.visible = false end
    for _, button in pairs(selfCargoButtons) do button.visible = false end

    local i = 1
    for _, p in pairs(getSortedCrewmen(playerShip)) do

        local crewman = p.crewman
        local num = p.num

        local caption = num .. " " .. crewman.profession.name

        playerTotalCrewBar:addEntry(num, caption, crewman.profession.color)

        local singleBar = playerCrewBars[i]
        singleBar.visible = true
        singleBar:setRange(0, playerShip.maxCrewSize)
        singleBar.value = num
        singleBar.name = caption
        singleBar.color = crewman.profession.color

        local button = playerCrewButtons[i*2-1]
        button.visible = true
        local button = playerCrewButtons[i*2]
        button.visible = true
        i = i + 1
    end

    local i = 1
    for _, p in pairs(getSortedCrewmen(Entity())) do

        local crewman = p.crewman
        local num = p.num

        local caption = num .. " " .. crewman.profession.name

        selfTotalCrewBar:addEntry(num, caption, crewman.profession.color)

        local singleBar = selfCrewBars[i]
        singleBar.visible = true
        singleBar:setRange(0, ship.maxCrewSize)
        singleBar.value = num
        singleBar.name = caption
        singleBar.color = crewman.profession.color

        local button = selfCrewButtons[i*2-1]
        button.visible = true
        local button = selfCrewButtons[i*2]
        button.visible = true
        i = i + 1
    end




    -- update cargo info
    playerTotalCargoBar:clear()
    selfTotalCargoBar:clear()

    playerTotalCargoBar:setRange(0, playerShip.maxCargoSpace)
    selfTotalCargoBar:setRange(0, ship.maxCargoSpace)

    for i, v in pairs(playerCargoBars) do

        local bar = playerCargoBars[i]
        local button = playerCargoButtons[i*2-1]
        local button2 = playerCargoButtons[i*2]

        if i > playerShip.numCargos then
            bar:hide();
            button:hide();
            button2:hide();
        else
            bar:show();
            button:show();
            button2:show();

            local good, amount = playerShip:getCargo(i - 1)
            local maxSpace = playerShip.maxCargoSpace
            bar:setRange(0, maxSpace)
            bar.value = amount * good.size

            if amount > 1 then
                bar.name = amount .. " " .. good.plural
                playerTotalCargoBar:addEntry(amount * good.size, amount .. " " .. good.plural, ColorInt(0xffa0a0a0))
            else
                bar.name = amount .. " " .. good.name
                playerTotalCargoBar:addEntry(amount * good.size, amount .. " " .. good.name, ColorInt(0xffa0a0a0))
            end
        end

        local bar = selfCargoBars[i]
        local button = selfCargoButtons[i*2-1]
        local button2 = selfCargoButtons[i*2]

        if i > ship.numCargos then
            bar:hide();
            button:hide();
            button2:hide();
        else
            bar:show();
            button:show();
            button2:show();

            local good, amount = ship:getCargo(i - 1)
            local maxSpace = ship.maxCargoSpace
            bar:setRange(0, maxSpace)
            bar.value = amount * good.size

            if amount > 1 then
                bar.name = amount .. " " .. good.plural
                selfTotalCargoBar:addEntry(amount * good.size, amount .. " " .. good.plural, ColorInt(0xffa0a0a0))
            else
                bar.name = amount .. " " .. good.name
                selfTotalCargoBar:addEntry(amount * good.size, amount .. " " .. good.name, ColorInt(0xffa0a0a0))
            end
        end
    end

end

function onPlayerTransferCrewPressed(button)
    -- transfer crew from player ship to self

    -- check which crew member type
    local crewmanIndex = crewmenByButton[button.index]
    if not crewmanIndex then return end

    invokeServerFunction("transferCrew", crewmanIndex, Player().craftIndex, false)
end

function onSelfTransferCrewPressed(button)
    -- transfer crew from self ship to player ship

    -- check which crew member type
    local crewmanIndex = crewmenByButton[button.index]
    if not crewmanIndex then return end

    invokeServerFunction("transferCrew", crewmanIndex, Player().craftIndex, true)
end

function onPlayerTransferCrewPressedx(button)
    -- transfer crew from player ship to self

    -- check which crew member type
    local crewmanIndex = crewmenByButton[button.index]
    if not crewmanIndex then return end

    for i = 1, 10 do
      invokeServerFunction("transferCrew", crewmanIndex, Player().craftIndex, false)
    end
end

function onSelfTransferCrewPressedx(button)
    -- transfer crew from self ship to player ship

    -- check which crew member type
    local crewmanIndex = crewmenByButton[button.index]
    if not crewmanIndex then return end

    for i = 1, 10 do
      invokeServerFunction("transferCrew", crewmanIndex, Player().craftIndex, true)
    end
end

function transferCrew(crewmanIndex, otherIndex, selfToOther)
    local sender
    local receiver

    if selfToOther then
        sender = Entity()
        receiver = Entity(otherIndex)
    else
        sender = Entity(otherIndex)
        receiver = Entity()
    end

    if sender.factionIndex ~= callingPlayer then
        local player = Player(callingPlayer)
        if player then
            player:sendChatMessage("Server"%_t, 1, "You don't own this craft."%_t)
        end
        return
    end

    -- check distance
    if sender:getNearestDistance(receiver) > 20 then
        Player(callingPlayer):sendChatMessage("Server"%_t, 1, "You're too far away."%_t)
        return
    end

    local sorted = getSortedCrewmen(sender)

    local p = sorted[crewmanIndex]
    if not p then
        print("bad crewman")
        return
    end

    local crewman = p.crewman

    -- make sure sending ship has a member of this type
    if sender.crew:getNumMembers(crewman) == 0 then
        print("no crew of this type")
        return
    end

    -- transfer
    sender:removeCrew(1, crewman)
    receiver:addCrew(1, crewman)

    invokeClientFunction(Player(callingPlayer), "updateData")
end

function onPlayerTransferCargoPressed(button)
    -- transfer cargo from player ship to self

    -- check which cargo
    local cargo = cargosByButton[button.index]
    if cargo == nil then return end

    invokeServerFunction("transferCargo", cargo - 1, Player().craftIndex, false)
end

function onSelfTransferCargoPressed(button)
    -- transfer cargo from self to player ship

    -- check which cargo
    local cargo = cargosByButton[button.index]
    if cargo == nil then return end

    invokeServerFunction("transferCargo", cargo - 1, Player().craftIndex, true)
end

function onPlayerTransferCargoPressedx(button)
    -- transfer cargo from player ship to self

    -- check which cargo
    local cargo = cargosByButton[button.index]
    if cargo == nil then return end

    for i = 1, 10 do
      invokeServerFunction("transferCargo", cargo - 1, Player().craftIndex, false)
    end
end

function onSelfTransferCargoPressedx(button)
    -- transfer cargo from self to player ship

    -- check which cargo
    local cargo = cargosByButton[button.index]
    if cargo == nil then return end

    for i = 1, 10 do
      invokeServerFunction("transferCargo", cargo - 1, Player().craftIndex, true)
    end
end


function transferCargo(cargoIndex, otherIndex, selfToOther)
    local sender
    local receiver

    if selfToOther then
        sender = Entity()
        receiver = Entity(otherIndex)
    else
        sender = Entity(otherIndex)
        receiver = Entity()
    end

    if sender.factionIndex ~= callingPlayer then
        local player = Player(callingPlayer)
        if player then
            player:sendChatMessage("Server"%_t, 1, "You don't own this craft."%_t)
        end
        return
    end

    -- check distance
    if sender:getNearestDistance(receiver) > 2 then
        Player(callingPlayer):sendChatMessage("Server"%_t, 1, "You're too far away."%_t)
        return
    end

    -- get the cargo
    local good, amount = sender:getCargo(cargoIndex)

    -- make sure sending ship has the cargo
    if amount == nil then return end
    if amount == 0 then return end

    -- make sure receiving ship has enough space
    if receiver.freeCargoSpace < good.size then
        Player(callingPlayer):sendChatMessage("Server"%_t, 1, "Not enough space on the other craft."%_t)
        return
    end

    -- transfer
    sender:removeCargo(good, 1)
    receiver:addCargo(good, 1)

    invokeClientFunction(Player(callingPlayer), "updateData")
end

---- this function gets called every time the window is shown on the client, ie. when a player presses F
function onShowWindow()
    updateData()
end
--
---- this function gets called every time the window is shown on the client, ie. when a player presses F
--function onCloseWindow()
--
--end

-- this function will be executed every frame both on the server and the client
--function update(timeStep)
--end
--
---- this function will be executed every frame on the client only
--function updateClient(timeStep)
--end
--
---- this function will be executed every frame on the server only
--function updateServer(timeStep)
--end
--
---- this function will be executed every frame on the client only
---- use this for rendering additional elements to the target indicator of the object
--function renderUIIndicator(px, py, size)
--end
--
---- this function will be executed every frame on the client only
---- use this for rendering additional elements to the interaction menu of the target craft
--function renderUI()
--end

