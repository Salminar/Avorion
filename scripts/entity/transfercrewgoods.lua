package.path = package.path .. ";data/scripts/lib/?.lua"

require("utility")
require("stringutility")


local playerTotalCrewBar;
local selfTotalCrewBar;
local playerCrewUI = {}
local selfCrewUI = {}

local playerTotalCargoBar;
local selfTotalCargoBar;
local playerCargoUI = {}
local selfCargoUI = {}

local playerTotalFighterBar;
local selfTotalFighterBar;

local playerFighters = {}
local selfFighters = {}
local playerSquad = {}
local selfSquad = {}
local fightersTab = nil

local fightersByButton = {}
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
    local maxcargo = 30
    local res = getResolution();
    local size = vec2(700, 600)

    local menu = ScriptUI()
    local window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
    menu:registerWindow(window, "Transfer Crew/Cargo"%_t)

    window.caption = "Transfer Crew, Cargo and Fighters"%_t
    window.showCloseButton = 1
    window.moveable = 1

    tabbedWindow = window:createTabbedWindow(Rect(vec2(10, 10), size - 10))
    local crewTab = tabbedWindow:createTab("Crew"%_t, "data/textures/icons/backup.png", "Exchange crew"%_t)

    local vSplit = UIVerticalSplitter(Rect(crewTab.size), 10, 0, 0.5)

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
        local vsplit1 = UIVerticalSplitter(vsplit.left, 3, 0, 0.15)
        local vsplit2 = UIVerticalSplitter(vsplit.right, 3, 0, 0.5)

        local pbutton = leftFrame:createButton(vsplit2.right, ">", "onPlayerTransferCrewPressed")
        local pbutton2 = leftFrame:createButton(vsplit2.left, ">>", "onPlayerTransferCrewPressed")
        local pbar = leftFrame:createStatisticsBar(vsplit1.right, ColorRGB(1, 1, 1))
        local picon = leftFrame:createPicture(vsplit1.left,"data/textures/icons/backup.png")
        pbutton.textSize = 12
        pbutton2.textSize = 12
        picon.flipped = true -- else the icon is upside down
        picon.isIcon = true

        local rect = rightLister:placeCenter(vec2(rightLister.inner.width, 25))
        local vsplit = UIVerticalSplitter(rect, 7, 0, 0.20)
        local vsplit1 = UIVerticalSplitter(vsplit.right, 3, 0, 0.85)
        local vsplit2 = UIVerticalSplitter(vsplit.left, 3, 0, 0.5)

        local sbutton = rightFrame:createButton(vsplit2.left, "<", "onSelfTransferCrewPressed")
        local sbutton2 = rightFrame:createButton(vsplit2.right, "<<", "onSelfTransferCrewPressed")
        local sbar = rightFrame:createStatisticsBar(vsplit1.left, ColorRGB(1, 1, 1))
        local sicon = rightFrame:createPicture(vsplit1.right,"data/textures/icons/backup.png")
        sbutton.textSize = 12
        sbutton2.textSize = 12
        sicon.flipped = true -- else the icon is upside down
        sicon.isIcon = true
        table.insert(playerCrewUI, {pbutton=pbutton, pbutton2=pbutton2, pbar=pbar, picon=picon})
        table.insert(selfCrewUI, {sbutton=sbutton, sbutton2=sbutton2, sbar=sbar, sicon=sicon})
        crewmenByButton[pbutton.index] = i
        crewmenByButton[pbutton2.index] = i
        crewmenByButton[sbutton.index] = i
        crewmenByButton[sbutton2.index] = i
    end

    local cargoTab = tabbedWindow:createTab("Cargo"%_t, "data/textures/icons/trade.png", "Exchange cargo"%_t)

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

    for i = 1, maxcargo do
        local rect = leftLister:placeCenter(vec2(leftLister.inner.width, 25))
        local vsplit = UIVerticalSplitter(rect, 7, 0, 0.80)
        local vsplit1 = UIVerticalSplitter(vsplit.left, 3, 0, 0.15)
        local vsplit2 = UIVerticalSplitter(vsplit.right, 3, 0, 0.5)

        local pbutton = leftFrame:createButton(vsplit2.right, ">", "onPlayerTransferCargoPressed")
        local pbutton2 = leftFrame:createButton(vsplit2.left, ">>", "onPlayerTransferCargoPressed")
        local pbar = leftFrame:createStatisticsBar(vsplit1.right, ColorInt(0xa0a0a0))
        local picon = leftFrame:createPicture(vsplit1.left,"data/textures/icons/trade.png")
        pbutton.textSize = 12
        pbutton2.textSize = 12
        picon.flipped = true -- else the icon is upside down
        picon.isIcon = true


        local rect = rightLister:placeCenter(vec2(rightLister.inner.width, 25))
        local vsplit = UIVerticalSplitter(rect, 10, 0, 0.20)
        local vsplit1 = UIVerticalSplitter(vsplit.right, 3, 0, 0.85)
        local vsplit2 = UIVerticalSplitter(vsplit.left, 3, 0, 0.5)

        local sbutton = rightFrame:createButton(vsplit2.left, "<", "onSelfTransferCargoPressed")
        local sbutton2 = rightFrame:createButton(vsplit2.right, "<<", "onSelfTransferCargoPressed")
        local sbar = rightFrame:createStatisticsBar(vsplit.right, ColorInt(0xa0a0a0))
        local sicon = rightFrame:createPicture(vsplit1.right,"data/textures/icons/trade.png")
        sbutton.textSize = 12
        sbutton2.textSize = 12
        sicon.flipped = true -- else the icon is upside down
        sicon.isIcon = true

        table.insert(playerCargoUI, {pbutton=pbutton, pbutton2=pbutton2, pbar=pbar, picon=picon})
        table.insert(selfCargoUI, {sbutton=sbutton, sbutton2=sbutton2, sbar=sbar, sicon=sicon})
        cargosByButton[pbutton.index] = i
        cargosByButton[pbutton2.index] = i
        cargosByButton[sbutton.index] = i
        cargosByButton[sbutton2.index] = i
    end

    fightersTab = tabbedWindow:createTab("Fighters"%_t, "data/textures/icons/fighter.png", "Exchange fighters"%_t)

    vSplit = UIVerticalSplitter(Rect(fightersTab.size), 5, 0, 0.5)

    local leftLister = UIVerticalLister(vSplit.left, 5, 5)
    local rightLister = UIVerticalLister(vSplit.right, 5, 5)

    leftLister.marginRight = 5
    rightLister.marginRight = 5

