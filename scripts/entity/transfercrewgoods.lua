package.path = package.path .. ";data/scripts/lib/?.lua"

require("utility")
require("stringutility")

MAXTRANSFER = 999

local playerTotalCrewBar;
local selfTotalCrewBar;

local playerCrewBars = {}
local playerCrewButtons = {}
local playerCrewNumberFields = {}
local playerCrewIcon = {}

local selfCrewBars = {}
local selfCrewButtons = {}
local selfCrewNumberFields = {}
local selfCrewIcon = {}

local playerTotalCargoBar;
local selfTotalCargoBar;

local playerCargoBars = {}
local playerCargoButtons = {}
local playerCargoNumberFields = {}
local playerCargoIcon = {}

local selfCargoBars = {}
local selfCargoButtons = {}
local selfCargoNumberFields = {}
local selfCargoIcon = {}

local playerTotalFighterBar;
local selfTotalFighterBar;

local playerFighters = {}
local selfFighters = {}
local playerSquad = {}
local selfSquad = {}

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
        local vsplit1 = UIVerticalSplitter(vsplit.left, 3, 0, 0.15)
        local vsplit2 = UIVerticalSplitter(vsplit.right, 3, 0, 0.5)

        local button = leftFrame:createButton(vsplit2.right, ">", "onPlayerTransferCrewPressed")
        local numberTextBox = leftFrame:createTextBox(vsplit2.left, "onNumberfieldEntered")
        numberTextBox.text = "1"
        numberTextBox.allowedCharacters = "0123456789"
        numberTextBox.clearOnClick = 1
        local bar = leftFrame:createStatisticsBar(vsplit1.right, ColorRGB(1, 1, 1))
        local icon = leftFrame:createPicture(vsplit1.left,"data/textures/icons/backup.png")
        button.textSize = 12
        icon.flipped = true -- else the icon is upside down
        icon.isIcon = true

        table.insert(playerCrewButtons, button)
        table.insert(playerCrewBars, bar)
        table.insert(playerCrewNumberFields, numberTextBox)
        table.insert(playerCrewIcon, icon)
        crewmenByButton[button.index] = i


        local rect = rightLister:placeCenter(vec2(rightLister.inner.width, 25))
        local vsplit = UIVerticalSplitter(rect, 7, 0, 0.20)
        local vsplit1 = UIVerticalSplitter(vsplit.right, 3, 0, 0.85)
        local vsplit2 = UIVerticalSplitter(vsplit.left, 3, 0, 0.5)

        local button = rightFrame:createButton(vsplit2.left, "<", "onSelfTransferCrewPressed")
        local numberTextBox = rightFrame:createTextBox(vsplit2.right, "onNumberfieldEntered")
        numberTextBox.text = "1"
        numberTextBox.allowedCharacters = "0123456789"
        numberTextBox.clearOnClick = 1
        local bar = rightFrame:createStatisticsBar(vsplit1.left, ColorRGB(1, 1, 1))
        local icon = rightFrame:createPicture(vsplit1.right,"data/textures/icons/backup.png")
        button.textSize = 12
        icon.flipped = true -- else the icon is upside down
        icon.isIcon = true

        table.insert(selfCrewButtons, button)
        table.insert(selfCrewBars, bar)
        table.insert(selfCrewNumberFields, numberTextBox)
        table.insert(selfCrewIcon, icon)
        crewmenByButton[button.index] = i
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


    for i = 1, 30 do

        local rect = leftLister:placeCenter(vec2(leftLister.inner.width, 25))
        local vsplit = UIVerticalSplitter(rect, 7, 0, 0.80)
        local vsplit1 = UIVerticalSplitter(vsplit.left, 3, 0, 0.15)
        local vsplit2 = UIVerticalSplitter(vsplit.right, 3, 0, 0.5)

        local button = leftFrame:createButton(vsplit2.right, ">", "onPlayerTransferCargoPressed")
        local numberTextBox = leftFrame:createTextBox(vsplit2.left, "onNumberfieldEntered")
        numberTextBox.text = "1"
        numberTextBox.allowedCharacters = "0123456789"
        numberTextBox.clearOnClick = 1
        
        local bar = leftFrame:createStatisticsBar(vsplit1.right, ColorInt(0xa0a0a0))
        local icon = leftFrame:createPicture(vsplit1.left,"data/textures/icons/trade.png")
        button.textSize = 12
        icon.flipped = true -- else the icon is upside down
        icon.isIcon = true


        table.insert(playerCargoButtons, button)
        table.insert(playerCargoBars, bar)
        table.insert(playerCargoNumberFields, numberTextBox)
        table.insert(playerCargoIcon, icon)
        cargosByButton[button.index] = i


        local rect = rightLister:placeCenter(vec2(rightLister.inner.width, 25))
        local vsplit = UIVerticalSplitter(rect, 10, 0, 0.20)
        local vsplit1 = UIVerticalSplitter(vsplit.right, 3, 0, 0.85)
        local vsplit2 = UIVerticalSplitter(vsplit.left, 3, 0, 0.5)


        local button = rightFrame:createButton(vsplit2.left, "<", "onSelfTransferCargoPressed")
        local numberTextBox = rightFrame:createTextBox(vsplit2.right, "onNumberfieldEntered")
        numberTextBox.text = "1"
        numberTextBox.allowedCharacters = "0123456789"
        numberTextBox.clearOnClick = 1
        
        local bar = rightFrame:createStatisticsBar(vsplit.right, ColorInt(0xa0a0a0))
        local icon = rightFrame:createPicture(vsplit1.right,"data/textures/icons/trade.png")
        button.textSize = 12
        icon.flipped = true -- else the icon is upside down
        icon.isIcon = true

        table.insert(selfCargoButtons, button)
        table.insert(selfCargoBars, bar)
        table.insert(selfCargoNumberFields, numberTextBox)
        table.insert(selfCargoIcon, icon)
        cargosByButton[button.index] = i

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
    
    for i = 1, 6 do
      local rect = leftLister:placeCenter(vec2(leftLister.inner.width, 125))
      local hsplit = UIHorizontalSplitter(rect, 5, 0, 0.2)
      local hsplit2 = UIHorizontalSplitter(hsplit.bottom, 0, 0, 0.5)
      local label = leftFrame:createLabel(vec2(hsplit.top.lower.x+2,hsplit.top.lower.y+4), "Squad "..i, 12)
      local vsplit = UIVerticalMultiSplitter(hsplit2.top, 2, 0, 5)
      local vsplit2 = UIVerticalMultiSplitter(hsplit2.bottom, 2, 0, 5)
      for j = 0, 5 do
        local pic1=leftFrame:createPicture(vsplit:partition(j),"data/textures/icons/fighter.png")
        local button=leftFrame:createButton(vsplit:partition(j),'',"onPlayerTFighter")
        pic1.flipped = true -- else the icon is upside down
        pic1.isIcon = true
        local pic2=leftFrame:createPicture(vsplit2:partition(j),"data/textures/icons/fighter.png")
        local button2=leftFrame:createButton(vsplit2:partition(j),'',"onPlayerTFighter")
        pic2.flipped = true -- else the icon is upside down
        pic2.isIcon = true
        fightersByButton[button.index]={s=i-1, f=j}
        fightersByButton[button2.index]={s=i-1, f=j+6}
        table.insert(playerFighters, { pict=pic1, button=button })
        table.insert(playerFighters, { pict=pic2, button=button2 })
      end


      local rect = rightLister:placeCenter(vec2(rightLister.inner.width,125))
      local hsplit = UIHorizontalSplitter(rect, 5, 0, 0.2)
      local hsplit2 = UIHorizontalSplitter(hsplit.bottom, 0, 0, 0.5)
      local label = rightFrame:createLabel(vec2(hsplit.top.lower.x+2,hsplit.top.lower.y+4), "Squad "..i, 12)
      local vsplit = UIVerticalMultiSplitter(hsplit2.top, 2, 0, 5)
      local vsplit2 = UIVerticalMultiSplitter(hsplit2.bottom, 2, 0, 5)
      for j = 0, 5 do
        local pic1=rightFrame:createPicture(vsplit:partition(j),"data/textures/icons/fighter.png")
        local button=rightFrame:createButton(vsplit:partition(j),'',"onSelfTFighter")
        pic1.flipped = true -- else the icon is upside down
        pic1.isIcon = true
        local pic2=rightFrame:createPicture(vsplit2:partition(j),"data/textures/icons/fighter.png")
        local button2=rightFrame:createButton(vsplit2:partition(j),'',"onSelfTFighter")
        pic2.flipped = true -- else the icon is upside down
        pic2.isIcon = true
        fightersByButton[button.index]={s=i-1, f=j}
        fightersByButton[button2.index]={s=i-1, f=j+6}
        table.insert(selfFighters, { pict=pic1, button=button })
        table.insert(selfFighters, { pict=pic2, button=button2 })
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

    for _, bar in pairs(playerCrewBars) do bar.visible = false end
    for _, bar in pairs(selfCrewBars) do bar.visible = false end
    for _, button in pairs(playerCrewButtons) do button.visible = false end
    for _, button in pairs(selfCrewButtons) do button.visible = false end
    for _, nField in pairs(playerCrewNumberFields) do nField.visible = false end
    for _, nField in pairs(selfCrewNumberFields) do nField.visible = false end
    for _, icon in pairs(playerCrewIcon) do icon.visible = false end
    for _, icon in pairs(selfCrewIcon) do icon.visible = false end

    local i = 1
    for _, p in pairs(getSortedCrewmen(playerShip)) do

        local crewman = p.crewman
        local num = p.num

        local caption = num .. " " .. crewman.profession.name .. " lv " .. crewman.level

        playerTotalCrewBar:addEntry(num, caption, crewman.profession.color)

        local singleBar = playerCrewBars[i]
        singleBar.visible = true
        singleBar:setRange(0, playerShip.maxCrewSize)
        singleBar.value = num
        singleBar.name = caption
        singleBar.color = crewman.profession.color

        local button = playerCrewButtons[i]
        button.visible = true
        
        local icon = playerCrewIcon[i]
        icon.picture = crewman.profession.icon
        icon.color = crewman.profession.color
        icon.visible = true
        
        local numField = playerCrewNumberFields[i]
        local nFAmount = numField.text
        if nFAmount == "" then
            nFAmount = 0
        else
            nFAmount = tonumber(nFAmount)
            if nFAmount >MAXTRANSFER then
                numField.text = tostring(MAXTRANSFER)
            end
        end
        
        numField.visible = true

        i = i + 1
    end

    local i = 1
    for _, p in pairs(getSortedCrewmen(Entity())) do

        local crewman = p.crewman
        local num = p.num

        local caption = num .. " " .. crewman.profession.name .. " lv " .. crewman.level

        selfTotalCrewBar:addEntry(num, caption, crewman.profession.color)

        local singleBar = selfCrewBars[i]
        singleBar.visible = true
        singleBar:setRange(0, ship.maxCrewSize)
        singleBar.value = num
        singleBar.name = caption
        singleBar.color = crewman.profession.color

        local button = selfCrewButtons[i]
        button.visible = true
        
        local icon = selfCrewIcon[i]
        icon.picture = crewman.profession.icon
        icon.color = crewman.profession.color
        icon.visible = true
        
        local numField = selfCrewNumberFields[i]
        local nFAmount = numField.text
        if nFAmount == "" then
            nFAmount = 0
        else
            nFAmount = tonumber(nFAmount)
            if nFAmount >MAXTRANSFER then
                numField.text = tostring(MAXTRANSFER)
            end
        end
        
        numField.visible = true
        
        i = i + 1
    end

    -- update cargo info
    playerTotalCargoBar:clear()
    selfTotalCargoBar:clear()

    playerTotalCargoBar:setRange(0, playerShip.maxCargoSpace)
    selfTotalCargoBar:setRange(0, ship.maxCargoSpace)

    for i, v in pairs(playerCargoBars) do

        local bar = playerCargoBars[i]
        local button = playerCargoButtons[i]
        local numField = playerCargoNumberFields[i]
        local icon = playerCargoIcon[i]
        if i > playerShip.numCargos then
            bar:hide();
            button:hide();
            numField:hide();
            icon:hide();
        else
            bar:show();
            button:show();
            numField:show();
            icon:show();
            local nFAmount =  numField.text
            if nFAmount == "" then
                nFAmount = 0
            else
                nFAmount = tonumber(nFAmount)
                if nFAmount >MAXTRANSFER then
                    numField.text = tostring(MAXTRANSFER)
                end
            end
            
            local good, amount = playerShip:getCargo(i - 1)
            local maxSpace = playerShip.maxCargoSpace
            bar:setRange(0, maxSpace)
            bar.value = amount * good.size
            icon.picture = good.icon

            if amount > 1 then
                bar.name = amount .. " " .. good.plural
                playerTotalCargoBar:addEntry(amount * good.size, amount .. " " .. good.plural, ColorInt(0xffa0a0a0))
            else
                bar.name = amount .. " " .. good.name
                playerTotalCargoBar:addEntry(amount * good.size, amount .. " " .. good.name, ColorInt(0xffa0a0a0))
            end
        end

        local bar = selfCargoBars[i]
        local button = selfCargoButtons[i]
        local numField = selfCargoNumberFields[i]
        local icon = selfCargoIcon[i]
        if i > ship.numCargos then
            bar:hide();
            button:hide();
            numField:hide();
            icon:hide();
        else
            bar:show();
            button:show();
            numField:show();
            icon:show();
            local nFAmount =  numField.text
            if nFAmount == "" then
                nFAmount = 0
            else
                nFAmount = tonumber(nFAmount)
                if nFAmount >MAXTRANSFER then
                    numField.text = tostring(MAXTRANSFER)
                end
            end

            local good, amount = ship:getCargo(i - 1)
            local maxSpace = ship.maxCargoSpace
            bar:setRange(0, maxSpace)
            bar.value = amount * good.size
            icon.picture = good.icon

            if amount > 1 then
                bar.name = amount .. " " .. good.plural
                selfTotalCargoBar:addEntry(amount * good.size, amount .. " " .. good.plural, ColorInt(0xffa0a0a0))
            else
                bar.name = amount .. " " .. good.name
                selfTotalCargoBar:addEntry(amount * good.size, amount .. " " .. good.name, ColorInt(0xffa0a0a0))
            end
        end
    end

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
        if(j<6)then --calculate where are the corresponding UI objects
          findex = squad*12+j*2+1
        else
          findex = squad*12+j*2-10
        end
        playerFighters[findex].pict.picture = fighter.weaponIcon
        playerFighters[findex].pict.color = fighter.rarity.color
        playerFighters[findex].pict.tooltip = title
        playerFighters[findex].pict.visible = true
        playerFighters[findex].button.visible = true
      end
      local squadmaxf=playerHangar:getSquadMaxFighters(squad)
      for j=squadmax, squadmaxf-1 do -- hiding unused slots in squad
        local findex
        if(j<6)then
          findex = squad*12+j*2+1
        else
          findex = squad*12+j*2-10
        end
        playerFighters[findex].pict.visible = false
        playerFighters[findex].button.visible = false
      end
      if squad > lsquad then lsquad = squad end
    end
    for i=lsquad+1, 5 do -- make invisible the missing squads
      for j=0, 11 do
        local findex
        if(j<6)then
          findex = i*12+j*2+1
        else
          findex = i*12+j*2-10
        end
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
        if(j<6)then --calculate where are the corresponding UI objects
          findex = squad*12+j*2+1
        else
          findex = squad*12+j*2-10
        end
        selfFighters[findex].pict.picture = fighter.weaponIcon
        selfFighters[findex].pict.color = fighter.rarity.color
        selfFighters[findex].pict.tooltip = title
        selfFighters[findex].pict.visible = true
        selfFighters[findex].button.visible = true
      end
      local squadmaxf=selfHangar:getSquadMaxFighters(squad)
      for j=squadmax, squadmaxf-1 do -- hiding unused slots in squad
        local findex
        if(j<6)then
          findex = squad*12+j*2+1
        else
          findex = squad*12+j*2-10
        end
        selfFighters[findex].pict.visible = false
        selfFighters[findex].button.visible = false
      end
      if squad > lsquad then lsquad = squad end
    end
    for i=lsquad+1, 5 do -- make invisible the missing squads
      for j=0, 11 do
        local findex
        if(j<6)then
          findex = i*12+j*2+1
        else
          findex = i*12+j*2-10
        end
        selfFighters[findex].pict.visible = false
        selfFighters[findex].button.visible = false
      end
    end

