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

CdefaultPlayerName = "Player "


--Setup Players
playerCount = 2


if "Win" == system.getInfo( "platformName" ) then
    require("win_fix")
end

function setupPlayers()
	if ( players == nil ) then
		players = {}
		for i=1, playerCount do
			players[i] = {}
			players[i]["name"] = CdefaultPlayerName .. i
			players[i]["score"] = 0
			
			players[i]["textbox"] = native.newTextField( display.contentCenterX, display.contentCenterY * .2 + (i * 40) , display.contentCenterX , 36 )
			players[i]["textbox"].placeholder = players[i]["name"]
		end
	else
		topIndex = tablelength(players)
		if ( topIndex < playerCount ) then
			for i=topIndex + 1, playerCount do
				players[i] = {}
				players[i]["name"] = CdefaultPlayerName .. i
				players[i]["score"] = 0
				
				players[i]["textbox"] = native.newTextField( display.contentCenterX, display.contentCenterY * .2 + (i * 40) , display.contentCenterX , 36 )
				players[i]["textbox"].placeholder = players[i]["name"]
			end
		elseif ( topIndex > playerCount ) then
			if (players[topIndex]["textbox"] ~= nil) then
				players[topIndex]["textbox"]:removeSelf()
			end
			players[topIndex] = nil
		else
			for i=1, playerCount do
			players[i]["score"] = 0
			
			players[i]["textbox"] = native.newTextField( display.contentCenterX, display.contentCenterY * .2 + (i * 40) , display.contentCenterX , 36 )
			if ( players[i]["name"] == CdefaultPlayerName .. i ) then
				players[i]["textbox"].placeholder = players[i]["name"]
			else
				players[i]["textbox"].text = players[i]["name"]
			end
		end
		end
	end
end

function loadSounds()
	CchimeCount = 22
	
	soundTable = {}
	soundTable[0] = audio.loadSound("Sounds/square.wav")
	for i=1, CchimeCount do
		local filePath = string.format("Sounds/Chimes/chime-%04d.wav",i)
		soundTable[i] = audio.loadSound(filePath)
	end

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
	elseif (color == "orange") then
		point:setFillColor( 1, .5, 0 )
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
	CtouchCushion = 2

	CcolumnCount = 6
	CmoveCount = 20

	pointCache = {}
	pointCacheSet = {}
	pointArray = {}
	selectedSequence = {}
	sequenceLength = 0
	selectAll = 0
	lineArray = {}
	colorOptions = {"red","blue","green","orange","purple"}
	currentColor = ""

	remainingMoves = {}
	remainingMoves["number"] = CmoveCount
	score = {}
	score["number"] = 0
	
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

local function onAlertComplete( event )
   if event.action == "clicked" then
        local i = event.index
        if i == 1 then
            clearScreen()
			displayLoadScreen()
			displayMainMenu()
        elseif i == 2 then
            -- Do nothing. Cancel button
        end
    end
end

function handleMainMenuGameButtonEvent( event )
    if ( "ended" == event.phase ) then
		local alert = native.showAlert( "Main Menu", "Are you sure you want to quit the current game?", { "OK", "Cancel" }, onAlertComplete )
    end
end

