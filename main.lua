-----------------------------------------------------------------------------------------
--
-- main.lua
-- 
-----------------------------------------------------------------------------------------

local widget = require( "widget" )

display.setDefault( "background", 255, 255, 255 )

fingerPaint = require("fingerPaint")
local canvas = fingerPaint.newCanvas()
canvas:setCanvasColor(0,0,0,0)
canvas:setPaintColor(0,0,0,0)

--Setup Players
players = {}
players[1] = {}
players[2] = {}
players[1]["name"] = "Player 1"
players[1]["score"] = 0
players[2]["name"] = "Player 2"
players[2]["score"] = 0


if "Win" == system.getInfo( "platformName" ) then
    require("win_fix")
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function deepCopy(object)
    local lookup_table = {}
    function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function setPointColor( point, color )
	if (color == "red") then
		point:setFillColor( 1, 0, 0 )
	elseif (color == "blue") then
		point:setFillColor( 0, 0, 1 )
	elseif (color == "green") then
		point:setFillColor( 0, 1, 0 )
	elseif (color == "yellow") then
		point:setFillColor( 1, 1, 0 )
	elseif (color == "purple") then
		point:setFillColor( 1, 0, 1 )
	end
end

function buildCache()
	for i=1, CcolumnCount do
		pointCache[i] = {}
		for j=1, 1000 do
			pointCache[i][j] = {}
			pointCache[i][j]["color"] = colorOptions[ math.random( #colorOptions ) ]
		end
	end
	
	pointCacheSet = deepCopy(pointCache)
end

function setupGame()
	CpointRadius = 10
	CpointSpread = 50
	CpointXoffset = -15
	CpointYoffset = 25

	CcolumnCount = 6
	CmoveCount = 2

	pointCache = {}
	pointCacheSet = {}
	pointArray = {}
	selectedSequence = {}
	sequenceLength = 0
	selectAll = 0
	lineArray = {}
	colorOptions = {"red","blue","green","yellow","purple"}
	currentColor = ""

	remainingMoves = {}
	remainingMoves["number"] = CmoveCount
	remainingMoves["display"] = display.newText( remainingMoves["number"] .. " moves left", display.contentCenterX, 0, native.systemFont, 12 )
	remainingMoves["display"]:setFillColor( 0 )
	score = {}
	score["number"] = 0
	score["display"] = display.newText( score["number"], display.contentCenterX, 25, native.systemFont, 32 )
	score["display"]:setFillColor( 0 )
	
	currentPlayer = 1
			
end

function buildTable()
	gameState = "board"
	for i=1, CcolumnCount do
		pointArray[i] = {}
		local x = (CpointSpread * i) + CpointXoffset
		
		for j=CcolumnCount, 1, -1 do
			local y = (CpointSpread * ((CcolumnCount + 1) - j)) + CpointYoffset
			pointArray[i][j] = {}
			pointArray[i][j]["point"] = display.newCircle( x, y, CpointRadius )
			pointArray[i][j]["color"] = pointCache[i][j]["color"]
			setPointColor( pointArray[i][j]["point"], pointArray[i][j]["color"] )
			table.remove(pointCache[i],j)
		end
			
	end
end

function resetTable()
	selectAll = 0
	sequenceLength = 0
	score["number"] = 0
	score["display"] = display.newText( score["number"], display.contentCenterX, 25, native.systemFont, 32 )
	score["display"]:setFillColor( 0 )
	remainingMoves["number"] = CmoveCount
	remainingMoves["display"] = display.newText( remainingMoves["number"] .. " moves left", display.contentCenterX, 0, native.systemFont, 12 )
	remainingMoves["display"]:setFillColor( 0 )
	pointArray = {}
	currentColor = ""
	pointCache = {}
	pointCache = deepCopy(pointCacheSet)
	buildTable()
end

function clearScreen()
	if sequenceLength > 1 then
		for i=1, sequenceLength - 1 do
			lineArray[i]:removeSelf()
		end
		lineArray = {}
	end
	for i=1, CcolumnCount do
		for j=CcolumnCount, 1, -1 do
			pointArray[i][j]["point"]:removeSelf()
		end
	end
	
	pointArray = {}
	
	remainingMoves["display"]:removeSelf()
	score["display"]:removeSelf()
end

function handleMainMenuButtonEvent( event )

    if ( "ended" == event.phase ) then
		player1Name:removeSelf()
		player2Name:removeSelf()
		winnerName:removeSelf()
		mainMenuButton:removeSelf()
		restartButton:removeSelf()
		displayMainMenu()
    end
end

function handleRestartButtonEvent( event )

    if ( "ended" == event.phase ) then
		player1Name:removeSelf()
		player2Name:removeSelf()
		winnerName:removeSelf()
		mainMenuButton:removeSelf()
		restartButton:removeSelf()
		setupGame()
		buildCache()
		buildTable()
    end
end

function handleNextPlayerButtonEvent( event )

    if ( "ended" == event.phase ) then
		currentPlayer = currentPlayer + 1
		endScore:removeSelf()
		playerName:removeSelf()
		nextPlayerButton:removeSelf()
		
		resetTable()
    end
end

function displayEndScreen()
	sequenceLength = 0
	gameState = "score"
	
	if ( currentPlayer == 1 ) then
		options = 
		{
			text = score["number"],     
			x = display.contentCenterX,
			y = display.contentCenterY,
			width = display.contentWidth,     --required for multi-line and alignment
			font = native.systemFont,   
			fontSize = 96,
			align = "center"  --new alignment parameter
		}
		endScore = display.newText( options )
		endScore:setFillColor( 0 )
	
		options = 
		{
			text = players[currentPlayer]["name"],     
			x = display.contentCenterX,
			y = 20,
			width = display.contentWidth,     --required for multi-line and alignment
			font = native.systemFont,   
			fontSize = 32,
			align = "center"  --new alignment parameter
		}
		playerName = display.newText( options )
		playerName:setFillColor( 0 )
		
		nextPlayerButton = widget.newButton
		{
			x = display.contentCenterX,
			y = display.contentCenterY * 1.5,
			id = "nextPlayer",
			label = "Next Player",
			onEvent = handleNextPlayerButtonEvent,
			emboss = false,
			--properties for a rounded rectangle button...
			shape="roundedRect",
			width = display.contentCenterX,
			height = display.contentHeight / 10,
			cornerRadius = 4,
			fillColor = { default={ 1, 0, 0, .8 }, over={ 1, 0, 0.1, 0.6 } },
			labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1 } }
		}
	else
		options = 
		{
			text = players[1]["name"] .. ": " .. players[1]["score"],     
			x = display.contentCenterX,
			y = 20,
			width = display.contentWidth,     --required for multi-line and alignment
			font = native.systemFont,   
			fontSize = 24,
			align = "center"  --new alignment parameter
		}
		player1Name = display.newText( options )
		player1Name:setFillColor( 0 )
		options = 
		{
			text = players[2]["name"] .. ": " .. players[2]["score"],     
			x = display.contentCenterX,
			y = 100,
			width = display.contentWidth,     --required for multi-line and alignment
			font = native.systemFont,   
			fontSize = 24,
			align = "center"  --new alignment parameter
		}
		player2Name = display.newText( options )
		player2Name:setFillColor( 0 )
		
		local key, max = 1, players[1]["score"]
		for k, v in ipairs(players) do
			if players[k]["score"] > max then
				key, max = k, v
			end
		end
		
		options = 
		{
			text = players[key]["name"] .. " wins!",     
			x = display.contentCenterX,
			y = display.contentCenterY * 1.2,
			width = display.contentWidth,     --required for multi-line and alignment
			font = native.systemFont,   
			fontSize = 48,
			align = "center"  --new alignment parameter
		}
		winnerName = display.newText( options )
		winnerName:setFillColor( 0 )
		
		restartButton = widget.newButton
		{
			x = display.contentCenterX,
			y = display.contentCenterY * 1.65,
			id = "restart",
			label = "Restart",
			onEvent = handleRestartButtonEvent,
			emboss = false,
			--properties for a rounded rectangle button...
			shape="roundedRect",
			width = display.contentCenterX,
			height = display.contentHeight / 10,
			cornerRadius = 4,
			fillColor = { default={ 0, .6, 0, 1 }, over={ 0, .6, 0.2, 0.6 } },
			labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1 } }
		}
		mainMenuButton = widget.newButton
		{
			x = display.contentCenterX,
			y = display.contentCenterY * 1.95,
			id = "mainMenu",
			label = "Main Menu",
			onEvent = handleMainMenuButtonEvent,
			emboss = false,
			--properties for a rounded rectangle button...
			shape="roundedRect",
			width = display.contentCenterX,
			height = display.contentHeight / 10,
			cornerRadius = 4,
			fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0, 0.1, 0.4 } },
			labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1 } }
		}
	end