end

function onPlayerTransferCrewPressed(button)
    -- transfer crew from player ship to self

    -- check which crew member type
    local crewmanIndex = crewmenByButton[button.index]
    local amount = playerCrewNumberFields[crewmanIndex].text
    if amount == "" then
        amount = 0
    else
        amount = tonumber(amount)
        if amount >MAXTRANSFER then
            playerCrewNumberFields[crewmanIndex].text = tostring(MAXTRANSFER)
            amount = MAXTRANSFER
        end
    end

    if not crewmanIndex then return end
    for i=1, amount do
        invokeServerFunction("transferCrew", crewmanIndex, Player().craftIndex, false)
    end
end

function onSelfTransferCrewPressed(button)
    -- transfer crew from self ship to player ship

    -- check which crew member type
    local crewmanIndex = crewmenByButton[button.index]
    local amount = selfCrewNumberFields[crewmanIndex].text
    if amount == "" then
        amount = 0
    else
        amount = tonumber(amount)
        if amount >MAXTRANSFER then
            selfCrewNumberFields[crewmanIndex].text = tostring(MAXTRANSFER)
            amount = MAXTRANSFER
        end
    end


    if not crewmanIndex then return end
    for i=1, amount do
        invokeServerFunction("transferCrew", crewmanIndex, Player().craftIndex, true)
    end