function buildBoardDisplays()
	score["display"] = display.newText( score["number"], display.contentCenterX, 25, native.systemFont, 32 )
	score["display"]:setFillColor( 0 )
	remainingMoves["number"] = CmoveCount
	remainingMoves["display"] = display.newText( remainingMoves["number"] .. " moves left", display.contentCenterX, 0, native.systemFont, 12 )
	remainingMoves["display"]:setFillColor( 0 )
	
	mainMenuGameButton = widget.newButton
	{
		x = display.contentCenterX,
		y = display.contentCenterY * 1.95,
		id = "mainMenu",
		label = "Main Menu",
		onEvent = handleMainMenuGameButtonEvent,
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

function resetTable()
	selectAll = 0
	sequenceLength = 0
	score["number"] = 0
	pointArray = {}
	currentColor = ""
	pointCache = {}
	pointCache = deepCopy(pointCacheSet)
	buildTable()
	buildBoardDisplays()
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
	mainMenuGameButton:removeSelf()
end

function handleMainMenuButtonEvent( event )

    if ( "ended" == event.phase ) then
		for i=1, playerCount do
			players[i]["endDisplay"]:removeSelf()
		end

		winnerName:removeSelf()
		mainMenuButton:removeSelf()
		restartButton:removeSelf()
		displayLoadScreen()
		displayMainMenu()
    end
end

function handleRestartButtonEvent( event )

    if ( "ended" == event.phase ) then
		for i=1, playerCount do
			players[i]["endDisplay"]:removeSelf()
		end

		winnerName:removeSelf()
		mainMenuButton:removeSelf()
		restartButton:removeSelf()
		setupGame()
		buildCache()
		buildTable()
		buildBoardDisplays()
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
	
	if ( currentPlayer < playerCount ) then
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
		winner = 1
		tie = {}
		for i=1, playerCount do
			options = 
			{
				text = players[i]["name"] .. ": " .. players[i]["score"],     
				x = display.contentCenterX,
				y = display.contentCenterY * .05 + ((i - 1) * 40),
				width = display.contentWidth,     --required for multi-line and alignment
				font = native.systemFont,   
				fontSize = 24,
				align = "center"  --new alignment parameter
			}
			players[i]["endDisplay"] = display.newText( options )
			players[i]["endDisplay"]:setFillColor( 0 )

			if (players[i]["score"] > players[winner]["score"]) or (i == 1) then
				winner = i
				tie = {}
			elseif (players[i]["score"] == players[winner]["score"]) then
				numTies = tablelength(tie)
				if (numTies == 0 and i ~= 1) then
					tie[1] = winner
					tie[2] = i
				else
					tie[numTies + 1] = i
					print("here")
				end
			end
		end

		numTied = tablelength(tie)
		if (numTied == 0) then
			winnerText = players[winner]["name"] .. " wins!"
		else
			winnerText = ""
			for i=1, numTied do
				if (i == numTied) then
					winnerText = winnerText .. ((i == 2) and " " or "") .. "and "
				end

				winnerText = winnerText .. players[tie[i]]["name"]

				if (i == numTied) then
					winnerText = winnerText .. " tied!"
				elseif (numTied > 2) then
					winnerText = winnerText .. ", "
				end
			end
		end

		options = 
		{
			text = winnerText,     
			x = display.contentCenterX,
			y = display.contentCenterY * 1.2,
			width = display.contentWidth,     --required for multi-line and alignment
			font = native.systemFont,   
			fontSize = 40,
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
	
	if ( sequenceLength <= CchimeCount ) then
		audio.play(soundTable[sequenceLength])
	else
		audio.play(soundTable[CchimeCount - (math.fmod(CchimeCount,sequenceLength))])
	end
	
end

function removePoint(row, col, countScore)
	if ( countScore == true ) then
		score["number"] = score["number"] + 1
		score["display"].text = score["number"]
	end
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
	
	if ( selectAll == 1 ) then
		audio.play(soundTable[0])
		system.vibrate()
	end
end

function resetSelection()
	for i=1, CcolumnCount do
		for j=1, CcolumnCount do
			pointArray[i][j]["point"].strokeWidth = 0
			pointArray[i][j]["selected"] = false
		end
	end
	
	if sequenceLength >= 1 then
		for i=1, sequenceLength  do
			selectPoint(selectedSequence[i]["row"],selectedSequence[i]["column"])
		end
	end
end

function checkForMoves()
	for i=1, CcolumnCount do
		for j=1, CcolumnCount do
			if ( i > 1 ) then
				if ( pointArray[i][j]["color"] == pointArray[i-1][j]["color"] ) then
					return 1
				end
			end
			if ( j > 1 ) then
				if ( pointArray[i][j]["color"] == pointArray[i][j-1]["color"] ) then
					return 1
				end
			end
		end
	end
	
	return 0
end

function removeBottomRow()
	for i=1, CcolumnCount do
		removePoint(1,i,false)
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
						if event.x >= (pointArray[i][j]["point"].x - (CpointRadius * CtouchCushion)) and event.x <= (pointArray[i][j]["point"].x + (CpointRadius * CtouchCushion)) and
							event.y >= (pointArray[i][j]["point"].y - (CpointRadius * CtouchCushion)) and event.y <= (pointArray[i][j]["point"].y + (CpointRadius * CtouchCushion)) then
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
							removePoint(j,i,true)
						end
					end
				end
				while ( checkForMoves() == 0 ) do
					removeBottomRow()
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
				selectAll = 0
			end
		end
	end
    return true
end

function handleStartButtonEvent( event )

    if ( "ended" == event.phase ) then
		for i=1, playerCount do
			if ( players[i]["textbox"].text ~= nil or players[i]["textbox"].text ~= "" ) then
				players[i]["name"] = players[i]["textbox"].text
				players[i]["textbox"]:removeSelf()
			else
				players[i]["name"] = CdefaultPlayerName .. i
			end
		end

		startButton:removeSelf()
		backButton:removeSelf()
		playerCountText:removeSelf()
		title:removeSelf()
		pointsLogo:removeSelf()
		decreasePlayers:removeSelf()
		increasePlayers:removeSelf()
		
		setupGame()
		buildCache()
		buildTable()
		buildBoardDisplays()
		while ( checkForMoves() == 0 ) do
			removeBottomRow()
		end
    end
end

function handleBackButtonEvent( event )
	if (event.phase == "ended") then
		if ( gameState == "setup" ) then
			startButton:removeSelf()
			playerCountText:removeSelf()
			title:removeSelf()
			decreasePlayers:removeSelf()
			increasePlayers:removeSelf()
			for i=1, playerCount do
				players[i]["textbox"]:removeSelf()
			end
		else
			licensesButton:removeSelf()
		end
		backButton:removeSelf()
		pointsLogo:removeSelf()
		
		displayLoadScreen()
		displayMainMenu()
	end
end

function decreasePlayersHandler( event )
	if ( playerCount > 1 ) then
		playerCount = playerCount - 1
		playerCountText.text = playerCount
		setupPlayers()
	end
end

function increasePlayersHandler( event )
	if ( playerCount < 4 ) then
		playerCount = playerCount + 1
		playerCountText.text = playerCount
		setupPlayers()
	end
end

function displayGameSetup()
	gameState = "setup"
	playerCountText = display.newText( playerCount, display.contentCenterX, display.contentCenterY * .025, native.systemFont, 48 )
	playerCountText:setFillColor( 0 )
	title = display.newText( "Players", display.contentCenterX, display.contentCenterY * .15, native.systemFont, 18 )
	title:setFillColor( 0 )
	
	decreasePlayers = display.newPolygon( display.contentCenterX * .25, display.contentCenterY * .025, {0,20, 20,40, 20,0} )
	decreasePlayers:setFillColor( 0 )
	
	increasePlayers = display.newPolygon( display.contentCenterX * 1.75, display.contentCenterY * .025, {0,-20, -20,-40, -20,0} )
	increasePlayers:setFillColor( 0 )
	
	decreasePlayers:addEventListener("touch", decreasePlayersHandler)
	increasePlayers:addEventListener("touch", increasePlayersHandler)
	
	
	startButton = widget.newButton
	{
		label = "Start Game",
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onEvent = handleStartButtonEvent,
		emboss = false,
		--properties for a rounded rectangle button...
		shape="roundedRect",
		width = display.contentCenterX,
		height = display.contentHeight / 10,
		cornerRadius = 4,
		fillColor = { default={ 0, .8, 0, 1 }, over={ 0, .8, 0, 0.4 } }
	}
	
	-- Center the button
	startButton.x = display.contentCenterX
	startButton.y = display.contentCenterY * 1.5
	
	backButton = widget.newButton
	{
		label = "Back",
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onEvent = handleBackButtonEvent,
		emboss = false,
		--properties for a rounded rectangle button...
		shape="roundedRect",
		width = display.contentCenterX,
		height = display.contentHeight / 10,
		cornerRadius = 4,
		fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0, 0.1, 0.4 } }
	}

	backButton.x = display.contentCenterX
	backButton.y = display.contentCenterY * 1.75
