--- ************************************************************************************************************************************************************************
---
---				Name : 		factory.lua
---				Purpose :	Factory that produces sequence factories
---				Created:	3 October 2014
---				Updated:	3 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************


local FactorySourceClass = Framework:createClass("game.factorysource")

function FactorySourceClass:constructor(info) end 
function FactorySourceClass:destructor() end

local facFunc = {}

function facFunc:count() return 25 end 

function facFunc:get(count) 
	local a = {}
	for i = 1,count do a[i] = i end
	a[4] = "4hello"
	a[5] = "5cat"
	a[6] = "6terrible"
	a[9] = "9another"
	return a 
end

function FactorySourceClass:getFactory(type) 
	return facFunc 
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		03-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************