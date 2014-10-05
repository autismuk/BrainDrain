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

require("game.usertext")

--- ************************************************************************************************************************************************************************
--															Number outputting factory, can do steps of one or with gaps.
--- ************************************************************************************************************************************************************************

local NumberFactory = Framework:createClass("game.factory.numbers")

function NumberFactory:constructor(info) self.m_spaceOut = info.spacing end 
function NumberFactory:destructor(info) end 

function NumberFactory:count() return 999999 end 

function NumberFactory:get(count) 
	local a = {} 																	-- this is the final list
	local n = 1 																	-- always start from 1, be nice :)
	for i = 1,count do  															-- create count numbers
		a[i] = n 																	-- store current
		if self.m_spaceOut then n = n + math.random(1,3) else n = n + 1 end 		-- go to next or perhaps step
	end 
	return a 																		-- return the list
end

--- ************************************************************************************************************************************************************************
--																			Word Factory (consecutive values)
--- ************************************************************************************************************************************************************************

local WordFactory = Framework:createClass("game.factory.words")

function WordFactory:constructor(info) self.m_list = info.list end 
function WordFactory:destructor(info) end 

function WordFactory:count() return #self.m_list end 

function WordFactory:get(count) 
	local list = {}
	local p = 1 																	-- start at 1
	if count ~= #self.m_list then p = math.random(1,#self.m_list-count) end			-- this is where we start - if not using all values
	for i = 1,count do list[i] = self.m_list[p] p = p + 1 end 						-- copy consecutive values
	return list 
end
--- ************************************************************************************************************************************************************************
--																			Word Factory (any values at all)
--- ************************************************************************************************************************************************************************

local SpacedWordFactory = Framework:createClass("game.factory.words.spaced","game.factory.words")