end

function handleSetupButtonEvent( event )

    if ( "ended" == event.phase ) then
		setupButton:removeSelf()
		aboutButton:removeSelf()
		title:removeSelf()
		pointsLogo.alpha = 0.25
		
		setupPlayers()
		displayGameSetup()
    end
end

function handleLicenseButtonEvent( event )

    if ( "ended" == event.phase ) then
		system.openURL( "https://github.com/sdmadsen/Points/issues/12" )
    end
end

function displayAboutSetup()
	licensesButton = widget.newButton
	{
		label = "Licenses",
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onEvent = handleLicenseButtonEvent,
		emboss = false,
		--properties for a rounded rectangle button...
		shape="roundedRect",
		width = display.contentCenterX,
		height = display.contentHeight / 10,
		cornerRadius = 4,
		fillColor = { default={ 0, 0, 1, 1 }, over={ 0, 0, 1, 0.4 } }
	}

	licensesButton.x = display.contentCenterX
	licensesButton.y = display.contentCenterY * 1.5

	backButton = widget.newButton
	{
		label = "Back",
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onEvent = handleBackButtonEvent,
		emboss = false,
		--properties for a rounded rectangle button...
		shape="roundedRect",
		width = display.contentCenterX,
		height = display.contentHeight / 10,
		cornerRadius = 4,
		fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0, 0.1, 0.4 } }
	}

	backButton.x = display.contentCenterX
	backButton.y = display.contentCenterY * 1.75
