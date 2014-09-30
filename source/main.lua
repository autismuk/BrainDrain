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
	appName = "BrainWash",
	version = "0.1",
	developers = { "Paul Robson" },
	email = "paul@robsons.org.uk",
	fqdn = "uk.org.robsons.brainwash"
}

display.setStatusBar(display.HiddenStatusBar)													-- hide status bar.
require("strict")																				-- install strict.lua to track globals etc.

require("framework.framework")																	-- framework.
require("utils.stubscene")
require("utils.sound")
require("scene.puzzle")

Framework:new("audio.sound",																	-- create sounds object
					{ sounds = { "correct","wrong" } })

local manager = Framework:new("game.manager") 													-- Create a new game manager and add states.

manager:addManagedState("title",
						Framework:new("utils.stubscene", { name = "title page",targets = { next = "start game" }}),
						{ next = "setup"})

manager:addManagedState("setup",
						Framework:new("utils.stubscene", { name = "setup screen",targets = { next = "play game" }}),
						{ next = "game" })

manager:addManagedState("game",
						Framework:new("scene.puzzle"),
						{ win = "highscore", exit = "setup" })

manager:addManagedState("highscore",
						Framework:new("utils.stubscene", { name = "high score",targets = { next = "setup screen" }}),
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

manager:start("game",{ factory = facFunc, 
 margin = 4, gridSize = 2, timeAllowed = 6, 
			 		   isReversed = false, isShuffling = true, isRotating = true, isChangingBackground = true, 
			 		   isVerticallyMirrored = false, isHorizontallyMirrored = false, isHard = true })

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		26-Sep-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

-- text object utility for adding to scenes ?
-- generic scene class, extend to delayed scene class and clickable scene class to progress.
-- current & high score table (combining the two)
-- gui design and implementation
-- main setup screen (preserves state in offline storage)
-- title screen (graphic exists) (use ApplicationVersion)
-- ("use your own word list")

-- the superclass thing for decoration ???? - mixin still needs same ?