--- ************************************************************************************************************************************************************************
---
---				Name : 		piece.lua
---				Purpose :	Single piece.
---				Updated:	26 September 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local Piece = Framework:createClass("game.piece")

function Piece:constructor(info)
	self.m_group = display.newGroup()
	self.m_index = info.index 
	self.m_info = info
	self.m_piece = display.newRect(self.m_group,0,0,info.gridPixelSize,info.gridPixelSize)
	self.m_piece.anchorX,self.m_piece.anchorY = 0.5,0.5
	self.m_group.x,self.m_group.y = info.centre.x,info.centre.y
	self.m_piece.strokeWidth = 2 self.m_piece:setFillColor(0,0,0) self.m_piece:setStrokeColor(0,0.5,1)
	local text = display.newText(self.m_group,info.textValue,0,0,native.systemFont,info.gridPixelSize/2)

	local maxSize = self.m_info.gridPixelSize * 0.8 
	if text.width > maxSize or #info.textValue > 2 then 
		local scaleReqd = math.min(0.5,maxSize / text.width)
		text.xScale, text.yScale = scaleReqd,scaleReqd
	end
	if self.m_info.isVerticallyMirrored then 
		text.yScale = -text.yScale 
	end
	if self.m_info.isHorizontallyMirrored then 
		text.xScale = -text.xScale 
	end
	self.m_group.alpha = 0
	self:changeBackground()
end 

function Piece:destructor()
	self.m_group:removeSelf()
	self.m_info = nil self.m_group = nil self.m_piece = nil
end

function Piece:move(x,y)
	self.m_currentX,self.m_currentY = x,y
	local offset = (self.m_info.gridSize + 1) /2
	x = (x - offset) * (self.m_info.gridPixelSize + self.m_info.margin) + self.m_info.centre.x
	y = (y - offset) * (self.m_info.gridPixelSize + self.m_info.margin) + self.m_info.centre.y
	transition.cancel(self.m_group)
	self.m_inMotion = true
	transition.to(self.m_group, { time = 1500, alpha = 1, x = x, y = y, onComplete = function() self.m_inMotion = false end })
end

Piece.backgroundList = { 
	{ 0,0,0 }, { 0,0,1 }, { 0,0.5,0 }, { 1,0,0 }, { 1,0.5,0 }, { 0.5,0.5,0.5 }, {160/255,82/255,45/255}
}

function Piece:changeBackground()
	local n = math.random(#Piece.backgroundList)
	local col = Piece.backgroundList[n]
	self.m_piece:setFillColor(col[1],col[2],col[3])
end

-- WHEN listening for move instructions check it's alive, not been selected, and it's not already in motion.