--    local leftFrame = fightersTab:createScrollFrame(vSplit.left)
--    local rightFrame = fightersTab:createScrollFrame(vSplit.right)
    
    playerTotalFightersBar = fightersTab:createNumbersBar(Rect())
    leftLister:placeElementCenter(playerTotalFightersBar)

    selfTotalFightersBar = fightersTab:createNumbersBar(Rect())
    rightLister:placeElementCenter(selfTotalFightersBar)
    
    for i = 1, 7 do
      local rect = leftLister:placeCenter(vec2(leftLister.inner.width, 50))
      local hsplit = UIHorizontalSplitter(rect, 5, 0, 0.4)
      local label = fightersTab:createLabel(vec2(hsplit.top.lower.x+2,hsplit.top.lower.y+4), "Squad "..i, 12)
      local vsplit = UIVerticalMultiSplitter(hsplit.bottom, 2, 0, 11)
      for j = 0, 11 do
        local pic1 = fightersTab:createPicture(vsplit:partition(j),"data/textures/icons/fighter.png")
        local button = fightersTab:createButton(vsplit:partition(j),'',"onPlayerTFighter")
        pic1.flipped = true -- else the icon is upside down
        pic1.isIcon = true
        fightersByButton[button.index]={s=i-1, f=j}
        local toolt1
        table.insert(playerFighters, { pict=pic1, button=button, tooltip=toolt1})
      end

      local rect = rightLister:placeCenter(vec2(rightLister.inner.width,50))
      local hsplit = UIHorizontalSplitter(rect, 5, 0, 0.4)
      local label = fightersTab:createLabel(vec2(hsplit.top.lower.x+2,hsplit.top.lower.y+4), "Squad "..i, 12)
      local vsplit = UIVerticalMultiSplitter(hsplit.bottom, 2, 0, 11)
      for j = 0, 11 do
        local pic1 = fightersTab:createPicture(vsplit:partition(j),"data/textures/icons/fighter.png")
        local button = fightersTab:createButton(vsplit:partition(j),'',"onSelfTFighter")
        pic1.flipped = true -- else the icon is upside down
        pic1.isIcon = true
        fightersByButton[button.index]={s=i-1, f=j}
        local toolt1
        table.insert(selfFighters, { pict=pic1, button=button, tooltip=toolt1})
      end
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

    for _, pUI in pairs(playerCrewUI) do
      for _, element in pairs (pUI) do element.visible = false end
    end
    for _, sUI in pairs(selfCrewUI) do
      for _, element in pairs (sUI) do element.visible = false end
    end

    local i = 1
    for _, p in pairs(getSortedCrewmen(playerShip)) do

        local crewman = p.crewman
        local num = p.num

        local caption = num .. " " .. crewman.profession.name .. " lv " .. crewman.level

        playerTotalCrewBar:addEntry(num, caption, crewman.profession.color)

        local bar = playerCrewUI[i].pbar
        bar.visible = true
        bar:setRange(0, playerShip.maxCrewSize)
        bar.value = num
        bar.name = caption
        bar.color = crewman.profession.color

        local button = playerCrewUI[i].pbutton
        button.visible = true
        local button = playerCrewUI[i].pbutton2

        button.visible = true
        local icon = playerCrewUI[i].picon
        icon.picture = crewman.profession.icon
        icon.color = crewman.profession.color
        icon.visible = true
        i = i + 1
    end

    local i = 1
    for _, p in pairs(getSortedCrewmen(Entity())) do

        local crewman = p.crewman
        local num = p.num

        local caption = num .. " " .. crewman.profession.name .. " lv " .. crewman.level

        selfTotalCrewBar:addEntry(num, caption, crewman.profession.color)

        local bar = selfCrewUI[i].sbar
        bar.visible = true
        bar:setRange(0, ship.maxCrewSize)
        bar.value = num
        bar.name = caption
        bar.color = crewman.profession.color

        local button = selfCrewUI[i].sbutton
        button.visible = true
        local button = selfCrewUI[i].sbutton2
        button.visible = true
        local icon = selfCrewUI[i].sicon
        icon.picture = crewman.profession.icon
        icon.color = crewman.profession.color
        icon.visible = true
        i = i + 1
    end
