--- ************************************************************************************************************************************************************************
---
---				Name : 		editor.lua
---				Purpose :	User Text Editor Scene
---				Updated:	6 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("game.usertext")
--- ************************************************************************************************************************************************************************
--//															Scene responsible for editor scene
--- ************************************************************************************************************************************************************************

local EditorScene = Framework:createClass("scene.editor.main")

--//	Constructor for setup 
--//	@info 	[table]		constructor information (top,bottom)

function EditorScene:constructor(info)
	self.m_group = display.newGroup() 												-- group for graphic objects.
	local r = display.newRect(self.m_group,0,0,display.contentWidth,display.contentHeight)
	r.anchorX,r.anchorY = 0,0 r:setFillColor(0.4,0.4,0.4)
	self.m_textBox = native.newTextBox(display.contentWidth*0.45, display.contentHeight*0.27,
									   display.contentWidth*0.82,display.contentHeight*0.5)
	self.m_textBox.isEditable = true
	local r2 = display.newRect(self.m_group,display.contentWidth*0.45, display.contentHeight*0.27,
									   display.contentWidth*0.84,display.contentHeight*0.52)
	r2:setFillColor(0,0,0)
	native.setKeyboardFocus(self.m_textBox)

	self.m_textBox.text = Framework.fw.usertext:get().."\nHello world"
end 

function EditorScene:destructor() 
	self.m_group:removeSelf() 														-- remove graphics
	self.m_textBox:removeSelf()
	self.m_group = nil self.m_textBox = nil
end 

function EditorScene:getDisplayObjects() return { self.m_group } end

--- ************************************************************************************************************************************************************************
--//																	Scene Manager Class
--- ************************************************************************************************************************************************************************

local EditorSceneManager = Framework:createClass("scene.editor","game.sceneManager")

--//	Before opening a main scene, create it.

function EditorSceneManager:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene") 													-- create a new scene. Instantiation/Removal is actually done in postOpen
	return scene 																				-- preClose because of the native textBox, which cannot be grouped etc.
end 

function EditorSceneManager:postOpen(manager,data,resources)
	self.m_textScene = self:getScene():new("scene.editor.main",{ }) 							-- set up the setup scene
	self:getScene():new("control.rightarrow", { x = 93,y = 5, r = 1, g = 0.5, b = 0, 			-- add right arrow to go to game.
													listener = self, message = "start" })
end

function EditorSceneManager:preClose(manager,data,resources)
	self.m_textScene:delete()
	self.m_textScene = nil
end 

--//	@sender 	[object]		sender
--//	@name 		[string]		message name
--//	@body 		[table]			anything else

function EditorSceneManager:onMessage(sender,name,body)

	assert(name == "iconbutton" and body.type == "start")										-- check it's the start message

	self:performGameEvent("next")
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		6-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