end

function handleAboutButtonEvent( event )
	if ( event.phase == "ended" ) then
		setupButton:removeSelf()
		aboutButton:removeSelf()
		title:removeSelf()
		pointsLogo.alpha = 0.1
		
		gameState = "about"
		
		displayAboutSetup()
	end
end

function fitImage( displayObject, fitWidth, fitHeight, enlarge )
	local scaleFactor = fitHeight / displayObject.height 
	local newWidth = displayObject.width * scaleFactor
	if newWidth > fitWidth then
		scaleFactor = fitWidth / displayObject.width 
	end
	if not enlarge and scaleFactor > 1 then
		return
	end
	displayObject:scale( scaleFactor, scaleFactor )
end

function displayLoadScreen()
	gameState = "loading"
	pointsLogo = display.newImage( "iTunesArtwork.png", display.contentCenterX, display.contentCenterY )
	fitImage( pointsLogo, display.contentCenterX, display.contentCenterX, false )
	
end

function displayMainMenu()
	gameState = "menu"
	title = display.newText( "Points", display.contentCenterX, display.contentCenterY * .25, native.systemFont, 96 )
	title:setFillColor( 0 )
	
	setupButton = widget.newButton
	{
		label = "Setup Game",
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onEvent = handleSetupButtonEvent,
		emboss = false,
		--properties for a rounded rectangle button...
		shape="roundedRect",
		width = display.contentCenterX,
		height = display.contentHeight / 10,
		cornerRadius = 4,
		fillColor = { default={ 0, .8, 0, 1 }, over={ 0, .8, 0, 0.4 } }
	}

	setupButton.x = display.contentCenterX
	setupButton.y = display.contentCenterY * 1.5
	
	aboutButton = widget.newButton
	{
		label = "About",
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onEvent = handleAboutButtonEvent,
		emboss = false,
		--properties for a rounded rectangle button...
		shape="roundedRect",
		width = display.contentCenterX,
		height = display.contentHeight / 10,
		cornerRadius = 4,
		fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0, 0.1, 0.4 } }
	}

	aboutButton.x = display.contentCenterX
	aboutButton.y = display.contentCenterY * 1.75
end


canvas:addEventListener( "touch", onObjectTouch )
displayLoadScreen()
loadSounds()
displayMainMenu()
--setupGame()
--buildCache()
--buildTable()
