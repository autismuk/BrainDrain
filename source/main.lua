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
require("scene.puzzle")

Framework:new("audio.sound",																	-- create sounds object
					{ sounds = { "correct","wrong" } })

local manager = Framework:new("game.manager") 													-- Create a new game manager and add states.

manager:addManagedState("game",
						Framework:new("scene.puzzle"),
						{})

local function facFunc(count) 
	local a = {}
	for i = 1,count do a[i] = i end
	a[4] = "4hello"
	a[5] = "5cat"
	a[6] = "6antidisestablishmentarianism"
	a[9] = "9another"
	return a 
end

manager:start("game",{ factory = facFunc })
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

-- add in default values.
-- add effects - rotating/shuffling, chance of rotate/shuffle (done on update of pieceManager) - moving code written.
-- handle click & removal, use star effect to remove, play right/wrong fx
-- timing counter (enterframe on background object)
-- adjust particle to fix ParticleLifeSpanInSeconds ?
-- main menu etc.
-- "use your own word list"

-- end game / time out / home