--free space for both bars
    local pfs=playerShip.maxCrewSize-playerShip.crewSize
    local sfs=ship.maxCrewSize-ship.crewSize
    playerTotalCrewBar:addEntry(pfs, 'Free beds : '..pfs, ColorRGB(0.1, 0.1, 0.1))
    selfTotalCrewBar:addEntry(sfs, 'Free beds : '..sfs, ColorRGB(0.1, 0.1, 0.1))

    -- update cargo info
    playerTotalCargoBar:clear()
    selfTotalCargoBar:clear()

    playerTotalCargoBar:setRange(0, playerShip.maxCargoSpace)
    selfTotalCargoBar:setRange(0, ship.maxCargoSpace)

    for i, v in pairs(playerCargoUI) do

        local bar = playerCargoUI[i].pbar
        local button = playerCargoUI[i].pbutton
        local button2 = playerCargoUI[i].pbutton2
        local icon = playerCargoUI[i].picon
        if i > playerShip.numCargos then
            for _, element in pairs (playerCargoUI[i]) do element:hide() end
        else
            for _, element in pairs (playerCargoUI[i]) do element:show() end
            local good, amount = playerShip:getCargo(i - 1)
            local regular = ''
            local color = 0xffa0a0a0
            if good.stolen then
              regular = " (stolen)"
              color = 0xffff0000
            elseif good.illegal then
              regular = " (illegal)"
              color = 0xffff0000
            elseif good.dangerous then
              regular = " (dangerous)"
              color = 0xffee8800
            elseif good.suspicious then
              regular = " (suspicious)"
              color = 0xffeeee00
            end
            local maxSpace = playerShip.maxCargoSpace
            bar:setRange(0, maxSpace)
            bar.value = amount * good.size
            bar.color = ColorInt(color)
            icon.picture = good.icon
            icon.color = ColorInt(color)
            if amount > 1 then
                bar.name = amount .. " " .. good.plural .. regular
                playerTotalCargoBar:addEntry(amount * good.size, amount .. " " .. good.plural .. regular, ColorInt(color))
            else
                bar.name = amount .. " " .. good.name .. regular
                playerTotalCargoBar:addEntry(amount * good.size, amount .. " " .. good.name .. regular, ColorInt(color))
            end
        end

        local bar = selfCargoUI[i].sbar
        local button = selfCargoUI[i].sbutton
        local button2 = selfCargoUI[i].sbutton2
        local icon = selfCargoUI[i].sicon
        if i > ship.numCargos then
            for _, element in pairs (selfCargoUI[i]) do element:hide() end
        else
            for _, element in pairs (selfCargoUI[i]) do element:show() end


            local good, amount = ship:getCargo(i - 1)
            local regular = ''
            local color = 0xffa0a0a0
            if good.stolen then
              regular = " (stolen)"
              color = 0xffff0000
            elseif good.illegal then
              regular = " (illegal)"
              color = 0xffff0000
            elseif good.dangerous then
              regular = " (dangerous)"
              color = 0xffee8800
            elseif good.suspicious then
              regular = " (suspicious)"
              color = 0xffeeee00
            end
            local maxSpace = ship.maxCargoSpace
            bar:setRange(0, maxSpace)
            bar.value = amount * good.size
            bar.color = ColorInt(color)
            icon.picture = good.icon
            icon.color = ColorInt(color)

            if amount > 1 then
                bar.name = amount .. " " .. good.plural .. regular
                selfTotalCargoBar:addEntry(amount * good.size, amount .. " " .. good.plural .. regular, ColorInt(color))
            else
                bar.name = amount .. " " .. good.name .. regular
                selfTotalCargoBar:addEntry(amount * good.size, amount .. " " .. good.name .. regular, ColorInt(color))
            end
        end
    end
    playerTotalCargoBar:addEntry(playerShip.freeCargoSpace, 'Free space : '..math.ceil(playerShip.freeCargoSpace*10)/10, ColorRGB(0.1, 0.1, 0.1))
    selfTotalCargoBar:addEntry(ship.freeCargoSpace, 'Free space : '..math.ceil(ship.freeCargoSpace*10)/10, ColorRGB(0.1, 0.1, 0.1))
    -- update fighters info
    playerTotalFightersBar:clear()
    selfTotalFightersBar:clear()

    --fetching the 2 hangars
    local playerHangar = Hangar(playerShip.index)
    local selfHangar = Hangar(ship.index)
    playerTotalFightersBar:setRange(0, playerHangar.space)
    selfTotalFightersBar:setRange(0, selfHangar.space)
    local squads = {playerHangar:getSquads()} --player panel
    local lsquad = -1
    for _, squad in pairs(squads) do --looping through squads
      local squadmax=playerHangar:getSquadFighters(squad) -- the length of current squad
      for j=0, squadmax-1 do --looping for each fighter
        local fighter = playerHangar:getFighter(squad,j)
        local title = "${weaponPrefix} Fighter"%_t % fighter
        playerTotalFightersBar:addEntry(fighter.volume,title,fighter.rarity.color)
        local findex
        --calculate where are the corresponding UI objects
        findex = squad*12+j+1
        playerFighters[findex].pict.picture = fighter.weaponIcon
        playerFighters[findex].pict.color = fighter.rarity.color
        playerFighters[findex].tooltip = makeFTooltip( fighter )
        playerFighters[findex].pict.visible = true
        playerFighters[findex].button.visible = true
      end
      local squadmaxf=playerHangar:getSquadMaxFighters(squad)
      for j=squadmax, squadmaxf-1 do -- hiding unused slots in squad
        local findex
        findex = squad*12+j+1
        playerFighters[findex].pict.visible = false
        playerFighters[findex].button.visible = false
      end
      if squad > lsquad then lsquad = squad end
    end
    for i=lsquad+1, 6 do -- make invisible the missing squads
      for j=0, 11 do
        local findex
        findex = i*12+j+1
        playerFighters[findex].pict.visible = false
        playerFighters[findex].button.visible = false
      end
    end
    local squads = {selfHangar:getSquads()} --other panel
    local lsquad = -1
    for _, squad in pairs(squads) do --looping through squads
      local squadmax=selfHangar:getSquadFighters(squad) -- the length of current squad
      for j=0, squadmax-1 do --looping for each fighter
        local fighter = selfHangar:getFighter(squad,j)
        local title = "${weaponPrefix} Fighter"%_t % fighter
        selfTotalFightersBar:addEntry(fighter.volume,title,fighter.rarity.color)
        local findex
        findex = squad*12+j+1
        selfFighters[findex].pict.picture = fighter.weaponIcon
        selfFighters[findex].pict.color = fighter.rarity.color
        selfFighters[findex].tooltip = makeFTooltip( fighter )
        selfFighters[findex].pict.visible = true
        selfFighters[findex].button.visible = true
      end
      local squadmaxf=selfHangar:getSquadMaxFighters(squad)
      for j=squadmax, squadmaxf-1 do -- hiding unused slots in squad
        local findex
        findex = squad*12+j+1
        selfFighters[findex].pict.visible = false
        selfFighters[findex].button.visible = false
      end
      if squad > lsquad then lsquad = squad end
    end
    for i=lsquad+1, 6 do -- make invisible the missing squads
      for j=0, 11 do
        local findex
        findex = i*12+j+1
        selfFighters[findex].pict.visible = false
        selfFighters[findex].button.visible = false
      end
    end
    playerTotalFightersBar:addEntry(playerHangar.freeSpace, "Free space : ".. math.ceil(playerHangar.freeSpace*10)/10, ColorRGB(0.1, 0.1, 0.1))
    selfTotalFightersBar:addEntry(selfHangar.freeSpace, "Free space : ".. math.ceil(selfHangar.freeSpace*10)/10, ColorRGB(0.1, 0.1, 0.1))