function SpacedWordFactory:get(count) 
	local list = {} 																-- list, initially of array indices
	local indexUsed = {} 															-- has the value been used
	for i = 1,count do  															-- for count objects
		local selected  		
		repeat  																	-- pick one at random
			selected = math.random(1,self:count())
		until not indexUsed[selected] 												-- that we haven't used yet
		indexUsed[selected] = true  												-- mark it used
		list[#list+1] = selected 													-- add its index to the list
	end 
	table.sort(list) 																-- values sorted as they were originally, because the index order defines it.
	for i = 1,count do list[i] = self.m_list[list[i]] end 							-- pull out the actual values
	return list
end 

--- ************************************************************************************************************************************************************************
--//															Very simple class for putting out word list factories
--- ************************************************************************************************************************************************************************

local FactorySourceClass = Framework:createClass("game.factorysource")

function FactorySourceClass:constructor(info) end 
function FactorySourceClass:destructor() end

--//	Get a factory as required. 1 = Numbers, 2 = Alphabet, 3 = Numbers with Gaps, 4 = Letters with Gaps, 5 = Three Letter Words, 6 = Top 500, 
--// 	7 = User Defined (sequential), 8 = User defined (spaces)
--//	@type 	[number]		factory type - see the "items" selector in setup.lua - this value is its index.
--//	@return [object] 		factory with count() and get() methods.

function FactorySourceClass:getFactory(type) 

	if type == 1 then return Framework:new("game.factory.numbers", { spacing = false }) end
	if type == 2 then return Framework:new("game.factory.words", { list = WordFactory.alphabet }) end
	if type == 3 then return Framework:new("game.factory.numbers", { spacing = true }) end
	if type == 4 then return Framework:new("game.factory.words.spaced", { list = WordFactory.alphabet }) end
	if type == 5 then return Framework:new("game.factory.words.spaced", { list = WordFactory.threeLetters }) end
	if type == 6 then return Framework:new("game.factory.words.spaced", { list = WordFactory.top500 }) end
	if type == 7 then return Framework:new("game.factory.words", { list = Framework.fw.usertext:getSplit() }) end
	if type == 8 then return Framework:new("game.factory.words.spaced", { list = Framework.fw.usertext:getSplit() }) end
	return facFunc 
end 

WordFactory.alphabet = { "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z" }

WordFactory.threeLetters = { "act","all","and","any","are","bar","boy","but","can","car","dad","day","dew","did","eat","far","for",
							 "get","gym","has","her","hey","him","his","how","ink","its","jet","key","let","log","mad","man","mom",
							 "nap","new","not","now","odd","old","one","our","out","pal","put","ram","saw","say","see","she","tan",
							 "the","too","two","urn","use","vet","was","way","wed","who","yap","you","zoo" }

WordFactory.top500 = { "the","name","of","very","to","through","and","just","form","in","much","is","great","it","think","you","say","that","help","he","low","was",
					   "line","for","before","on","turn","are","cause","with","same","as","mean","differ","his","move","they","right","be","boy","at","old","one",
					   "too","have","does","this","tell","from","sentence","or","set","had","three","by","want","hot","air","but","well","some","also","what","play",
					   "there","small","we","end","can","put","out","home","other","read","were","hand","all","port","your","large","when","spell","up","add","use",
					   "even","word","land","how","here","said","must","an","big","each","high","she","such","which","follow","do","act","their","why","time","ask",
					   "if","men","will","change","way","went","about","light","many","kind","then","off","them","need","would","house","write","picture","like",
					   "try","so","us","these","again","her","animal","long","point","make","mother","thing","world","see","near","him","build","two","self","has",
					   "earth","look","father","more","head","day","stand","could","own","go","page","come","should","did","country","my","found","sound","answer",
					   "no","school","most","grow","number","study","who","still","over","learn","know","plant","water","cover","than","food","call","sun","first",
					   "four","people","thought","may","let","down","keep","side","eye","been","never","now","last","find","door","any","between","new","city","work",
					   "tree","part","cross","take","since","get","hard","place","start","made","might","live","story","where","saw","after","far","back","sea",
					   "little","draw","only","left","round","late","man","run","year","don't","came","while","show","press","every","close","good","night","me","real",
					   "give","life","our","few","under","open","ten","seem","simple","together","several","next","vowel","white","toward","children","war","begin",
					   "lay","got","against","walk","pattern","example","slow","ease","center","paper","love","often","person","always","money","music","serve",
					   "those","appear","both","road","mark","map","book","science","letter","rule","until","govern","mile","pull","river","cold","car","notice",
					   "feet","voice","care","fall","second","power","group","town","carry","fine","took","certain","rain","fly","eat","unit","room","lead","friend",
					   "cry","began","dark","idea","machine","fish","note","mountain","wait","north","plan","once","figure","base","star","hear","box","horse","noun",
					   "cut","field","sure","rest","watch","correct","color","able","face","pound","wood","done","main","beauty","enough","drive","plain","stood","girl",
					   "contain","usual","front","young","teach","ready","week","above","final","ever","gave","red","green","list","oh","though","quick","feel","develop",
					   "talk","sleep","bird","warm","soon","free","body","minute","dog","strong","family","special","direct","mind","pose","behind","leave","clear","song",
					   "tail","measure","produce","state","fact","product","street","black","inch","short","lot","numeral","nothing","class","course","wind","stay","question",
					   "wheel","happen","full","complete","force","ship","blue","area","object","half","decide","rock","surface","order","deep","fire","moon","south","island",
					   "problem","foot","piece","yet","told","busy","knew","test","pass","record","farm","boat","top","common","whole","gold","king","possible","size","plane",
					   "heard","age","best","dry","hour","wonder","better","laugh","true.","thousand","during","ago","hundred","ran","am","check","remember","game","step",
					   "shape","early","yes","hold","hot","west","miss","ground","brought","interest","heat","reach","snow","fast","bed","five","bring","sing","sit","listen",
					   "perhaps","six","fill","table","east","travel","weight","less","language","morning","among" }


table.sort(WordFactory.top500)							 
table.sort(WordFactory.alphabet)							 
table.sort(WordFactory.threeLetters)		
					 
--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		03-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************