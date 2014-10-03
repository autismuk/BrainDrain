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

local PieceManager = Framework:createClass("game.piece.manager")

function PieceManager:constructor(info)
	self.m_info = info 																-- save information.
	local rect = info.rectangle 													-- calculate rectangle.
	info.centre = { x = rect.x + rect.width/2, y = rect.y + rect.height / 2}		-- calculate the centre of the play area 

	local smallest = math.min(rect.width,rect.height)								-- smaller of width and height.
	smallest = smallest - (info.gridSize - 1) * info.margin 						-- allow for margin
	info.gridPixelSize = math.floor(smallest / info.gridSize) 						-- this is how big everything is.
	
	self.m_pieceList = {} 															-- array of pieces, in order.
	self.m_displayList = {}

	local valueList = info.factory:get(info.gridSize * info.gridSize)				-- list of values

	if info.isReversed then 														-- if reversed, just reverse the list of values.
		local oldList = valueList 
		valueList = {}
		for i = 1,#oldList do valueList[#oldList + 1 - i] = oldList[i] end 
	end
	
	local positionList = {} 														-- work out list of positions
	for x = 1, info.gridSize do 
		for y = 1,info.gridSize do 
			positionList[(y-1)*info.gridSize + x] = { x = x, y = y }
		end 
	end 

	for pass = 1,4 do  																-- randomly shuffle the position list
		for i = 1, info.gridSize * info.gridSize do 
			local swap = math.random(info.gridSize * info.gridSize) 
			local t = positionList[i] 
			positionList[i] = positionList[swap] 
			positionList[swap] = t 
		end 
	end 

	for i = 1, info.gridSize * info.gridSize do 									-- create them.
		info.index = i 																-- tell it the actual real index
		info.textValue = valueList[i] .. "" 										-- text to be displayed as a string.
		self.m_pieceList[i] = Framework:new("game.piece",info) 						-- create a piece
		self.m_pieceList[i]:move(positionList[i].x,positionList[i].y) 				-- put it to its position list space.
		self.m_displayList[i] = self.m_pieceList[i]:getDisplayObject() 				-- create display object list.
	end

	self:tag("enterFrame,pieceManager")
	self.m_nextRequiredClick = 1 													-- index of next required click
	self.m_lastRequiredClick = info.gridSize * info.gridSize 						-- last required click.
end	

function PieceManager:destructor()
	for i = 1,#self.m_pieceList do 
		if self.m_pieceList[i]:isAlive() then self.m_pieceList[i]:delete() end
	end 
	self.m_info = nil self.m_pieceList = nil
end

function PieceManager:getDisplayObjects()
	return self.m_displayList
end 

function PieceManager:onEnterFrame(dt)
	self.m_time = (self.m_time or 0) + dt 											-- add to clock
	if self.m_time >= 1 then 														-- if 1s elapsed
		self.m_time = 0
		if self.m_info.isChangingBackground then 									-- background change
			local n = math.random(#self.m_pieceList)								-- pick one and change it.
			if self.m_pieceList[n] ~= nil and self.m_pieceList[n]:isAlive() then
				self.m_pieceList[n]:changeBackground()
			end
		end
		local chance = 5 if self.m_info.isHard then chance = 2 end 					-- hard or easy for rotate/shuffle
		if math.random(chance) == 1 then 											-- random chance of rotate/shuffle.
			local event = 0
			if self.m_info.isShuffling then event = 1 end 							-- decide what to do
			if self.m_info.isRotating then event = 2 end 
			if self.m_info.isShuffling and self.m_info.isRotating then 				-- if both, then choose one randomly.
				event = math.random(1,2)
			end
			if event == 1 then self:shuffle() end 									-- then go do it.
			if event == 2 then self:rotate() end 
		end
	end
end

function PieceManager:shuffle()
	local size = self.m_info.gridSize 												-- number of rows/cols.
	local row = math.random(size) 													-- this is the row we are going to shuffle (rubiks cube style)
	for i = 1,size-1 do 															-- move all but the end one right one.
		self:sendMessage("piece","move", { fromX = i, fromY = row, toX = i+1, toY = row })
	end
	self:sendMessage("piece","move", { fromX = size, fromY = row, toX = 1, toY = row})
end 

function PieceManager:rotate()
	local size = self.m_info.gridSize 												-- number of rows/cols.
	for i = 1,size-1 do 
		self:sendMessage("piece","move", { fromX = i, fromY = 1, toX = i+1, toY = 1 })
		self:sendMessage("piece","move", { fromX = size, fromY = i, toX = size, toY = i+1 })
		self:sendMessage("piece","move", { fromX = i+1, fromY = size, toX = i, toY = size })
		self:sendMessage("piece","move", { fromX = 1, fromY = i+1, toX = 1, toY = i })
	end 
end 

function PieceManager:onMessage(sender,name,body)
	if name == "tap" then 															-- is it tapped ?
		local index = body.index 
		if index == self.m_nextRequiredClick then 									-- is it the correct one ?
			self:playSound("correct")
			self.m_nextRequiredClick = self.m_nextRequiredClick + 1 
			sender:remove()															-- make it go away
			if self.m_nextRequiredClick > self.m_lastRequiredClick then 			-- completed ?
				self:sendMessage("puzzleSceneManager","complete",{ completed = true })	-- tell the puzzle scene manager
			end
		else 
			self:playSound("wrong")
		end 
	end
end