end

function onPlayerTransferCrewPressed(button)
    -- transfer crew from player ship to self
    -- check which crew member type
    local crewmanIndex = crewmenByButton[button.index]
    if not crewmanIndex then return end
    if button.caption == '>' then
      invokeServerFunction("transferCrew", crewmanIndex, Player().craftIndex, false)
    else
      for i = 1, 10 do
        invokeServerFunction("transferCrew", crewmanIndex, Player().craftIndex, false)
      end
    end
end

function onSelfTransferCrewPressed(button)
    -- transfer crew from self ship to player ship
    -- check which crew member type
    local crewmanIndex = crewmenByButton[button.index]
    if not crewmanIndex then return end
    if button.caption == '<' then
      invokeServerFunction("transferCrew", crewmanIndex, Player().craftIndex, true)
    else
      for i = 1, 10 do
        invokeServerFunction("transferCrew", crewmanIndex, Player().craftIndex, true)
      end
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
    if button.caption == '>' then
      invokeServerFunction("transferCargo", cargo - 1, Player().craftIndex, false)
    else
      for i = 1, 25 do
        invokeServerFunction("transferCargo", cargo - 1, Player().craftIndex, false)
      end
    end
end

function onSelfTransferCargoPressed(button)
    -- transfer cargo from self to player ship
    -- check which cargo
    local cargo = cargosByButton[button.index]
    if cargo == nil then return end
    if button.caption == '<' then
      invokeServerFunction("transferCargo", cargo - 1, Player().craftIndex, true)
    else
      for i = 1, 25 do
        invokeServerFunction("transferCargo", cargo - 1, Player().craftIndex, true)
      end
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

