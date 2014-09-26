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
	self.info = info 																-- save information
	local rect = info.rectangle 													-- calculate rectangle.
	info.centre = { x = rect.x + rect.width/2, y = rect.y + rect.height / 2}		-- calculate the centre of the play area 

	local smallest = math.min(rect.width,rect.height)								-- smaller of width and height.
	smallest = smallest - (info.gridSize - 1) * info.margin 						-- allow for margin
	info.gridPixelSize = math.floor(smallest / info.gridSize) 						-- this is how big everything is.
	
	self.pieceList = {} 															-- array of pieces, in order.
	local valueList = info.factory(info.gridSize * info.gridSize)					-- list of values

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

	for pass = 1,0 do  																-- randomly shuffle the position list
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
		self.pieceList[i] = Framework:new("game.piece",info) 						-- create a piece
		self.pieceList[i]:move(positionList[i].x,positionList[i].y) 				-- put it to its position list space.
	end

end	

function PieceManager:destructor()
	for i = 1,#self.pieceList do 
		if self.pieceList[i]:isAlive() then self.pieceList[i]:delete() end
	end 
	self.info = nil self.pieceList = nil
end