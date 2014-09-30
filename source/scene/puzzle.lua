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
require("utils.music")
require("utils.admob")

local PuzzleScene = Framework:createClass("scene.puzzle.scenebackground","system.controllable")

function PuzzleScene:constructor(info)
	self.m_group = display.newGroup()															-- group for all graphic objects
	local background = display.newRect(self.m_group,0,info.headerSpace,							-- mosaic background
						display.contentWidth,display.contentHeight-info.headerSpace)
	background.anchorX,background.anchorY = 0,0
	display.setDefault("textureWrapX","repeat")
	display.setDefault("textureWrapY","repeat")
	background.fill = { type = "image", filename = "images/mosaicb.jpg" }
	background.fill.scaleX,background.fill.scaleY = 0.2,0.15
	local frame = display.newRoundedRect(self.m_group,											-- timer bar background
						display.contentWidth * 0.2,display.contentHeight * 0.95,
						display.contentWidth * 0.6,display.contentHeight * 0.05,
						display.contentHeight * 0.05/2)
	frame.anchorX,frame.anchorY = 0,0.5
	frame:setFillColor(0,0.5,0.7)
	
	self.m_timerBar = display.newRoundedRect(self.m_group,										-- timer bar
						display.contentWidth * 0.2,display.contentHeight * 0.95,
						display.contentWidth * 0.6,display.contentHeight * 0.05,
						display.contentHeight * 0.05/2)
	self.m_timerBar.anchorX,self.m_timerBar.anchorY = 0,0.5
	self.m_timerBar:setFillColor(0,0,1)
	self.m_TimerBarFullWidth = self.m_timerBar.width
	self:setProgressBar(0) 																		-- reset progress bar
	self.m_elapsedTime = 0 																		-- current and final time
	self.m_totalTime = info.timeAllowed
	self:tag("enterFrame")																		-- gets enterFrame
	self:name("timer")																			-- name it 'timer'
end 

--//	Tidy up

function PuzzleScene:setProgressBar(percent)
	percent = math.max(0,math.min(percent,100))
	self.m_timerBar.width = self.m_TimerBarFullWidth * (percent / 100 * 0.90 + 0.12)
end

function PuzzleScene:destructor() 
	self.m_group:removeSelf() 																	-- remove graphics
	self.m_group = nil self.m_timerBar = nil
end 

function PuzzleScene:getDisplayObjects() return { self.m_group } end

function PuzzleScene:onEnterFrame(dt)
	if not self:isEnabled() then return end 													-- timer only when started
	self.m_elapsedTime = math.min(self.m_elapsedTime + dt, self.m_totalTime)					-- update time and timer display
	self:setProgressBar(self.m_elapsedTime * 100 / self.m_totalTime)
	if self.m_elapsedTime >= self.m_totalTime then 												-- run out of time
		self:sendMessage("puzzleSceneManager","complete",{ completed = false })					-- tell the puzzle scene manager
		self:tag("-enterFrame")																	-- stop the clock
	end
end 

function PuzzleScene:getSecondsRemaining()
	self:tag("-enterFrame")																		-- stop the clock
	return math.floor(math.max(self.m_totalTime - self.m_elapsedTime,0))
end

local TextScene = Framework:createClass("scene.puzzle.text")

function TextScene:constructor()
	local txt = display.newBitmapText("GET READY !", 								-- put up 'get ready'
								display.contentWidth/2,display.contentHeight/2,"badabb",display.contentWidth/4) 			
	txt:setTintColor(1,1,0) txt.alpha = 0 														-- yellow and hidden
	transition.to(txt, { time = 1500, alpha = 1, onComplete = function() 						-- transition it visible
		timer.performWithDelay(1000,function() 													-- hold
			self:setControllableEnabled(true) 													-- everything on
			transition.to(txt, { time = 750, y = -80, alpha = 0.1, onComplete = function() 		-- whizz off the screen
				txt:removeSelf() 																-- and delete text object
			end })
		end)
	end })
	self.m_text = txt