end

function revertBorders()
	for i=1, CcolumnCount do
		for j=1, CcolumnCount do
			pointArray[i][j]["point"].strokeWidth = 0
			pointArray[i][j]["selected"] = false
			currentColor = ""
		end
	end
	
	if sequenceLength > 1 then
		for i=1, sequenceLength - 1 do
			lineArray[i]:removeSelf()
		end
		lineArray = {}
	end
end

function selectPoint(row, col)
	pointArray[col][row]["point"].strokeWidth = 2
	pointArray[col][row]["point"]:setStrokeColor( 0 )
	pointArray[col][row]["selected"] = true
end

function removePoint(row, col)
	score["number"] = score["number"] + 1
	score["display"].text = score["number"]
	pointArray[col][row]["point"]:removeSelf()
	for i=row, CcolumnCount do
		pointArray[col][i]["point"].y = pointArray[col][i]["point"].y + CpointSpread
	end
	table.remove(pointArray[col],row)
	pointArray[col][CcolumnCount] = {}
	pointArray[col][CcolumnCount]["point"] = display.newCircle( (CpointSpread * col) + CpointXoffset, CpointSpread + CpointYoffset, CpointRadius )
	pointArray[col][CcolumnCount]["color"] = pointCache[col][1]["color"]
	setPointColor( pointArray[col][CcolumnCount]["point"], pointArray[col][CcolumnCount]["color"] )
	table.remove(pointCache[col],1)
