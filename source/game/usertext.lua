--- ************************************************************************************************************************************************************************
---
---				Name : 		usertext.lua
---				Purpose :	Manages user defined text (singleton)
---				Updated:	5 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("utils.document")

--- ************************************************************************************************************************************************************************
--//																This class maintains and updates the user text
--- ************************************************************************************************************************************************************************

local UserText = Framework:createClass("game.usertext")

--//	Create the user text store
--//	@info 	[table]		Constructor data (unused)

function UserText:constructor(info)
	self:name("usertext") 															-- name object so it can be accessed
	self.m_userText = Framework.fw.documentStore:access().userText 					-- load the user text in
	self.m_userText = self.m_userText or UserText.xanadu 							-- use Xanadu as a default.
end

--//	Tidy up

function UserText:destructor()
end

--//	Access the user text
--//	@return 	[string]		User text as string

function UserText:get()
	return self.m_userText 
end 

--//	Set the user text
--//	@text 		[string]		Text to set it to

function UserText:set(text)
	self.m_userText = text or "" 													-- save it
	Framework.fw.documentStore:access().userText = self.m_userText 					-- copy to document store
	Framework.fw.documentStore:update() 											-- and write it back to document store
end 

--//	Get the current user text split into seperate words all lower case.
--//	@return 	[Array]		List of words

function UserText:getSplit()
	local txt = (self.m_userText.." "):lower():gsub("%W"," "):gsub("%s+","!")		-- get text, append a space, make lower case,replace any group of spaces by pling.
	local words = {} 																-- array of words.
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

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		05-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
