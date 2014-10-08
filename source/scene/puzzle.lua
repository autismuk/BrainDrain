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
require("utils.text")

--- ************************************************************************************************************************************************************************
--//									This scene is the creator for the actual game scene background - mosaic and timer bar
--- ************************************************************************************************************************************************************************

local PuzzleScene = Framework:createClass("scene.puzzle.scenebackground","system.controllable")

function PuzzleScene:constructor(info)
	self.m_group = display.newGroup()															-- group for all graphic objects
	local background = display.newRect(self.m_group,0,info.headerSpace,							-- mosaic background
						display.contentWidth,display.contentHeight-info.headerSpace)
	background.anchorX,background.anchorY = 0,0 												-- tile it.
	display.setDefault("textureWrapX","repeat")
	display.setDefault("textureWrapY","repeat")
	background.fill = { type = "image", filename = "images/mosaicb.jpg" }
	background.fill.scaleX,background.fill.scaleY = 0.2,0.15

	local frame = display.newRoundedRect(self.m_group,											-- timer bar background
						display.contentWidth * 0.2,display.contentHeight * 0.92,
						display.contentWidth * 0.6,display.contentHeight * 0.05,
						display.contentHeight * 0.05/2)
	frame.anchorX,frame.anchorY = 0,0.5
	frame:setFillColor(0,0.5,0.7)
	
	self.m_timerBar = display.newRoundedRect(self.m_group,										-- timer bar inner
						display.contentWidth * 0.2,display.contentHeight * 0.92,
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

--// 	Set the progress bar position
--//	@percent 	[number]		percentage used 0..100

function PuzzleScene:setProgressBar(percent)
	percent = math.max(0,math.min(percent,100)) 												-- force into range
	self.m_timerBar.width = self.m_TimerBarFullWidth * (percent / 100 * 0.90 + 0.12) 			-- set bar width accordingly.
end

--//	Tidy up

function PuzzleScene:destructor() 
	self.m_group:removeSelf() 																	-- remove graphics
	self.m_group = nil self.m_timerBar = nil
end 

--//	Get display objects for this scene

function PuzzleScene:getDisplayObjects() return { self.m_group } end

--//	Handle enterFrame event
--//	@dt 	[number]		delta time

function PuzzleScene:onEnterFrame(dt)
	if not self:isEnabled() then return end 													-- timer only when started as this scene object is controllable
	self.m_elapsedTime = math.min(self.m_elapsedTime + dt, self.m_totalTime)					-- update time and timer display
	self:setProgressBar(self.m_elapsedTime * 100 / self.m_totalTime) 							
	if self.m_elapsedTime >= self.m_totalTime then 												-- run out of time
		self:sendMessage("puzzleSceneManager","complete",{ completed = false })					-- tell the puzzle scene manager
		self:tag("-enterFrame")																	-- stop the clock
	end
end 

--//	Get the number of seconds remaining, and stop the clock.
--//	@return 	[number]	number of unused seconds on the clock.

function PuzzleScene:getSecondsRemaining()
	self:tag("-enterFrame")																		-- stop the clock
	return math.floor(math.max(self.m_totalTime - self.m_elapsedTime,0))						-- return unused seconds.
end

--- ************************************************************************************************************************************************************************
--//															This class manages the puzzle scene
--- ************************************************************************************************************************************************************************

local PuzzleSceneManager = Framework:createClass("scene.puzzle","game.sceneManager")

--//	Before opening a main scene, create it.

function PuzzleSceneManager:preOpen(manager,data,resources)
	self:applyDefaults(data)																	-- get default values if none others provided
	self.m_difficulty = self:calculateDifficulty(data) 											-- calculate difficulty as percentage
	local scene = Framework:new("game.scene") 													-- create a new scene

	scene.m_advertObject = scene:new("ads.admob",ApplicationDescription.admobIDs)				-- create a new advert object
	data.headerSpace = scene.m_advertObject:getHeightAfterGap() 								-- get the advert object height
	scene:new("scene.puzzle.scenebackground",data)												-- create the background objects.

	scene:new("control.audio", { r = 0,g = 0, b = 1 })											-- add an audio control and a home button
	scene:new("control.home", { x = 90, r = 0, g = 0, b = 1, listener = self, message = "abandon" })

	local margin = display.contentWidth / 64 													-- margin required in game area
	local gameArea = { x = margin, y = data.headerSpace+margin, 								-- work out game area.
											width = display.contentWidth - margin * 2 }
	gameArea.height = display.contentHeight * 0.89 - gameArea.y 								-- work out height
	data.rectangle = gameArea 																	-- put in the data structure so it knows the game space
	scene:new("game.piece.manager",data)														-- create piece manager, this will start the game

	scene:new("control.text", { text = "GET READY", font = "badabb", alpha = 1, 				-- add the 'get ready' text
								tint = { r = 1,g = 1,b = 0} ,
								transition = { time = 1500, alpha = 1 ,
									onComplete = function(item) 								-- transition it visible
									timer.performWithDelay(1000,function() 						-- hold it briefly.
											self:setControllableEnabled(true) 					-- everything on
											transition.to(item, { time = 750, y = -80, 
																  alpha = 0.1, 
																  onComplete = function() item:removeSelf() end })
											end)
									 end }
	})
	self:tag("puzzleSceneManager")																-- tag it (may be already tagged as such, doesn't matter.)
	scene:new("audio.music") 																	-- start the background music.
	return scene
end 

--//	Handle Messages
--//	@sender 	[object]		sender
--//	@name 		[string]		message name
--//	@body 		[table]			anything else

function PuzzleSceneManager:onMessage(sender,message,body)

	if message == "iconbutton" then 															-- there is only one icon button message
		self:cancelTimer("complete")															-- cancel any pending completions (because this object exists throughout)
		self:performGameEvent("exit",{}) 														-- go back to the main setup screen
		return 
	end

	assert(message == "complete")																-- check it is the 'complete' message
	body.baseScore = Framework.fw.timer:getSecondsRemaining()									-- copy in the body score
	if not body.completed then body.baseScore = 0 end 											-- score nothing if did not complete.
	body.difficulty = self.m_difficulty 														-- and the difficulty level.
	body.score = math.floor(body.baseScore * body.difficulty / 100)	* 10						-- difficulty adjusted score.
	self:setControllableEnabled(false)															-- turn off controllables.

	local text = "TIME UP !" 																	-- what do we put
	if body.completed then text = "GOAL IN !" end 

	self:getScene():new("control.text", { 														-- add that text banner flyout.
						text = text, 
						x = display.contentWidth /2 , y = -40,
						font = "badabb",
						tint = { r = 1, g = 1 , b = 0},
						transition = { time = 2000, y = display.contentHeight/2, transition = easing.outBounce,
									   onComplete = function(obj) end	}						-- stops auto deletion
						})

	self.m_result = body 																		-- save the output in a reference so we can use it on the timer.
	self:addSingleTimer(4,"complete") 															-- send it in four seconds, allow time for control.text to display etc.
end 

--//	Handle timer messages
--//	@tag 	[string]	associate tag

function PuzzleSceneManager:onTimer(tag)
	self:performGameEvent("win",self.m_result)													-- after a time, switch to high score with the saved data
end 

--//	Get the defaults for the setup values
--//	@def 	[table]		constructor with game setup values

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

--//	Given the setup values, calculate how hard the level is
--//	@setup 	[table]	table of setup values
--//	@return [number] difficulty as a percentage from about 40-280

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