end

function drawLine(row, col)
	local x, y, width, height
	
	if selectedSequence[sequenceLength]["row"] == row then
		height = 2
		width = CpointSpread
		y = pointArray[col][row]["point"].y
		if selectedSequence[sequenceLength]["column"] == col - 1 then
			x = pointArray[col][row]["point"].x - (CpointSpread / 2)
		else
			x = pointArray[col][row]["point"].x + (CpointSpread / 2)
		end
	else
		height = CpointSpread
		width = 2
		x = pointArray[col][row]["point"].x
		if selectedSequence[sequenceLength]["row"] == row - 1 then
			y = pointArray[col][row]["point"].y + (CpointSpread / 2)
		else
			y = pointArray[col][row]["point"].y - (CpointSpread / 2)
		end
	end
	
	lineArray[sequenceLength] = display.newRect( x, y, width, height )
	lineArray[sequenceLength]:toBack()
	lineArray[sequenceLength]:setFillColor( 0 )
end
		
function selectAllPoints( color )
	for i=1, CcolumnCount do
		for j=1, CcolumnCount do
			if (pointArray[i][j]["selected"] ~= true and pointArray[i][j]["color"] == color) then
				selectPoint(j,i)
			end
		end
	end
	system.vibrate()
end

function resetSelection()
	for i=1, CcolumnCount do
		for j=1, CcolumnCount do
			pointArray[i][j]["point"].strokeWidth = 0
			pointArray[i][j]["selected"] = false
		end
	end
	
	if sequenceLength > 1 then
		for i=1, sequenceLength  do
			selectPoint(selectedSequence[i]["row"],selectedSequence[i]["column"])
		end
	end
end
		
function onObjectTouch( event )
	if ( gameState == "board" ) then
		if ( event.phase == "moved" ) then
			for i=1, CcolumnCount do
				for j=1, CcolumnCount do
					if pointArray[i][j]["selected"] then
						currentColor = pointArray[i][j]["color"]
					end
					if (pointArray[i][j]["color"] == currentColor or currentColor == "") then
						if event.x >= (pointArray[i][j]["point"].x - (CpointRadius * 1.5)) and event.x <= (pointArray[i][j]["point"].x + (CpointRadius * 1.5)) and
							event.y >= (pointArray[i][j]["point"].y - (CpointRadius * 1.5)) and event.y <= (pointArray[i][j]["point"].y + (CpointRadius * 1.5)) then
							if sequenceLength <=1 or (sequenceLength > 1 and not (selectedSequence[sequenceLength - 1]["row"] == j and selectedSequence[sequenceLength - 1]["column"] == i)) then
								if sequenceLength == 0 or
								  ((selectedSequence[sequenceLength]["row"] == j and (selectedSequence[sequenceLength]["column"] == i - 1 
																					  or selectedSequence[sequenceLength]["column"] == i + 1)) or
								   (selectedSequence[sequenceLength]["column"] == i and (selectedSequence[sequenceLength]["row"] == j - 1 
																						 or selectedSequence[sequenceLength]["row"] == j + 1))) then
									if sequenceLength > 0 then
										drawLine(j,i)
									end
									
									sequenceLength = sequenceLength + 1
									selectedSequence[sequenceLength] = {}
									selectedSequence[sequenceLength]["row"] = j
									selectedSequence[sequenceLength]["column"] = i
										
									if pointArray[i][j]["selected"] == true and pointArray[i][j]["line"] == true then
										selectedSequence[sequenceLength]["selectAll"] = true
										selectAll = selectAll + 1
										selectAllPoints(currentColor)
									else
										selectPoint(j,i)
										pointArray[i][j]["line"] = true
									end
								end
							else
								if (sequenceLength > 1 and (selectedSequence[sequenceLength - 1]["row"] == j and selectedSequence[sequenceLength - 1]["column"] == i)) then
									if selectedSequence[sequenceLength]["selectAll"] then
										selectAll = selectAll - 1
									else
										pointArray[selectedSequence[sequenceLength]["column"]][selectedSequence[sequenceLength]["row"]]["point"].strokeWidth = 0
										pointArray[selectedSequence[sequenceLength]["column"]][selectedSequence[sequenceLength]["row"]]["selected"] = false
										pointArray[selectedSequence[sequenceLength]["column"]][selectedSequence[sequenceLength]["row"]]["line"] = false
									end
									selectedSequence[sequenceLength] = {}
									sequenceLength = sequenceLength - 1
									lineArray[sequenceLength]:removeSelf()
									
									if selectAll == 0 then
										resetSelection()
									end
								end
							end
						end
					end
				end
			end
		elseif ( event.phase == "ended" ) then
			if (sequenceLength >= 2) then
				remainingMoves["number"] = remainingMoves["number"] - 1
				remainingMoves["display"].text = remainingMoves["number"] .. " moves left"
				for i=1, CcolumnCount do
					for j=CcolumnCount, 1, -1 do
						if (pointArray[i][j]["selected"] == true) then
							removePoint(j,i)
						end
					end
				end
			end
			if remainingMoves["number"] == 0 then
				players[currentPlayer]["score"] = score["number"]
				clearScreen()
				displayEndScreen()
			else
				canvas:undo()
				revertBorders()
				selectedSequence = {}
				sequenceLength = 0
			end
		end
	end
    return true
