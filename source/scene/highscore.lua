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

local HighScoreScene = Framework:createClass("scene.highscore.main")

function HighScoreScene:constructor(info)
	self.m_group = display.newGroup()
	self.m_textList = {}
	if info.score > 0 then
		Framework.fw.highScoreTable:add(info.score, { difficulty = info.difficulty }) 			-- put into high score table
	end
	print("NOTE: insert into high score table disabled.")
	local fontSize = display.contentWidth / 8 													-- size of fonts.
	local msg = (("00000"..info.score):sub(-6)) .. " (" .. math.floor(info.difficulty or 100) .. " %)" -- put up current score.
	if info.score == 0 then msg = "TIME UP !" end
	local txt = display.newBitmapText(self.m_group,msg,display.contentWidth / 2, info.space + fontSize, "badabb", fontSize * 1.4)
	txt:setModifier(FontManager.Modifiers.SimpleCurveModifier:new(nil,nil,0.4,nil)):animate(3):setTintColor(1,1,0)
	self.m_textList[#self.m_textList+1] =txt
	local y = info.space + fontSize * 2.2 														-- put up rest of score table
	local n = 1
	while y < display.contentHeight-fontSize do 
		local newGroup = display.newGroup()
		self.m_group:insert(newGroup)
		txt = display.newBitmapText(newGroup,n..".",display.contentWidth * 0.2, y, "badabb",fontSize):setTintColor(1,0.5,0)
		self.m_textList[#self.m_textList+1] =txt
		local score,data = Framework.fw.highScoreTable:get(n)
		if score > 0 then
			txt = display.newBitmapText(newGroup,("00000"..score):sub(-6),display.contentWidth * 0.47,y,"badabb",fontSize):setTintColor(0,1,0)
			self.m_textList[#self.m_textList+1] =txt
			txt = display.newBitmapText(newGroup,(data.difficulty or 100) .. "%",display.contentWidth * 0.8,y,"badabb",fontSize):setTintColor(0,0.5,1)
			self.m_textList[#self.m_textList+1] =txt
		end
		newGroup.alpha = 0 																		-- roll it in.
		timer.performWithDelay(n * 400,function() transition.to(newGroup,{ time = 1000, alpha = 1 }) end)
		y = y + fontSize
		n = n + 1
	end

	self.m_tapArea = display.newRect(self.m_group,0,0,display.contentWidth,display.contentHeight)
	self.m_tapArea.anchorX,self.m_tapArea.anchorY = 0,0 self.m_tapArea.alpha = 0.01
	self.m_tapArea:addEventListener("tap",self)
end 

function HighScoreScene:destructor() 
	for _,ref in ipairs(self.m_textList) do ref:removeSelf() end
	self.m_tapArea:removeEventListener("tap",self)
	self.m_group:removeSelf() 																	-- remove graphics
	self.m_group = nil self.m_tapArea = nil self.m_textList = nil
end 

function HighScoreScene:tap(event)
	self:performGameEvent("next")
end 

function HighScoreScene:getDisplayObjects() return { self.m_group } end


local HighScoreSceneManager = Framework:createClass("scene.highscore","game.sceneManager")

--//	Before opening a main scene, create it.

function HighScoreSceneManager:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")
	scene.m_advertObject = scene:new("ads.admob",ApplicationDescription.admobIDs)				-- create a new advert object
	local header = scene.m_advertObject:getHeight() 											-- get the advert object heigh
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

