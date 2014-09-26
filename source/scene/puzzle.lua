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

local PuzzleScene = Framework:createClass("scene.puzzle.scenebackground")

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
	self:setProgressBar(10)
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
	local scene = Framework:new("game.scene")
	local adIDs = { ios = "ca-app-pub-8354094658055499/1659828014", 							-- admob identifiers.
					android = "ca-app-pub-8354094658055499/7706361613" }
	scene.m_advertObject = scene:new("ads.admob",adIDs)											-- create a new advert object
	data.headerSpace = scene.m_advertObject:getHeight() 										-- get the advert object height
	scene:new("scene.puzzle.scenebackground",data)												-- create the background objects.
	scene:new("control.audio", { r = 0,g = 0, b = 1 })											-- add an audio control.
	scene:new("control.home", { x = 82, r = 0, g = 0, b = 1, listener = self, message = "home" })
	return scene
end 


--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		26-Sep-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

