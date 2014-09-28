--- ************************************************************************************************************************************************************************
---
---				Name : 		piece.lua
---				Purpose :	Single piece.
---				Updated:	26 September 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("utils.particle")
require("utils.controllable")

local Piece = Framework:createClass("game.piece","system.controllable")

function Piece:constructor(info)
	self.m_hasBeenKilled = false 													-- set to true when has been killed but running end animation
	self.m_group = display.newGroup()												-- group representing piece
	self.m_index = info.index 														-- index number in sequence
	self.m_info = info 																-- information
	self.m_piece = display.newRoundedRect(self.m_group,0,0,							-- create piece
												info.gridPixelSize,info.gridPixelSize,5)
	self.m_piece.anchorX,self.m_piece.anchorY = 0.5,0.5
	self.m_group.x,self.m_group.y = info.centre.x,info.centre.y
	self.m_piece.strokeWidth = 2
	self.m_piece:setFillColor(0,0,0) self.m_piece:setStrokeColor(0,0.5,1)
	local text = display.newText(self.m_group,info.textValue,0,0,					-- fill text
													native.systemFont,info.gridPixelSize/2)

	local maxSize = self.m_info.gridPixelSize * 0.8 								-- must be smaller than this
	if text.width > maxSize or #info.textValue > 2 then 							-- if it is greater or 3+ letters
		local scaleReqd = math.min(0.5,maxSize / text.width)						-- work out required size.
		text.xScale, text.yScale = scaleReqd,scaleReqd 								-- and scale text
	end
	if self.m_info.isVerticallyMirrored then 										-- invert upside down
		text.yScale = -text.yScale 
	end
	if self.m_info.isHorizontallyMirrored then 										-- left to right
		text.xScale = -text.xScale 
	end
	self.m_group.alpha = 0 															-- can't be seen initially
	self:changeBackground()															-- pick random background
	self:tag("piece")																-- tag as piece
	self.m_group:addEventListener("tap",self)										-- listen for taps.
end 

function Piece:destructor()
	self.m_group:removeEventListener("tap",self)									-- remove event listener
	self.m_group:removeSelf() 														-- remove object
	self.m_info = nil self.m_group = nil self.m_piece = nil 						-- clean up
end

function Piece:tap(e)
	if self:isAlive() and not self.m_hasBeenKilled then 							-- if still active.
		if self:isEnabled() then 													-- and it has been enabled
			self:sendMessage("pieceManager","tap",{ index = self.m_index })			-- tapped, send message to manager about this.
		end
	end
end 

function Piece:remove()
	self.m_hasBeenKilled = true 													-- piece no longer alive.
	transition.to(self.m_group, { time = 300, xScale = 0.1, yScale = 0.1, 			-- make it vanish by shrinking to near nothing
		onComplete = function() 													-- at end
			Framework:new("graphics.particle.short", { x = self.m_group.x,y = self.m_group.y, time = 1, emitter = "StarExplosion"})
			self:delete()															-- destroy the piece
		end })
end 

function Piece:move(x,y)
	self.m_currentX,self.m_currentY = x,y 											-- update current position
	local offset = (self.m_info.gridSize + 1) /2 									-- how far off the middle and calculate
	x = (x - offset) * (self.m_info.gridPixelSize + self.m_info.margin) + self.m_info.centre.x
	y = (y - offset) * (self.m_info.gridPixelSize + self.m_info.margin) + self.m_info.centre.y
	transition.cancel(self.m_group)													-- stop any ongoing transitions.
	--self.m_group:toFront() 															-- move moving pieces to the front
	self.m_inMotion = true 															-- mark as in progress so we don't accept any more moves
	transition.to(self.m_group, { time = 900, alpha = 1, x = x, y = y, 				-- and move
								onComplete = function() self.m_inMotion = false end })
end

Piece.backgroundList = { 															-- possible background colours
	{ 0,0,0 }, { 0,0,1 }, { 0,0.5,0 }, { 1,0,0 }, { 1,0.5,0 }, { 0.5,0.5,0.5 }, {160/255,82/255,45/255}
}

function Piece:changeBackground()
	if self.m_hasBeenKilled then return end 										-- don't change if going
	local n = math.random(#Piece.backgroundList)									-- pick a colour
	local col = Piece.backgroundList[n]
	self.m_piece:setFillColor(col[1],col[2],col[3])									-- and set it
end

function Piece:onMessage(sender,name,body)
	if name == "move" then 															-- received move instruction.
		if self:isAlive() and not self.m_hasBeenKilled and not self.m_inMotion then -- if alive, not been killed and not moving
			if self.m_currentX == body.fromX and self.m_currentY == body.fromY then -- and is this cell 
				self:move(body.toX,body.toY) 										-- move to this other cell
			end
		end 
	end 
end

