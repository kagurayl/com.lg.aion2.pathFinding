
richtextflag =
{
    removeunstable = 0x1,
	removecolor = 0x2
}

richtexttag =
{
    text = 1,
	image = 2,
    color = 3,
	colorend = 4,
	boldface = 5,
	boldfaceend = 6,
	italics = 7,
	italicsend = 8,
	dict = 9,
	replace = 10,
	item = 11,
	equip = 12,
	recruit = 13,
	location = 14,
	quest = 15,
	npc = 16,
}

local m_richtext_replace = nil

function richtext_clearreplace()
	m_richtext_replace = {}
end

function richtext_addreplace(key, val)
	m_richtext_replace[key] = val
end

function richtext_updatereplace()
	richtext_clearreplace()
	richtext_addreplace("username", playerattr_info.name)
	richtext_addreplace("userclass", c_textformat(playercareertext[playerattr_info.career]))
	richtext_addreplace("userrace", c_textformat(getplayercivtext(playerattr_info.civ)))
end

function richtext_setweaponreplace()
	local name = ""
	local equip = playeritem_getspareequip(equipslot.weapon1)
	local config_item = csvitem_getfromid(equip.itemid)
	if config_item ~= nil then
		name = csvitem_getcolorname(config_item)
	end
	m_richtext_replace["mainslotitem"] = name
end

