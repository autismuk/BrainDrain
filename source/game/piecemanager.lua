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
	local valueList = info.factory(info.gridSize * info.gridSize)
	print("Todo .... fail if alphabetic and 5x5 +")

	for i = 1, info.gridSize * info.gridSize do 									-- create them.
		info.index = i 																-- tell it the actual real index
		info.textValue = valueList[i] .. "" 										-- text to be displayed as a string.
		self.pieceList[i] = Framework:new("game.piece",info) 						-- create a piece
		self.pieceList[i]:move((i - 1) % info.gridSize + 1,math.floor((i - 1) / info.gridSize) + 1)
	end

end	

function PieceManager:destructor()
	print("Destroy")
	for i = 1,#self.pieceList do 
		self.pieceList[i]:delete()
	end 
	self.info = nil self.pieceList = nil
end