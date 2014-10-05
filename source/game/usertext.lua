--- ************************************************************************************************************************************************************************
---
---				Name : 		usertext.lua
---				Purpose :	Manages user defined text (singleton)
---				Updated:	5 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local UserText = Framework:createClass("game.usertext")

function UserText:constructor(info)
	self:name("usertext")
end 

function UserText:destructor()
end

function UserText:getSplit()
	return UserText.xanadu
end 

UserText.xanadu = { "in","xanadu","did","kubla","khan","a","stately","pleasure","dome","decree","where","alph","the","sacred","river","ran","through","caverns",
					"measureless","to","man","down","to","a","sunless","sea","so","twice","five","miles","of","fertile","ground","with","walls","and","towers",
					"were","girdled","round","and","there","were","gardens","bright","with","sinuous","rills","where" }

Framework:new("game.usertext").constructor = nil

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		05-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