local function richtext_getarg(str, arg)
	local bytespace = string.byte(" ")
	local byteequals = string.byte("=")
	local bytebrackets1 = string.byte("/")
	local bytebrackets2 = string.byte(">")
	for i=1, #str - #arg do
		local strbyte = string.byte(str,i,i)
		if strbyte == bytespace then
			local argname = string.sub(str, i + 1, i + #arg)
			if argname == arg then
				local index = i + 1 + #arg
				strbyte = string.byte(str,index,index)
				if strbyte == byteequals then
					for j=index + 1, #str do
						strbyte = string.byte(str,j,j)
						if strbyte == bytespace or strbyte == bytebrackets1 or strbyte == bytebrackets2 then
							return string.sub(str, index + 1, j - 1)
						end
					end
					return
				end
			end
		end
	end
end

local function richtext_gettag(str)
	if string.startwith(str, "<quad") then
		local tag = {type = richtexttag.image}
		tag.x = richtext_getarg(str, "x")
		tag.y = richtext_getarg(str, "y")
		return tag
	elseif string.startwith(str, "<color=") then
		if #str == 15 or #str == 17 then
			local tag = {type = richtexttag.color}
			tag.color = string.sub(str, 9, #str - 1)
			return tag
		end
	elseif string.startwith(str, "</color>") then
		return {type = richtexttag.colorend}
	elseif string.startwith(str, "<u") then
		local tag = {type = richtexttag.item}
		tag.itemid = base52_decode(richtext_getarg(str, "i"))
		return tag
	elseif string.startwith(str, "<e") then
		local tag = {type = richtexttag.equip}
		tag.uuid = base52_decode(richtext_getarg(str, "u"))
		return tag
	elseif string.startwith(str, "<r") then
		local tag = {type = richtexttag.recruit}
		tag.leaderid = richtext_getarg(str, "l")
		return tag
	elseif string.startwith(str, "<m") then
		local tag = {type = richtexttag.location}
		tag.mapid = richtext_getarg(str, "m")
		tag.x = richtext_getarg(str, "x")
		tag.y = richtext_getarg(str, "y")
		tag.z = richtext_getarg(str, "z")
		return tag
	elseif string.startwith(str, "<q") then
		local tag = {type = richtexttag.quest}
		tag.questid = richtext_getarg(str, "i")
		return tag
	elseif string.startwith(str, "<n") then
		local tag = {type = richtexttag.npc}
		tag.npcid = richtext_getarg(str, "i")
		return tag
	elseif string.startwith(str, "<b>") then
		return {type = richtexttag.boldface}
	elseif string.startwith(str, "</b>") then
		return {type = richtexttag.boldfaceend}
	elseif string.startwith(str, "<i>") then
		return {type = richtexttag.italics}
	elseif string.startwith(str, "</i>") then
		return {type = richtexttag.italicsend}
	end
end

local function richtext_getdict(str)
	if string.startwith(str, "[%dic:") then
		local tag = {type = richtexttag.dict}
		tag.key = string.upper(string.sub(str, 7, #str - 1))
		return tag
	elseif string.startwith(str, "[%") then
		local tag = {type = richtexttag.replace}
		tag.key = string.sub(str, 3, #str - 1)
		return tag
	end
end

function richtext_parse(srctext, equip, flag)
	if srctext == nil then
		return nil, nil
	end
	local removeunstable = bit.band(flag, richtextflag.removeunstable) > 0
	local removecolor = bit.band(flag, richtextflag.removecolor) > 0

	local bytebrackets1 = string.byte("<")
	local bytebrackets2 = string.byte(">")
	local bytebracketsdict1 = string.byte("[")
	local bytebracketsdict2 = string.byte("]")
	local bytebracketsdict3 = string.byte("%")
	local tagarray = {}
	local textstart = 1
	local brackets1 = 0
	local bracketsdict1 = 0
	for i=1, #srctext do
		local srcbyte = string.byte(srctext, i, i)
		if srcbyte == bytebrackets1 then
			brackets1 = i
		elseif srcbyte == bytebrackets2 then
			if brackets1 > 0 then
				local tag = richtext_gettag(string.sub(srctext, brackets1, i))
				if tag ~= nil then
					local tagprev = {}
					tagprev.type = richtexttag.text
					tagprev.text = string.sub(srctext, textstart, brackets1 - 1)
					tagarray[#tagarray + 1] = tagprev

					tagarray[#tagarray + 1] = tag
					textstart = i + 1
					brackets1 = 0
				end
			end
		elseif srcbyte == bytebracketsdict1 then
			bracketsdict1 = i
		elseif srcbyte == bytebracketsdict2 then
			if bracketsdict1 > 0 then
				local tag = richtext_getdict(string.sub(srctext, bracketsdict1, i))
				if tag ~= nil then
					local tagprev = {}
					tagprev.type = richtexttag.text
					tagprev.text = string.sub(srctext, textstart, bracketsdict1 - 1)
					tagarray[#tagarray + 1] = tagprev
					
					tagarray[#tagarray + 1] = tag
					textstart = i + 1
					bracketsdict1 = 0
					srcbyte = string.byte(srctext, textstart, textstart)
					if srcbyte == bytebracketsdict3 then
						i = i + 1
						textstart = i + 1
					end
				end
			end
		end
		if i == #srctext and textstart <= i then
			local tag = {}
			tag.type = richtexttag.text
			tag.text = string.sub(srctext, textstart, i)
			tagarray[#tagarray + 1] = tag
		end
	end

	local text = ""
	for tagindex=1,#tagarray do
		local tag = tagarray[tagindex]
		if tag.type == richtexttag.text then
			text = text .. tag.text
		elseif tag.type == richtexttag.image then
			text = text .. string.format("<quad x=%d y=%d>", tag.x, tag.y)
		elseif tag.type == richtexttag.color then
			if not removecolor then
				text = text .. string.format("<color=#%s>", tag.color)
			end
		elseif tag.type == richtexttag.colorend then
			if not removecolor then
				text = text .. "</color>"
			end
		elseif tag.type == richtexttag.boldface then
			if not removeunstable then
				text = text .. "<b>"
			end
		elseif tag.type == richtexttag.boldfaceend then
			if not removeunstable then
				text = text .. "</b>"
			end
		elseif tag.type == richtexttag.italics then
			if not removeunstable then
				text = text .. "<i>"
			end
		elseif tag.type == richtexttag.italicsend then
			if not removeunstable then
				text = text .. "</i>"
			end
		elseif tag.type == richtexttag.dict then
			tag.startindex = c_textutf8count(text)
			local dict = c_textformat(tag.key)
			local dictsplit = string.byte(";")
			local textsplit = tag.key
			for i=1,#dict do
				local dictbyte = string.byte(dict, i, i)
				if dictbyte == dictsplit then
					textsplit = string.sub(dict, 1, i - 1)
					break
				end
			end
			if removecolor then
				text = text .. textsplit
			else
				text = text .. string.format("<color=#%08x>%s</color>", Color_LinkWeb, textsplit)
			end
			tag.endindex = c_textutf8count(text)
		elseif tag.type == richtexttag.replace then
			tag.startindex = c_textutf8count(text)
			local replace = m_richtext_replace[tag.key]
			if replace ~= nil then
				text = text .. replace
			else
				text = text .. string.format("[%%%s]", tag.key)
			end
			tag.endindex = c_textutf8count(text)
		elseif tag.type == richtexttag.item then
			tag.startindex = c_textutf8count(text)
			local config_item = csvitem_getfromid(tag.itemid)
			if config_item ~= nil then
				if removecolor then
					text = text .. config_item.name
				else
					text = text .. csvitem_getcolorname(config_item)
				end
			end
			tag.endindex = c_textutf8count(text)
		elseif tag.type == richtexttag.equip then
			if equip ~= nil then
				local taguuid = string.tointeger(tag.uuid)
				for i=1,#equip do
					if equip[i].uuid == taguuid then
						tag.startindex = c_textutf8count(text)
						local config_item = csvitem_getfromid(equip[i].itemid)
						if config_item ~= nil then
							if removecolor then
								text = text .. config_item.name
							else
								text = text .. csvitem_getcolorname(config_item)
							end
						end
						tag.endindex = c_textutf8count(text)
						tag.equip = equip[i]
						break
					end
				end
			end
		elseif tag.type == richtexttag.recruit then
			tag.startindex = c_textutf8count(text)
			if removecolor then
				text = text .. c_textformat("CHAT_LINK_RECRUIT")
			else
				text = text .. string.format("<color=#%08x><%s></color>", Color_LinkWhere, c_textformat("CHAT_LINK_RECRUIT"))
			end
			tag.endindex = c_textutf8count(text)
		elseif tag.type == richtexttag.location then
			tag.startindex = c_textutf8count(text)
			if removecolor then
				text = text .. c_textformat("CHAT_LINK_LOCATION")
			else
				text = text .. string.format("<color=#%08x><%s></color>", Color_LinkWhere, c_textformat("CHAT_LINK_LOCATION"))
			end
			tag.endindex = c_textutf8count(text)
		elseif tag.type == richtexttag.quest then
			local config_quest = csvquest_getfromid(string.tointeger(tag.questid))
			if config_quest ~= nil then
				tag.startindex = c_textutf8count(text)
				if removecolor then
					text = text .. config_quest.name
				else
					text = text .. string.format("<color=#%08x><%s></color>", Color_LinkQuest, config_quest.name)
				end
				tag.endindex = c_textutf8count(text)
			end
		elseif tag.type == richtexttag.npc then
			local config_npc = csvnpc_getfromid(string.tointeger(tag.npcid))
			if config_npc ~= nil then
				tag.startindex = c_textutf8count(text)
				if removecolor then
					text = text .. config_npc.name
				else
					text = text .. string.format("<color=#%08x>%s</color>", Color_LinkPos, config_npc.name)
				end
				tag.endindex = c_textutf8count(text)
			end
		end
	end
	return text, tagarray
end

function richtext_makeitem(itemid)
	return string.format("<u i=%s>", base52_encode(itemid))
end

function richtext_makeequip(uuid)
	return string.format("<e u=%s>", base52_encode(uuid))
end

function richtext_makerecruit(leaderid)
	return string.format("<r l=%d>", base52_encodesign(leaderid))
end

function richtext_makelocation(mapid, x, y, z)
	return string.format("<m m=%s x=%s y=%s z=%s>", base52_encodesign(mapid), base52_encodesign(x), base52_encodesign(y), base52_encodesign(z))
end

function richtext_makequest(questid)
	return string.format("<q i=%d>", questid)
end

function richtext_clicklink(tag, tipsx, tipsflag)
	if tag.type == richtexttag.item then
        if tag.itemid ~= nil then
			tips_item(string.tointeger(tag.itemid), 1, tipsx, -1, tipsflag, nil)
        end
	elseif tag.type == richtexttag.equip then
		if tag.equip ~= nil then
			tips_item(tag.equip.itemid, 1, tipsx, -1, tipsflag, tag.equip)
		end
	elseif tag.type == richtexttag.dict then
		dictview_setview(tag.key)
	elseif tag.type == richtexttag.recruit then
		--tag.leaderid
	elseif tag.type == richtexttag.location then
		maplabel_addlocation(false, base52_decodesign(tag.mapid), base52_decodesign(tag.x), base52_decodesign(tag.y), base52_decodesign(tag.z))
	elseif tag.type == richtexttag.quest then
		--tag.questid
	elseif tag.type == richtexttag.npc then
		--tag.npcid
	end
end

function richtext_onclick(event, tagarray, tipsx, flag)
	if tagarray ~= nil then
		linkid = string.tointeger(event.linkid)
		for i=1,#tagarray do
			local tag = tagarray[i]
			if tag.startindex ~= nil and tag.endindex ~= nil and linkid > tag.startindex and linkid <= tag.endindex then
				richtext_clicklink(tag, tipsx, flag)
				break
			end
		end
	end
end
