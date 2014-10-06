--- ************************************************************************************************************************************************************************
---
---				Name : 		editor.lua
---				Purpose :	User Text Editor Scene
---				Updated:	6 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--- ************************************************************************************************************************************************************************
--//															Scene responsible for editor scene
--- ************************************************************************************************************************************************************************

local EditorScene = Framework:createClass("scene.editor.main")

--//	Constructor for setup 
--//	@info 	[table]		constructor information (top,bottom)

function EditorScene:constructor(info)
	self.m_group = display.newGroup() 												-- group for graphic objects.
end 

function EditorScene:destructor() 
	self.m_group:removeSelf() 														-- remove graphics
	self.m_group = nil 
end 

function EditorScene:getDisplayObjects() return { self.m_group } end

--- ************************************************************************************************************************************************************************
--//																	Scene Manager Class
--- ************************************************************************************************************************************************************************

local EditorSceneManager = Framework:createClass("scene.editor","game.sceneManager")

--//	Before opening a main scene, create it.

function EditorSceneManager:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene") 													-- create a new scene
	scene:new("scene.editor.main",{ }) 															-- set up the setup scene
	scene:new("control.rightarrow", { x = 90, r = 1, g = 0.5, b = 0, 							-- add right arrow to go to game.
													listener = self, message = "start" })
	return scene
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

