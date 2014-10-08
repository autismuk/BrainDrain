--- ************************************************************************************************************************************************************************
---
---				Name : 		highscore.lua
---				Purpose :	High Score scene
---				Updated:	3 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("utils.highscore")
local FontManager = require("utils.fontmanager")

--- ************************************************************************************************************************************************************************
--//											This scene displays the high score table
--- ************************************************************************************************************************************************************************

local HighScoreScene = Framework:createClass("scene.highscore.main")

--//	Create the high score scene
--//	@info 	[table]		constructor information, score and difficulty.

function HighScoreScene:constructor(info)
	self.m_group = display.newGroup() 															-- group for this scene
	self.m_textList = {} 																		-- array of bitmap text objects
	info.score = info.score or 0 																-- force a default score value of zero.
	if info.score > 0 then 																		-- is there a score ?
		Framework.fw.highScoreTable:add(info.score, { difficulty = info.difficulty }) 			-- put into high score table
	end

	local fontSize = display.contentWidth / 8 													-- size of fonts.
	local msg = (("00000"..info.score):sub(-5)).." ("..math.floor(info.difficulty or 100).." %)"-- text for current score.
	if info.score == 0 then msg = "TIME UP !" end 												-- if time up, then display time up.
	local txt = display.newBitmapText(self.m_group,msg,display.contentWidth / 2, 				-- create and animate that bitmap text showing score/time up
													info.space + fontSize, "badabb", fontSize * 1.4)
	txt:setModifier(FontManager.Modifiers.SimpleCurveModifier:new(nil,nil,0.4,nil)):animate(3):setTintColor(1,1,0)
	self.m_textList[#self.m_textList+1] = txt 													-- store in table

	local y = info.space + fontSize * 2.2 														-- put up rest of score table
	local n = 1
	while y < display.contentHeight-fontSize do 												-- while more space
		local newGroup = display.newGroup() 													-- create a new group for the entry
		self.m_group:insert(newGroup) 															-- put in main group
		txt = display.newBitmapText(newGroup,n..".",display.contentWidth * 0.2, 				-- add score number (e.g. 1,2,3) to it.
														y, "badabb",fontSize):setTintColor(1,0.5,0)
		self.m_textList[#self.m_textList+1] =txt
		local score,data = Framework.fw.highScoreTable:get(n)
		if score > 0 then 																		-- if there is a score for that entry add that text
			txt = display.newBitmapText(newGroup,("00000"..score):sub(-5),display.contentWidth * 0.47,y,"badabb",fontSize):setTintColor(0,1,0)
			self.m_textList[#self.m_textList+1] =txt
			txt = display.newBitmapText(newGroup,(data.difficulty or 100) .. "%",display.contentWidth * 0.8,y,"badabb",fontSize):setTintColor(0,0.5,1)
			self.m_textList[#self.m_textList+1] =txt
		end
		newGroup.alpha = 0 																		-- initially hide it, then make it appear after a period of time.
		timer.performWithDelay(n * 400,function() transition.to(newGroup,{ time = 1000, alpha = 1 }) end)
		y = y + fontSize 																		-- next line 
		n = n + 1 																				-- next score
	end

	self.m_tapArea = display.newRect(self.m_group,0,0,											-- create transparent tap area
											display.contentWidth,display.contentHeight)
	self.m_tapArea.anchorX,self.m_tapArea.anchorY = 0,0 self.m_tapArea.alpha = 0.01
	self.m_tapArea:addEventListener("tap",self) 												-- add listener to it, so can tap anywhere
end 

--//	Tidy up

function HighScoreScene:destructor() 
	for _,ref in ipairs(self.m_textList) do ref:removeSelf() end 								-- physically remove all text items
	self.m_tapArea:removeEventListener("tap",self) 												-- and the tap listener
	self.m_group:removeSelf() 																	-- remove any other graphics
	self.m_group = nil self.m_tapArea = nil self.m_textList = nil 								-- and null out.
end 

--//	Handle tap

function HighScoreScene:tap(event)
	self:performGameEvent("next") 																-- next FSM event goes to setup screen
end 

function HighScoreScene:getDisplayObjects() return { self.m_group } end

--- ************************************************************************************************************************************************************************
--//													Manager for the high score scene
--- ************************************************************************************************************************************************************************

local HighScoreSceneManager = Framework:createClass("scene.highscore","game.sceneManager")

--//	Before opening a main scene, create it.

function HighScoreSceneManager:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene") 													-- new scene
	scene.m_advertObject = scene:new("ads.admob",ApplicationDescription.admobIDs)				-- create a new advert object
	local header = scene.m_advertObject:getHeightAfterGap() 									-- get the advert object heigh
	scene:new("scene.highscore.main",{ score = data.score or 0, difficulty = data.difficulty, space = header })				
	return scene
end 


--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		3-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

