--- ************************************************************************************************************************************************************************
---
---				Name : 		main.lua
---				Purpose :	Top level code "Brain Drain"
---				Updated:	26 September 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

ApplicationDescription = { 																		-- application description.
	appName = 		"BrainWash",
	version = 		"0.1",
	developers = 	{ "Paul Robson" },
	email = 		"paul@robsons.org.uk",
	fqdn = 			"uk.org.robsons.brainwash", 												-- must be unique for each application.
    admobIDs = 		{ 																			-- admob Identifiers.
    					ios = "ca-app-pub-8354094658055499/1659828014", 							
						android = "ca-app-pub-8354094658055499/7706361613" 
					}
}

display.setStatusBar(display.HiddenStatusBar)													-- hide status bar.
require("strict")																				-- install strict.lua to track globals etc.
require("framework.framework")																	-- framework.
require("utils.sound")																			-- sfx singleton
require("scene.puzzle") 																		-- puzzle scene code.
require("utils.simplescene")
require("scene.highscore")
require("scene.setup")

Framework:new("audio.sound",																	-- create sounds object, not much in this game.
					{ sounds = { "correct","wrong" } })


local manager = Framework:new("game.manager") 													-- Create a new game manager and then add states.

manager:addManagedState("title",
						Framework:new("scene.simple.timed",{
							creator = function(group,scene,manager)
								local background = display.newRect(group,0,0,					-- mosaic background
															display.contentWidth,display.contentHeight)
								background.anchorX,background.anchorY = 0,0
								background:setFillColor(0,0,0.5)
								background.fill.scaleX,background.fill.scaleY = 0.2,0.15	
								local image = display.newImage(group,"images/title.png",0,0)
								image.anchorX,image.anchorY = 0,0
								local ver = display.newText(group,"v"..ApplicationDescription.version,0,0,system.nativeFont,10)
								ver.anchorX,ver.anchorY = 0,0 ver:setFillColor(0,1,0)
							end
						}),
						{ next = "setup"})

manager:addManagedState("setup",
						Framework:new("scene.setup",{}),
						{ next = "game" })

manager:addManagedState("game",
						Framework:new("scene.puzzle"),
						{ win = "highscore", exit = "setup" })

manager:addManagedState("highscore",
						Framework:new("scene.highscore"),
						{ next = "setup" })

manager:start("title")

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		26-Sep-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************


-- create standard factories.
-- TEST/Code Read
-- Comments !
-- "use your own word list" - get from clipboard as HTML
-- icon
-- testing

-- the superclass thing for decoration ???? - mixin still needs same ?
-- extended transition system.