-----------------------------------------------------------------------------------------
--
-- main.lua
-- 
-----------------------------------------------------------------------------------------
display.setDefault( "background", 255, 255, 255 )
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
remainingMoves["number"] = 20
remainingMoves["display"] = display.newText( remainingMoves["number"] .. " moves left", display.contentWidth / 2, 0, native.systemFont, 12 )
remainingMoves["display"]:setFillColor( 0 )
score = display.newText( 0, display.contentWidth / 2, 25, native.systemFont, 32 )
score:setFillColor( 0 )

local widget = require( "widget" )

local fingerPaint = require("fingerPaint")
local canvas = fingerPaint.newCanvas()
canvas:setCanvasColor(0,0,0,0)
canvas:setPaintColor(0,0,0,0)

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function deepCopy(object)
    local lookup_table = {}
    local function _copy(object)
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

local function setPointColor( point, color )
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

local function buildCache()
	for i=1, 4 do
		pointCache[i] = {}
		for j=1, 120 do
			pointCache[i][j] = {}
			pointCache[i][j]["color"] = colorOptions[ math.random( #colorOptions ) ]
		end
	end
	
	pointCacheSet = deepCopy(pointCache)
end

local function buildTable()
	for i=1, 4 do
		pointArray[i] = {}
		local x = (75 * i) - 25
		
		for j=4, 1, -1 do
			local y = 75 * (5-j)
			pointArray[i][j] = {}
			pointArray[i][j]["point"] = display.newCircle( x, y, 25 )
			pointArray[i][j]["color"] = pointCache[i][j]["color"]
			setPointColor( pointArray[i][j]["point"], pointArray[i][j]["color"] )
			table.remove(pointCache[i],j)
		end
			
	end
end

local function resetTable()
	selectAll = 0
	score.text = 0
	remainingMoves["number"] = 20
	remainingMoves["display"].text = remainingMoves["number"] .. " moves left"
	pointArray = {}
	currentColor = ""
	pointCache = {}
	pointCache = deepCopy(pointCacheSet)
	buildTable()
end

local function revertBorders()
	for i=1, 4 do
		for j=1, 4 do
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

local function removePoint(row, col)
	score.text = score.text + 1
	pointArray[col][row]["point"]:removeSelf()
	for i=row, 4 do
		pointArray[col][i]["point"].y = pointArray[col][i]["point"].y + 75
	end
	table.remove(pointArray[col],row)
	pointArray[col][4] = {}
	pointArray[col][4]["point"] = display.newCircle( (75 * col) - 25, 75, 25 )
	pointArray[col][4]["color"] = pointCache[col][1]["color"]
	setPointColor( pointArray[col][4]["point"], pointArray[col][4]["color"] )
	table.remove(pointCache[col],1)
end

local function drawLine(row, col)
	local x, y, width, height
	
	if selectedSequence[sequenceLength]["row"] == row then
		height = 5
		width = 25
		y = pointArray[col][row]["point"].y
		if selectedSequence[sequenceLength]["column"] == col - 1 then
			x = pointArray[col][row]["point"].x - 37.5
		else
			x = pointArray[col][row]["point"].x + 37.5
		end
	else
		height = 25
		width = 5
		x = pointArray[col][row]["point"].x
		if selectedSequence[sequenceLength]["row"] == row - 1 then
			y = pointArray[col][row]["point"].y + 37.5
		else
			y = pointArray[col][row]["point"].y - 37.5
		end
	end
	
	lineArray[sequenceLength] = display.newRect( x, y, width, height )
	lineArray[sequenceLength]:toBack()
	lineArray[sequenceLength]:setFillColor( 0 )
end
		
local function selectAllPoints( color )
	for i=1, 4 do
		for j=1, 4 do
			if (pointArray[i][j]["selected"] ~= true and pointArray[i][j]["color"] == color) then
				pointArray[i][j]["point"].strokeWidth = 5
				pointArray[i][j]["point"]:setStrokeColor( 1, 0.8, 0 )
				pointArray[i][j]["selected"] = true
			end
		end
	end
end

local function resetSelection()
	for i=1, 4 do
		for j=1, 4 do
			pointArray[i][j]["point"].strokeWidth = 0
			pointArray[i][j]["selected"] = false
		end
	end
	
	if sequenceLength > 1 then
		for i=1, sequenceLength  do
			pointArray[selectedSequence[i]["column"]][selectedSequence[i]["row"]]["point"].strokeWidth = 5
			pointArray[selectedSequence[i]["column"]][selectedSequence[i]["row"]]["point"]:setStrokeColor( 1, 0.8, 0 )
			pointArray[selectedSequence[i]["column"]][selectedSequence[i]["row"]]["selected"] = true
		end
	end
end
		
local function onObjectTouch( event )
    if ( event.phase == "moved" ) then
		for i=1, 4 do
			for j=1, 4 do
				if pointArray[i][j]["selected"] then
					currentColor = pointArray[i][j]["color"]
				end
				if (pointArray[i][j]["color"] == currentColor or currentColor == "") then
					if event.x >= (pointArray[i][j]["point"].x - 25) and event.x <= (pointArray[i][j]["point"].x + 25) and
						event.y >= (pointArray[i][j]["point"].y - 25) and event.y <= (pointArray[i][j]["point"].y + 25) then
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
									print (selectAll)
									selectAllPoints(currentColor)
								else
									pointArray[i][j]["point"].strokeWidth = 5
									pointArray[i][j]["point"]:setStrokeColor( 1, 0.8, 0 )
									pointArray[i][j]["selected"] = true
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
								
								print(selectAll)
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
			for i=1, 4 do
				for j=4, 1, -1 do
					if (pointArray[i][j]["selected"] == true) then
						removePoint(j,i)
					end
				end
			end
		end
        canvas:undo()
		revertBorders()
		selectedSequence = {}
		sequenceLength = 0
    end
    return true
end

local function handleButtonEvent( event )

    if ( "ended" == event.phase ) then
        resetTable()
    end
end

local button1 = widget.newButton
{
    left = 75,
    top = 350,
    id = "button1",
    label = "Reset",
    onEvent = handleButtonEvent
}

buildCache()
buildTable()
canvas:addEventListener( "touch", onObjectTouch )