end

function handleStartButtonEvent( event )

    if ( "ended" == event.phase ) then
		startButton:removeSelf()
		title:removeSelf()
		player1Name:removeSelf()
		player2Name:removeSelf()
		
		setupGame()
		buildCache()
		buildTable()
    end
end

function playerNameFunction( event )
	
    if ( event.phase == "ended" or event.phase == "submitted" ) then
        -- user begins editing numericField
		if ( event.target.placeholder == "Player 1" ) then
			players[1]["name"] = event.target.text
		else
			players[2]["name"] = event.target.text
		end
    end   
end

function displayGameSetup()
	gameState = "setup"
	title = display.newText( "Setup Game", display.contentCenterX, 10, native.systemFont, 48 )
	title:setFillColor( 0 )
	
	startButton = widget.newButton
	{
		label = "button",
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onEvent = handleStartButtonEvent,
		emboss = false,
		--properties for a rounded rectangle button...
		shape="roundedRect",
		width = display.contentCenterX,
		height = display.contentHeight / 10,
		cornerRadius = 4,
		fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0, 0.1, 0.4 } }
	}

	-- Change the button's label text
	startButton:setLabel( "Start Game" )
	
	-- Center the button
	startButton.x = display.contentCenterX
	startButton.y = display.contentCenterY * 1.5

	-- Eventually add ability for more than two players
	-- playerNumberLabel = display.newText( "# of players", display.contentCenterX, 100, native.systemFont, 16 )
	-- playerNumberLabel:setFillColor( 0 )
	-- playerNumber = native.newTextField( display.contentCenterX, 150, 220, 36 )
	-- playerNumber.inputType = "number"
	-- playerNumber.text = 2
	-- playerNumber:addEventListener( "userInput", handlerFunction )
	
	player1Name = native.newTextField( display.contentCenterX, display.contentCenterY / 2, 220, 36 )
	player1Name.placeholder = "Player 1"
	player1Name:addEventListener( "userInput", playerNameFunction )

	player2Name = native.newTextField( display.contentCenterX, display.contentCenterY, 220, 36 )
	player2Name.placeholder = "Player 2"
	player2Name:addEventListener( "userInput", playerNameFunction )

end

function handleSetupButtonEvent( event )

    if ( "ended" == event.phase ) then
		setupButton:removeSelf()
		title:removeSelf()
		
		displayGameSetup()
		--setupGame()
		--buildCache()
		--buildTable()
    end
end

function displayMainMenu()
	gameState = "menu"
	title = display.newText( "Points", display.contentCenterX, 20, native.systemFont, 96 )
	title:setFillColor( 0 )
	
	setupButton = widget.newButton
	{
		label = "button",
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onEvent = handleSetupButtonEvent,
		emboss = false,
		--properties for a rounded rectangle button...
		shape="roundedRect",
		width = display.contentCenterX,
		height = display.contentHeight / 10,
		cornerRadius = 4,
		fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0, 0.1, 0.4 } }
	}

	-- Center the button
	setupButton.x = display.contentCenterX
	setupButton.y = display.contentCenterY

	-- Change the button's label text
	setupButton:setLabel( "Setup Game" )
end


canvas:addEventListener( "touch", onObjectTouch )
displayMainMenu()
--setupGame()
--buildCache()
--buildTable()
