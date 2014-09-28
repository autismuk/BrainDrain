--- ************************************************************************************************************************************************************************
---
---				Name : 		main.lua
---				Purpose :	Top level code "Brain Drain"
---				Updated:	26 September 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

ApplicationVersion = "v0.1"

display.setStatusBar(display.HiddenStatusBar)													-- hide status bar.
require("strict")																				-- install strict.lua to track globals etc.
require("framework.framework")																	-- framework.
require("utils.sound")
require("utils.admob")
require("utils.stubscene")
require("scene.puzzle")

Framework:new("audio.sound",																	-- create sounds object
					{ sounds = { "correct","wrong" } })

local manager = Framework:new("game.manager") 													-- Create a new game manager and add states.

manager:addManagedState("title",
						Framework:new("utils.stubscene", { name = "title page",targets = { start = "start game" }}),
						{ start = "setup"})

manager:addManagedState("setup",
						Framework:new("utils.stubscene", { name = "setup screen",targets = { play = "play game" }}),
						{ play = "game" })

manager:addManagedState("game",
						Framework:new("scene.puzzle"),
						{ win = "highscore", exit = "setup" })

manager:addManagedState("highscore",
						Framework:new("utils.stubscene", { name = "high score",targets = { exit = "setup screen" }}),
						{ exit = "setup" })

local function facFunc(count) 
	local a = {}
	for i = 1,count do a[i] = i end
	a[4] = "4hello"
	a[5] = "5cat"
	a[6] = "6antidisestablishmentarianism"
	a[9] = "9another"
	return a 
end

manager:start("game",{ factory = facFunc, gridSize = 2 })
--, margin = 4, gridSize = 5, timeAllowed = 5 * 5 * 5, 
--			 		   isReversed = false, isShuffling = true, isRotating = true, isChangingBackground = true, 
--			 		   isVerticallyMirrored = false, isHorizontallyMirrored = false, isHard = true })

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		26-Sep-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

-- home button immediate fail.
-- difficulty level calculator
-- high score table and offline storage (see Rob's code)
-- gui design and implementation
-- main setup
-- title screen (graphic exists)
-- "use your own word list"

-- end game / time out / home

-- the superclass thing for decoration ????