function onPlayerTFighter(button)
  local fighter=fightersByButton[button.index]--get the index of the squad and the fighter
  invokeServerFunction("transferFighter", fighter, Player().craftIndex, false)
end

function onSelfTFighter(button)
  local fighter=fightersByButton[button.index]--get the index of the squad and the fighter
  invokeServerFunction("transferFighter", fighter, Player().craftIndex, true)
end

function transferFighter(fighterIndex, otherIndex, selfToOther)
    local sender
    local receiver

    if selfToOther then
        sender = Entity()
        receiver = Entity(otherIndex)
    else
        sender = Entity(otherIndex)
        receiver = Entity()
    end
    if sender.factionIndex ~= callingPlayer then --check ownership
        local player = Player(callingPlayer)
        if player then
            player:sendChatMessage("Server"%_t, 1, "You don't own this craft."%_t)
        end
        return
    end
    -- check distance
    if sender:getNearestDistance(receiver) > 5 then
        Player(callingPlayer):sendChatMessage("Server"%_t, 1, "You're too far away."%_t)
        return
    end
    local senderHangar = Hangar(sender.index)
    local receiverHangar = Hangar(receiver.index)
    local squads = {receiverHangar:getSquads()}
    local freesquad = -1
    for _, squad in pairs(squads) do -- getting some free space in receiver squads
      local sqsize = receiverHangar:getSquadFighters(squad)
      if sqsize < receiverHangar:getSquadMaxFighters(squad) then
        freesquad = squad
        break
       end
    end
    
    if freesquad < 0 then
        Player(callingPlayer):sendChatMessage("Server"%_t, 1, "No space in receiver squads."%_t)
        return
    end
    
    local fighter = senderHangar:getFighter(fighterIndex.s,fighterIndex.f)
    if fighter.volume > receiverHangar.freeSpace then -- checking free space in hangar
      Player(callingPlayer):sendChatMessage("Server"%_t, 1, "Receiver hangar is full."%_t)
      return
    end

    receiverHangar:addFighter(freesquad,fighter)
    senderHangar:removeFighter(fighterIndex.f,fighterIndex.s)
    
    invokeClientFunction(Player(callingPlayer), "updateData")