end

function onNumberfieldEntered()




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
    local cargo = cargosByButton[button.index]
    -- transfer cargo from player ship to self
    local amount = playerCargoNumberFields[cargo].text
    if amount == "" then
        amount = 0
    else
        amount = tonumber(amount)
        if amount >MAXTRANSFER then
            playerCargoNumberFields[cargo].text = tostring(MAXTRANSFER)
            amount = MAXTRANSFER
        end
    end

    -- check which cargo
    
    if cargo == nil then return end
    for i=1, amount do
        invokeServerFunction("transferCargo", cargo - 1, Player().craftIndex, false)
    end
end

function onSelfTransferCargoPressed(button)
    local cargo = cargosByButton[button.index]
    -- transfer cargo from self to player ship
    local amount = selfCargoNumberFields[cargo].text
    if amount == "" then
        amount = 0
    else
        amount = tonumber(amount)
        if amount >MAXTRANSFER then
            selfCargoNumberFields[cargo].text = tostring(MAXTRANSFER)
            amount = MAXTRANSFER
        end
    end












    -- check which cargo
    
    if cargo == nil then return end
    for i=1, amount do
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

function onPlayerTFighter(button)
  local fighter=fightersByButton[button.index]--get the index of the squad and the fighter
  invokeServerFunction("transferFighter", fighter, Player().craftIndex, false)
end

function onSelfTFighter(button)
  local fighter=fightersByButton[button.index]--get the index of the squad and the fighter
  invokeServerFunction("transferFighter", fighter, Player().craftIndex, true)
end

function transferFighter(fighterIndex, otherIndex, selfToOther)
    print(fighterIndex.s.."/"..fighterIndex.f)
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

