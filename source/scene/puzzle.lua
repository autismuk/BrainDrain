--- ************************************************************************************************************************************************************************
---
---				Name : 		puzzle.lua
---				Purpose :	Puzzle (Main) scene
---				Updated:	26 September 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("utils.buttons")
require("game.piecemanager")
require("utils.fontmanager")

local PuzzleScene = Framework:createClass("scene.puzzle.scenebackground","system.controllable")

function PuzzleScene:constructor(info)
	self.m_group = display.newGroup()															-- group for all graphic objects
	local background = display.newRect(0,info.headerSpace,
						display.contentWidth,display.contentHeight-info.headerSpace)
	background.anchorX,background.anchorY = 0,0
	display.setDefault("textureWrapX","repeat")
	display.setDefault("textureWrapY","repeat")
	background.fill = { type = "image", filename = "images/mosaicb.jpg" }
	background.fill.scaleX,background.fill.scaleY = 0.2,0.15
	local frame = display.newRoundedRect(self.m_group,
						display.contentWidth * 0.2,display.contentHeight * 0.91,
						display.contentWidth * 0.6,display.contentHeight * 0.05,
						12)
	frame.anchorX,frame.anchorY = 0,0
	frame:setFillColor(0,0.5,0.7)
	
	self.m_timerBar = display.newRoundedRect(self.m_group,
						display.contentWidth * 0.2,display.contentHeight * 0.91,
						display.contentWidth * 0.6,display.contentHeight * 0.05,
						12)
	self.m_timerBar.anchorX,self.m_timerBar.anchorY = 0,0
	self.m_timerBar:setFillColor(0,0,1)
	self.m_TimerBarFullWidth = self.m_timerBar.width
	self:setProgressBar(0)

	local t = display.newBitmapText(self.m_group,"GET READY !",160,240,"badabb",88)
	t:setTintColor(1,0,0)
	timer.performWithDelay(4000,function() self:setControllableEnabled(true) t:removeSelf() end) 			
	print("Temporary, done when the Get Ready ! message goes")

end 

--//	Tidy up

function PuzzleScene:setProgressBar(percent)
	percent = math.max(0,math.min(percent,100))
	self.m_timerBar.width = self.m_TimerBarFullWidth * (percent / 100 * 0.88 + 0.12)
end

function PuzzleScene:destructor() 
	self.m_group:removeSelf() 																	-- remove graphics
	self.m_group = nil self.m_timerBar = nil
end 

function PuzzleScene:tap(event)
	self:performGameEvent("start") 																-- and run it
end 

function PuzzleScene:getDisplayObjects() return { self.m_group } end


local PuzzleSceneManager = Framework:createClass("scene.puzzle","game.sceneManager")

--//	Before opening a main scene, create it.

function PuzzleSceneManager:preOpen(manager,data,resources)
	self:applyDefaults(data)
	local scene = Framework:new("game.scene")
	local adIDs = { ios = "ca-app-pub-8354094658055499/1659828014", 							-- admob identifiers.
					android = "ca-app-pub-8354094658055499/7706361613" }
	scene.m_advertObject = scene:new("ads.admob",adIDs)											-- create a new advert object
	data.headerSpace = scene.m_advertObject:getHeight() 										-- get the advert object height
	scene:new("scene.puzzle.scenebackground",data)												-- create the background objects.
	scene:new("control.audio", { r = 0,g = 0, b = 1 })											-- add an audio control.
	scene:new("control.home", { x = 82, r = 0, g = 0, b = 1, listener = self, message = "home" })
	local margin = display.contentWidth / 64 													-- margin
	local gameArea = { x = margin, y = data.headerSpace+margin, 								-- work out game area.
											width = display.contentWidth - margin * 2 }
	gameArea.height = display.contentHeight * 0.89 - gameArea.y
	data.rectangle = gameArea 																	-- put in the data structure
	
	scene:new("game.piece.manager",data)														-- create piece manager, this will start the game
	return scene
end 

function PuzzleSceneManager:applyDefaults(def)
	def.margin = def.margin or 4
	def.gridSize = def.gridSize or 5
	def.timeAllowed = def.timeAllowed or (def.gridSize * def.gridSize * 5)
	def.isReversed = def.isReversed or false 
	def.isShuffling = def.isShuffling or false 
	def.isRotating = def.isRotating or false 
	def.isChangingBackground = def.isChangingBackground or false 
	def.isVerticallyMirrored = def.isVerticallyMirrored or false 
	def.isHorizontallyMirrored = def.isHorizontallyMirrored or false 
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		26-Sep-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