end

function TextScene:destructor()
	self.m_text:removeSelf() 
	self.m_text = nil 
end 

function TextScene:getDisplayObjects()
	return { self.m_text }
end 

local PuzzleSceneManager = Framework:createClass("scene.puzzle","game.sceneManager")

--//	Before opening a main scene, create it.

function PuzzleSceneManager:preOpen(manager,data,resources)
	self:applyDefaults(data)																	-- defaults
	self.m_difficulty = self:calculateDifficulty(data) 											-- calculate difficulty as percentage
	local scene = Framework:new("game.scene")
	local adIDs = { ios = "ca-app-pub-8354094658055499/1659828014", 							-- admob identifiers.
					android = "ca-app-pub-8354094658055499/7706361613" }
	scene.m_advertObject = scene:new("ads.admob",adIDs)											-- create a new advert object
	data.headerSpace = scene.m_advertObject:getHeight() 										-- get the advert object height

	scene:new("scene.puzzle.scenebackground",data)												-- create the background objects.
	scene:new("control.audio", { r = 0,g = 0, b = 1 })											-- add an audio control.
	scene:new("control.home", { x = 90, r = 0, g = 0, b = 1, listener = self, message = "abandon" })
	local margin = display.contentWidth / 64 													-- margin
	local gameArea = { x = margin, y = data.headerSpace+margin, 								-- work out game area.
											width = display.contentWidth - margin * 2 }
	gameArea.height = display.contentHeight * 0.89 - gameArea.y
	data.rectangle = gameArea 																	-- put in the data structure
	
	scene:new("game.piece.manager",data)														-- create piece manager, this will start the game
	scene:new("scene.puzzle.text")
	self:tag("puzzleSceneManager")																-- tag it.
	scene:new("audio.music")
	return scene
end 

function PuzzleSceneManager:onMessage(sender,message,body)
	if message == "iconbutton" then 															-- there is only one icon button message
		self:performGameEvent("exit",{}) 														-- so if clicked go back to the main screen
		return 
	end
	body.baseScore = Framework.fw.timer:getSecondsRemaining()									-- copy in the body score
	if not body.completed then body.baseScore = 0 end 											-- score nothing if did not complete.
	body.difficulty = self.m_difficulty 														-- and the difficulty level.
	body.score = math.floor(body.baseScore * body.difficulty / 100)								-- difficulty adjusted score.
	self:setControllableEnabled(false)															-- turn off controllables.
	local text = "TIME UP !"
	if body.completed then text = "GOAL IN !" end 
	local group = self:getScene():getContainer() 												-- get current scene's container
	text = display.newBitmapText(group,text, 													-- put up text
									display.contentWidth/2,-40,"badabb",display.contentWidth/4)
	text:setTintColor(0,1,1)
	transition.to(text, { time = 2000, y = display.contentHeight / 2, 							-- bounce it in.
											transition = easing.outBounce })
	timer.performWithDelay(4000,function() self:performGameEvent("win",body) end) 				-- after a time, switch to high score.
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

function PuzzleSceneManager:calculateDifficulty(setup)
	local diff = { nil, 40,60,100,130,160,200 }													-- difficulty for 1..7
	diff = diff[setup.gridSize]																	-- get the difficulty
	if setup.isReversed then diff = diff + 25 end 												-- 25% for backwards
	if setup.isShuffling then diff = diff + 20 end 												-- 20% for row shuffling
	if setup.isRotating then diff = diff + 30 end 												-- 30% for rotating frame
	if setup.isChangingBackground then diff = diff + 10 end 									-- 10% for changing background
	if setup.isVerticallyMirrored then diff = diff + 25 end 									-- 25% for vertical flip
	if setup.isHorizontallyMirrored then diff = diff + 20 end 									-- 20% for horizontal flip
	return diff
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		26-Sep-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

