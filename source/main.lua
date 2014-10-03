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
require("utils.stubscene")																		-- temporary stub scenes for FSM
require("utils.sound")																			-- sfx singleton
require("scene.puzzle") 																		-- puzzle scene code.
require("utils.simplescene")
require("scene.highscore")

Framework:new("audio.sound",																	-- create sounds object, not much in this game.
					{ sounds = { "correct","wrong" } })


local manager = Framework:new("game.manager") 													-- Create a new game manager and then add states.

manager:addManagedState("title",
						Framework:new("scene.simple.touch",{
							creator = function(group,scene,manager)
								local background = display.newRect(group,0,0,					-- mosaic background
															display.contentWidth,display.contentHeight)
								background.anchorX,background.anchorY = 0,0
								display.setDefault("textureWrapX","repeat")
								display.setDefault("textureWrapY","repeat")
								background.fill = { type = "image", filename = "images/mosaict.jpg" }
								background.fill.scaleX,background.fill.scaleY = 0.2,0.15	
								local image = display.newImage(group,"images/title.png",0,0)
								image.anchorX,image.anchorY = 0,0
								local ver = display.newText(group,"v"..ApplicationDescription.version,0,0,system.nativeFont,10)
								ver.anchorX,ver.anchorY = 0,0 ver:setFillColor(0,1,0)
							end
						}),
						{ next = "setup"})

manager:addManagedState("setup",
						Framework:new("utils.stubscene", { name = "setup screen",targets = { next = "play game" }}),
						{ next = "game" })

manager:addManagedState("game",
						Framework:new("scene.puzzle"),
						{ win = "highscore", exit = "setup" })

manager:addManagedState("highscore",
						Framework:new("scene.highscore"),
						{ next = "setup" })

local function facFunc(count) 
	local a = {}
	for i = 1,count do a[i] = i end
	a[4] = "4hello"
	a[5] = "5cat"
	a[6] = "6terrible"
	a[9] = "9another"
	return a 
end


manager:start("game",{ factory = facFunc, margin = 4, gridSize = 2, timeAllowed = 6, 
			 		   isReversed = false, isShuffling = true, isRotating = true, isChangingBackground = true, 
			 		   isVerticallyMirrored = false, isHorizontallyMirrored = false, isHard = true })

--manager:start("highscore",{})

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		26-Sep-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

-- gui design and implementation (?)
-- main setup screen (preserves state in offline storage)
-- icon
-- testing
-- ("use your own word list")

-- the superclass thing for decoration ???? - mixin still needs same ?
-- extended transition system.