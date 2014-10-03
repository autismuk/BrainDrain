--- ************************************************************************************************************************************************************************
---
---				Name : 		setup.lua
---				Purpose :	Set up Scene
---				Updated:	3 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("utils.document")
require("utils.fontmanager")
require("game.factory")

local SetupSelector = Framework:createClass("scene.setup.selector")

function SetupSelector:constructor(info)
	self.m_info = info
	local docStore = Framework.fw.documentStore:access().settings 
	docStore[info.name] = docStore[info.name] or info.default 
	self.m_button = display.newRoundedRect(info.group,display.contentWidth/2,info.y,display.contentWidth * 0.93, display.contentWidth/10,display.contentWidth/20)
	self.m_button:setFillColor(0.4,0,0) self.m_button.strokeWidth = 2
	self.m_text = display.newBitmapText(info.group,self.m_info.options[docStore[info.name]]:upper(),display.contentWidth/2,info.y,"badabb",display.contentWidth/10)
	self.m_text:setTintColor(1,1,0)
	self.m_button:addEventListener("tap",self)
end

function SetupSelector:destructor()
	self.m_button:removeEventListener("tap",self)
	self.m_text:removeSelf() self.m_button:removeSelf()
end 

function SetupSelector:tap()
	local docStore = Framework.fw.documentStore:access().settings 
	local n = (docStore[self.m_info.name] or self.m_info.default) + 1
	if n > #self.m_info.options then n = 1 end 
	docStore[self.m_info.name] = n 
	self.m_text:setText(self.m_info.options[n]:upper())
	Framework.fw.documentStore:update()
	return true
end 


local SetupScene = Framework:createClass("scene.setup.main")

SetupScene.selectors = {

	{ name = "items", options = { "numbers","letters","spaced numbers","three letter words","top 500 english words","user defined"}, default = 1 },
	{ name = "gridsize", options = { "2 x 2 Grid","3 x 3 Grid","4 x 4 Grid","5 x 5 Grid","6 x 6 Grid","7 x 7 Grid" }, default = 4 },
	{ name = "reversed", options = { "Do it forwards","Do it backwards" }, default = 1},
	{ name = "sliding", options = { "Don't slide the tiles", "Slide the tiles"}, default = 1 },
	{ name = "rotating", options = { "Don't rotate the tiles","Rotate the tiles"}, default = 1 },
	{ name = "chback", options = { "Don't change the background","Change the background"}, default = 1},
	{ name = "vertmirror", options = { "Right way up","Show upside down"}, default = 1},
	{ name = "horizmirror", options = { "Right way round","Back to front"}, default = 1},
	{ name = "hard", options = { "Don't shuffle a lot","Shuffle a lot"}, default = 1} 
}

function SetupScene:constructor(info)
	self.m_group = display.newGroup() 															-- group for graphic objects.
	local documentHandle = Framework.fw.documentStore:access()									-- access document store
	documentHandle.settings = documentHandle.settings or {} 									-- create settings table if does not exist
	self.m_itemCount = #SetupScene.selectors  													-- number of items.
	self.m_selectors = {}
	for i = 1,self.m_itemCount do 																-- for each control option
		local y = (info.bottom - info.top) / (self.m_itemCount) * (i + 0.8) 					-- work out where it goes
		local sel = SetupScene.selectors[i]
		self.m_selectors[i] = Framework:new("scene.setup.selector", { y = y, name = sel.name, options = sel.options, default = sel.default, group = self.m_group })
	end
end 

function SetupScene:destructor() 
	self.m_group:removeSelf() 																	-- remove graphics
	for i = 1,self.m_itemCount do self.m_selectors[i]:delete() end 
	self.m_group = nil  self.m_selectors = nil
end 

function SetupScene:getDisplayObjects() return { self.m_group } end


local SetupSceneManager = Framework:createClass("scene.setup","game.sceneManager")

--//	Before opening a main scene, create it.

function SetupSceneManager:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")
	scene.m_advertObject = scene:new("ads.admob",ApplicationDescription.admobIDs)				-- create a new advert object
	local header = scene.m_advertObject:getHeight() 											-- get the advert object heigh
	scene:new("scene.setup.main",{ top = header, bottom = display.contentHeight * 0.85 })
	scene:new("control.rightarrow", { x = 90, r = 1, g = 0.5, b = 0, listener = self, message = "start" })
	return scene
end 

function SetupSceneManager:onMessage()

	local setup = Framework.fw.documentStore:access().settings 

	local descriptor = { 	gridSize = setup.gridsize + 1,
			 		   		isReversed = (setup.reversed == 2), 
			 		   		isShuffling = (setup.sliding == 2), 
			 		   		isRotating = (setup.rotating == 2), 
			 		   		isChangingBackground = (setup.chback == 2), 
			 		   		isVerticallyMirrored = (setup.vertmirror == 2), 
			 		   		isHorizontallyMirrored = (setup.horizmirror == 2), 
			 		   		isHard = (setup.hard == 2) }

	descriptor.factory = self:getScene():new("game.factorySource"):getFactory(1)

	if descriptor.gridSize * descriptor.gridSize <= descriptor.factory:count() then 
		self:performGameEvent("next",descriptor)
	else 
		self:playSound("wrong")
	end
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		3-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

