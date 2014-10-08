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

--- ************************************************************************************************************************************************************************
--//													This class rotates through a set of predefined options
--- ************************************************************************************************************************************************************************

local SetupSelector = Framework:createClass("scene.setup.selector")

--//	Constructor. 
--//	@info [table]	name is the parameter in <docstore>.settings, options is an array of options, default the default value, group where it's going

function SetupSelector:constructor(info)
	self.m_info = info 																-- save setup
	local docStore = Framework.fw.documentStore:access().settings  					-- access the document store
	docStore[info.name] = docStore[info.name] or info.default  						-- put the default in if necessary
	Framework.fw.documentStore:update() 											-- update the document store
	self.m_button = display.newRoundedRect(info.group,display.contentWidth/2,		-- create the selector frame
					info.y,display.contentWidth * 0.93, display.contentWidth/10,display.contentWidth/20)
	self.m_button:setFillColor(0.4,0,0) self.m_button.strokeWidth = 2
	self.m_text = display.newBitmapText(info.group, 								-- create the selector text
					self.m_info.options[docStore[info.name]]:upper(),display.contentWidth/2,info.y,"badabb",display.contentWidth/10)
	self.m_text:setTintColor(1,1,0)
	self.m_button:addEventListener("tap",self) 										-- add tap event.
end

--//	Tidy up

function SetupSelector:destructor()
	self.m_button:removeEventListener("tap",self)
	self.m_text:removeSelf() self.m_button:removeSelf()
end 

--//	Handle tap events

function SetupSelector:tap()
	local docStore = Framework.fw.documentStore:access().settings 					-- access document store
	local n = (docStore[self.m_info.name] or self.m_info.default) + 1 				-- get to next value
	if n > #self.m_info.options then n = 1 end  									-- wrap round past end
	docStore[self.m_info.name] = n 													-- write back
	self.m_text:setText(self.m_info.options[n]:upper()) 							-- update text object
	Framework.fw.documentStore:update() 											-- update the document store
	return true
end 

--- ************************************************************************************************************************************************************************
--	 																		Edit Button
--- ************************************************************************************************************************************************************************

local EditButton = Framework:createClass("control.user.edit","control.abstract")

function EditButton:draw(colour)
	local img = display.newImage(self.m_group,"images/edit.png",0,0)
	img.width = 50 img.height = 50
end 

--- ************************************************************************************************************************************************************************
--//															Scene responsible for  setup scene
--- ************************************************************************************************************************************************************************

local SetupScene = Framework:createClass("scene.setup.main")

SetupScene.selectors = { 															-- table of items for selectors

	{ name = "items", options = { "numbers","letters","spaced numbers","spaced letters",
											"three letter words","top 500 english words","user defined (sequential)", "user defined (spaces)"}, default = 1 },
	{ name = "gridsize", options = { "2 x 2 Grid","3 x 3 Grid","4 x 4 Grid","5 x 5 Grid","6 x 6 Grid","7 x 7 Grid" }, default = 4 },
	{ name = "reversed", options = { "Do it forwards","Do it backwards" }, default = 1},
	{ name = "sliding", options = { "Don't slide the tiles", "Slide the tiles"}, default = 1 },
	{ name = "rotating", options = { "Don't rotate the tiles","Rotate the tiles"}, default = 1 },
	{ name = "chback", options = { "Don't change the background","Change the background"}, default = 1},
	{ name = "vertmirror", options = { "Right way up","Show upside down"}, default = 1},
	{ name = "horizmirror", options = { "Right way round","Back to front"}, default = 1},
	{ name = "hard", options = { "Don't shuffle a lot","Shuffle a lot"}, default = 1} 
}

--//	Constructor for setup 
--//	@info 	[table]		constructor information (top,bottom)

function SetupScene:constructor(info)
	self.m_group = display.newGroup() 												-- group for graphic objects.
	local documentHandle = Framework.fw.documentStore:access()						-- access document store
	documentHandle.settings = documentHandle.settings or {} 						-- create settings table if does not exist
	self.m_itemCount = #SetupScene.selectors  										-- number of items.
	self.m_selectors = {} 															-- array of selector objects

	for i = 1,self.m_itemCount do 													-- for each control option
		local y = (info.bottom - info.top) / (self.m_itemCount) * (i + 0.8) 		-- work out where it goes
		local sel = SetupScene.selectors[i] 										-- reference its ssetup data
		self.m_selectors[i] = Framework:new("scene.setup.selector", 				-- create a selector
												{ y = y, name = sel.name, options = sel.options, default = sel.default, group = self.m_group })
	end
end 

function SetupScene:destructor() 
	self.m_group:removeSelf() 														-- remove graphics
	for i = 1,self.m_itemCount do self.m_selectors[i]:delete() end 					-- delete all selector objects
	self.m_group = nil  self.m_selectors = nil 										-- null references
end 

function SetupScene:getDisplayObjects() return { self.m_group } end

--- ************************************************************************************************************************************************************************
--//																	Scene Manager Class
--- ************************************************************************************************************************************************************************

local SetupSceneManager = Framework:createClass("scene.setup","game.sceneManager")

--//	Before opening a main scene, create it.

function SetupSceneManager:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene") 													-- create a new scene
	scene.m_advertObject = scene:new("ads.admob",ApplicationDescription.admobIDs)				-- create a new advert object
	local header = scene.m_advertObject:getHeightAfterGap() 									-- get the advert object heigh
	scene:new("scene.setup.main",{ top = header, bottom = display.contentHeight * 0.85 }) 		-- set up the setup scene
	scene:new("control.rightarrow", { x = 90, r = 1, g = 0.5, b = 0, 							-- add right arrow to go to game.
													listener = self, message = "start" })
	scene:new("control.user.edit", { x = 10,listener = self,message = "edit" })
	self.m_factorySource = scene:new("game.factorySource",{})									-- add a factory source non visible
	return scene
end 

--//	@sender 	[object]		sender
--//	@name 		[string]		message name
--//	@body 		[table]			anything else

function SetupSceneManager:onMessage(sender,name,body)
	assert(name == "iconbutton")																-- check it's an icon button, it should be.

	if body.type == "edit" then 																-- if it's the edit button, then go to the edit scene.
		self:performGameEvent("edit")
		return 
	end

	assert(body.type == "start")																-- check it's the start message
	local setup = Framework.fw.documentStore:access().settings 									-- access settings

	local descriptor = { 	gridSize = setup.gridsize + 1,										-- copy settings into descriptor table.
			 		   		isReversed = (setup.reversed == 2), 								-- convert from index in options lists to real working values
			 		   		isShuffling = (setup.sliding == 2), 
			 		   		isRotating = (setup.rotating == 2), 
			 		   		isChangingBackground = (setup.chback == 2), 
			 		   		isVerticallyMirrored = (setup.vertmirror == 2), 
			 		   		isHorizontallyMirrored = (setup.horizmirror == 2), 
			 		   		isHard = (setup.hard == 2) }

	descriptor.factory = self.m_factorySource:getFactory(setup.items) 							-- use the factory source to get the item factory

	if descriptor.gridSize * descriptor.gridSize <= descriptor.factory:count() then 			-- if enough then start game using the descriptor to specify it
		self:performGameEvent("next",descriptor)
	else  																						-- otherwise, beep and don't change scene.
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

