--- ************************************************************************************************************************************************************************
---
---				Name : 		piecemanager.lua
---				Purpose :	Responsible for managing pieces, the actual game bit
---				Updated:	26 September 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("game.piece")

--- ************************************************************************************************************************************************************************
-- 																This class controls the pieces
--- ************************************************************************************************************************************************************************

local PieceManager = Framework:createClass("game.piece.manager")

--//	Create a new collection of pieces.
--//	@info 	[table]	constructor info (info.rectangle, info.margin, info.gridSize)

function PieceManager:constructor(info)
	self.m_info = info 																-- save information.
	local rect = info.rectangle 													-- reference to the available drawing rectangle.
	info.centre = { x = rect.x + rect.width/2, y = rect.y + rect.height / 2}		-- calculate the centre of the play area 

	local smallest = math.min(rect.width,rect.height)								-- smaller of width and height.
	smallest = smallest - (info.gridSize - 1) * info.margin 						-- allow for margin
	info.gridPixelSize = math.floor(smallest / info.gridSize) 						-- this is the size of each side, they are always square.
	
	self.m_pieceList = {} 															-- array of pieces, in order.
	self.m_displayList = {} 														-- list of display objects
	self.m_valueList = info.factory:get(info.gridSize * info.gridSize)				-- list of values, in order

	if info.isReversed then 														-- if reversed, just reverse the list of values.
		local oldList = self.m_valueList 											-- save original list
		self.m_valueList = {} 														-- new value list
		for i = 1,#oldList do self.m_valueList[#oldList + 1 - i] = oldList[i] end 	-- copy to the old one backwards,
	end
	
	local positionList = {} 														-- work out list of positions
	for x = 1, info.gridSize do 													-- initialise it so that they are done l-r 
		for y = 1,info.gridSize do  												-- top to bottom
			positionList[(y-1)*info.gridSize + x] = { x = x, y = y }
		end 
	end 

	for pass = 1,4 do  																-- randomly shuffle the position list, 4 x n x n times
		for i = 1, info.gridSize * info.gridSize do 								-- so they are all mixed up.
			local swap = math.random(info.gridSize * info.gridSize) 				-- pick one to swap with current
			local t = positionList[i] 												-- and swap it.
			positionList[i] = positionList[swap] 
			positionList[swap] = t 
		end 
	end 

	for i = 1, info.gridSize * info.gridSize do 									-- create the pieces that this controls
		info.index = i 																-- tell it the actual real index
		info.textValue = self.m_valueList[i] .. "" 									-- text to be displayed as a string.
		self.m_pieceList[i] = Framework:new("game.piece",info) 						-- create a piece with this information.
		self.m_pieceList[i]:move(positionList[i].x,positionList[i].y) 				-- put it to its position list space, so each is allocated a random square
		self.m_displayList[i] = self.m_pieceList[i]:getPieceDisplayObject() 		-- store its display object in that list.
	end

	self:tag("enterFrame,pieceManager")												-- tag self.
	self.m_nextRequiredClick = 1 													-- index of next required click
	self.m_lastRequiredClick = info.gridSize * info.gridSize 						-- last required click.
end	

--//	Tidy up

function PieceManager:destructor()
	for i = 1,#self.m_pieceList do 													-- remove all pieces in the list, some may already have been deleted.
		if self.m_pieceList[i]:isAlive() then self.m_pieceList[i]:delete() end
	end 
	self.m_info = nil self.m_pieceList = nil self.m_valueList = nil 				-- null out.
	self.m_positionList = nil
end

--//	Get the display objects, for the game/scene mananger
--//	@return 	[table]		array of display objects

function PieceManager:getDisplayObjects()
	return self.m_displayList 														-- return list we built in the constructor.
end 

--//	Handle the enterFrame event
--//	@dt 	[number] 	elapsed time.

function PieceManager:onEnterFrame(dt)
	self.m_time = (self.m_time or 0) + dt 											-- add to clock
	if self.m_time >= 1 then 														-- if 1s elapsed
		self.m_time = 0 															-- reset the clock
		if self.m_info.isChangingBackground then 									-- are we doing background change ?
			local n = math.random(#self.m_pieceList)								-- pick one and change it.
			if self.m_pieceList[n] ~= nil and self.m_pieceList[n]:isAlive() then
				self.m_pieceList[n]:changeBackground()
			end
		end

		local chance = 5 if self.m_info.isHard then chance = 2 end 					-- hard or easy for rotate/shuffle, affects the chance of it happening

		if math.random(chance) == 1 then 											-- random chance of rotate/shuffle.
			local event = 0 														-- 0 = nothing, 1 = shuffle, 2 = rotate
			if self.m_info.isShuffling then event = 1 end 							-- decide what to do
			if self.m_info.isRotating then event = 2 end 
			if self.m_info.isShuffling and self.m_info.isRotating then 				-- if both, then choose one randomly.
				event = math.random(1,2) 											-- e.g. 1 or 2 !
			end
			if event == 1 then self:shuffle() end 									-- then go do it.
			if event == 2 then self:rotate() end 
		end
	end
end

--//	Shuffle a row of pieces, e.g. push the right most one off and shove it at the start

function PieceManager:shuffle()
	local size = self.m_info.gridSize 												-- number of rows/cols.
	local row = math.random(size) 													-- this is the row we are going to shuffle (rubiks cube style)
	for i = 1,size-1 do 															-- move all but the end one right one.
		self:sendMessage("piece","move", { fromX = i, fromY = row, toX = i+1, toY = row })
	end
	self:sendMessage("piece","move", 												-- finally send the last one back to the start.
							{ fromX = size, fromY = row, toX = 1, toY = row})
end 

--//	Rotate a row of pieces, e.g. the outer ring rotates right once.

function PieceManager:rotate()
	local size = self.m_info.gridSize 												-- number of rows/cols.
	for i = 1,size-1 do 
		self:sendMessage("piece","move", { fromX = i, fromY = 1, toX = i+1, toY = 1 })
		self:sendMessage("piece","move", { fromX = size, fromY = i, toX = size, toY = i+1 })
		self:sendMessage("piece","move", { fromX = i+1, fromY = size, toX = i, toY = size })
		self:sendMessage("piece","move", { fromX = 1, fromY = i+1, toX = 1, toY = i })
	end 
end 

--//	Handle messages
--//	@sender 	[object]		sender
--//	@name 		[string]		message name
--//	@body 		[table]			anything else

function PieceManager:onMessage(sender,name,body)

	if name == "tap" then 															-- is it tapped - this is sent by a piece to indicate it's been tapped
		if body.text.."" == self.m_valueList[self.m_nextRequiredClick].."" then 	-- is it the correct one ? (note casting both to strings)
			self:playSound("correct") 												-- tada !
			self.m_nextRequiredClick = self.m_nextRequiredClick + 1  				-- and advance to the next required entry
			sender:remove()															-- make it go away

			if self.m_nextRequiredClick > self.m_lastRequiredClick then 			-- completed ?
				self:sendMessage("puzzleSceneManager","complete",{ completed = true })	-- tell the puzzle scene manager
			end
		else 
			self:playSound("wrong") 												-- nope, try again
		end 
	end
end