end
--build tooltip for fighters
function makeFTooltip(fighter)
  	-- create tool tip
	local tooltip = Tooltip()
	-- title
	local title = "${weaponPrefix} Fighter"%_t % fighter
	local line = TooltipLine(20, 16)
	line.ctext = title
	line.ccolor = fighter.rarity.color
	tooltip:addLine(line)
  
  --weapon and dps
  local multis = fighter.simultaneousShooting and fighter.numWeapons > 1 and fighter.numWeapons or 1
  local dps=math.floor(fighter.fireRate * multis * fighter.shotsPerFiring * fighter.damage)
  local line = TooltipLine(15,12)
  line.ltext = "DPS"%_t
  line.rtext = dps
  line.icon = fighter.weaponIcon
  line.iconColor = ColorInt(0xa0a0a0)
  tooltip:addLine(line)

	-- durability
	local line = TooltipLine(15, 12)
	line.ltext = "Durability"%_t
	line.rtext = round(fighter.durability)
	line.icon = "data/textures/icons/health-normal.png";
	line.iconColor = ColorInt(0xa0a0a0)
	tooltip:addLine(line)

	local line = TooltipLine(15, 12)
	line.ltext = "Shield"%_t
	line.rtext = fighter.shield > 0 and round(fighter.durability) or "None"
	line.icon = "data/textures/icons/shield.png";
	line.iconColor = ColorInt(0xa0a0a0)
	tooltip:addLine(line)

	tooltip:addLine(TooltipLine(15, 15))

	-- size
	local line = TooltipLine(15, 12)
	line.ltext = "Size"%_t
	line.rtext = math.floor(fighter.volume*10)/10 --what's the unit?
	line.icon = "data/textures/icons/fighter.png";
	line.iconColor = ColorInt(0xa0a0a0)
	tooltip:addLine(line)

	-- maneuverability
	local line = TooltipLine(15, 12)
	line.ltext = "Maneuverability"%_t
	line.rtext = round(fighter.turningSpeed, 2) --what's the unit?
	line.icon = "data/textures/icons/dodge.png";
	line.iconColor = ColorInt(0xa0a0a0)
	tooltip:addLine(line)

	-- velocity
	local line = TooltipLine(15, 12)
	line.ltext = "Speed"%_t
	line.rtext = round(fighter.maxVelocity * 10.0).."m/s" --lyr_nt
	line.icon = "data/textures/icons/afterburn.png";
	line.iconColor = ColorInt(0xa0a0a0)
	tooltip:addLine(line)

  return tooltip
end
--used to get the version installed on the server
function btVersion()
    return 1.12
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
function renderUI()
    local mouse = Mouse().position
    if tabbedWindow:getActiveTab().index == fightersTab.index then
      for _, fUI in pairs (playerFighters) do
        if (fUI.pict.visible) then
          local l = fUI.pict.lower
          local u = fUI.pict.upper
          if mouse.x >= l.x and mouse.x <= u.x and
            mouse.y >= l.y and mouse.y <= u.y then
            fUI.tooltip:drawMouseTooltip(Mouse().position)
          end
        end
      end
    end
end