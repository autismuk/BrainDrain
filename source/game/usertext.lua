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
	self.m_userText = UserText.xanadu
end 

function UserText:destructor()
end


--//	Get the current user text split into seperate words all lower case.
--//	@return 	[Array]		List of words

function UserText:getSplit()
	local txt = (self.m_userText.." "):lower():gsub("%W"," "):gsub("%s+","!")		-- get text, append a space, make lower case,replace any group of spaces by pling.
	local words = {} 																-- array of words.
	print(txt)
	while txt ~= "" and txt ~= "!" do 												-- while text string is not empty or not just a pling (empty string)
		local word
		word,txt = txt:match("^!*(%w+)!(.*)$") 										-- strip off first word and keep rest
		if #word > 0 then 															-- shouldn't happen, but just in case.
			words[#words+1] = word 													-- add word to word list.
			--print(#words,word)													-- helps with debugging :)
		end
	end
	--print(#words)
	return words 																	-- return the word list.
end 

																					-- Coleridge's default text with some traps.
UserText.xanadu =  "   In Xanadu!!! did Kubla Khan a stately pleasure dome decree, where Alph the sacred river ran through caverns " ..
					"measureless to man down to a sunless sea, so twice five miles of fertile  ,  ground----with walls and towers " ..
					"were girdled round and there were gardens bright with sinuous rills where.!  "

local Singleton = Framework:new("game.usertext")
Singleton:getSplit()

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		05-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
