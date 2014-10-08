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
	version = 		"1.0",
	developers = 	{ "Paul Robson" },
	email = 		"paul@robsons.org.uk",
	fqdn = 			"uk.org.robsons.brainwash", 												-- must be unique for each application.
    admobIDs = 		{ 																			-- admob Identifiers.
    					ios = "ca-app-pub-8354094658055499/1749592813", 							
						android = "ca-app-pub-8354094658055499/1609992011"
					},
	showDebug = 	true 																		-- show debug info and adverts.
}

display.setStatusBar(display.HiddenStatusBar)													-- hide status bar.
require("strict")																				-- install strict.lua to track globals etc.
require("framework.framework")																	-- framework.
require("utils.sound")																			-- sfx singleton
require("scene.puzzle") 																		-- puzzle scene code.
require("utils.simplescene")
require("scene.highscore")
require("scene.setup")
require("scene.editor")

--- ************************************************************************************************************************************************************************
--																				Start Up
--- ************************************************************************************************************************************************************************

Framework:new("audio.sound",																	-- create sounds object, not much in this game.
					{ sounds = { "correct","wrong" } })


local manager = Framework:new("game.manager") 													-- Create a new game manager and then add states.

manager:addManagedState("title",
						Framework:new("scene.simple.touch",{
							constructor = function(storage,group,scene,manager)					-- just create some animated bitmap headings.
								local r = display.newRect(group,0,0,display.contentWidth,display.contentHeight)
								r.anchorX,r.anchorY = 0,0 r.alpha = 0
								local ver = display.newText(group,"v"..ApplicationDescription.version,0,0,system.nativeFont,10)
								ver.anchorX,ver.anchorY = 0,0 ver:setFillColor(0,1,0)
								storage.t1 = display.newBitmapText(group,"BRAINDRAIN",display.contentWidth/2,display.contentHeight * 0.2,"badabb",display.contentWidth/3.5):setTintColor(1,1,0)
								storage.t2 = display.newBitmapText(group,"TRAIN YOUR BRAIN!",display.contentWidth/2,display.contentHeight * 0.55,"badabb",display.contentWidth/7):setTintColor(1,0.5,0)
								storage.t3 = display.newBitmapText(group,"WRITTEN BY PAUL ROBSON (C) 2014",display.contentWidth/2,display.contentHeight * 0.9,"badabb",display.contentWidth/12):setTintColor(0,0.5,1)
								storage.t1:setModifier("scale"):animate(3)
								storage.t2:setModifier(	function(modifier, cPos, info)
															local w = math.floor(info.elapsed/720) % info.wordCount + 1 									
															if info.wordIndex == w then  																		
																	local newScale = 1 + (info.elapsed/2 % 360) / 360 / 2										
																	modifier.xScale,modifier.yScale = newScale,newScale 									
															end
														end):animate()
								storage.t3:setModifier("wobble")
							end,
							destructor = function(storage,group,scene,manager)
								storage.t1:removeSelf()
								storage.t2:removeSelf()
								storage.t3:removeSelf()
							end
						}),
						{ next = "setup"})

manager:addManagedState("setup",																-- set up scene
						Framework:new("scene.setup",{}),
						{ next = "game", edit = "editor" })

manager:addManagedState("editor",
						Framework:new("scene.editor",{}),
						{ next = "setup"})

manager:addManagedState("game",																	-- actual game scene
						Framework:new("scene.puzzle"),
						{ win = "highscore", exit = "setup" })

manager:addManagedState("highscore",															-- high score scene
						Framework:new("scene.highscore"),
						{ next = "setup" })

manager:start("title") 																			-- and start.

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		26-Sep-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

-- TEST/Code Read, remove document store first.
-- testing

-- the superclass thing for decoration ???? - mixin still needs same ?
-- extended transition system.