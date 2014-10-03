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
	if info.score > 0 then
		Framework.fw.highScoreTable:add(info.score, { difficulty = info.difficulty }) 			-- put into high score table
	end
	print("NOTE: insert into high score table disabled.")
	local fontSize = display.contentWidth / 8 													-- size of fonts.
	local msg = (("00000"..info.score):sub(-6)) .. " (" .. math.floor(info.difficulty) .. " %)" -- put up current score.
	if info.score == 0 then msg = "TIME UP !" end
	local txt = display.newBitmapText(self.m_group,msg,display.contentWidth / 2, info.space + fontSize, "badabb", fontSize * 1.4)
	txt:setModifier(FontManager.Modifiers.SimpleCurveModifier:new(nil,nil,0.4,nil)):animate(3):setTintColor(1,1,0)
	local y = info.space + fontSize * 2.2
	local n = 1
	while y < display.contentHeight-fontSize do 
		display.newBitmapText(self.m_group,n..".",display.contentWidth * 0.2, y, "badabb",fontSize):setTintColor(1,0.5,0)
		local score,data = Framework.fw.highScoreTable:get(n)
		if score > 0 then
			display.newBitmapText(self.m_group,("00000"..score):sub(-6),display.contentWidth * 0.47,y,"badabb",fontSize):setTintColor(0,1,0)
			display.newBitmapText(self.m_group,(data.difficulty or 100) .. "%",display.contentWidth * 0.8,y,"badabb",fontSize):setTintColor(0,0.5,1)
		end
		y = y + fontSize
		n = n + 1
	end
end 

function HighScoreScene:destructor() 
	self.m_group:removeSelf() 																	-- remove graphics
	self.m_group = nil 
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

