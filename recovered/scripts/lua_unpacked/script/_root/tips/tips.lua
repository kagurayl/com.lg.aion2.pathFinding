include("tips/tips_item")
include("tips/tips_skill")
include("tips/tips_equip")
include("tips/tips_recipe")

local m_uitips_main = uipanel_createnamehandle("tips/tips_main", "tipsmain", uilayer.tips, 0)
local m_uitips_compare1 = uipanel_createnamehandle("tips/tips_main", "tipscompare1", uilayer.tips, 0)
local m_uitips_compare2 = uipanel_createnamehandle("tips/tips_main", "tipscompare2", uilayer.tips, 0)
local m_uitips_current = nil

local m_uitips_inst =
{
    attr1 = "tips/tips_attr1",
    attr2 = "tips/tips_attr2",
    desc = "tips/tips_desc",
    charge = "tips/tips_charge",
    gem = "tips/tips_gem",
    split = "tips/tips_split",
    title = "tips/tips_title",
}

tipsflag =
{
	vleft = 0x1,
    vright = 0x2,
    htop = 0x4,
    hbottom = 0x8,
    equip = 0x10,
    opencompare = 0x20,
    compare1 = 0x40,
    compare2 = 0x80,
    available = 0x100,
    addspace = 0x200,
    attrmain = 0x400,
    attrbonus = 0x800,
    attrcompond = 0x1000,
}

tipsextendtype =
{
	equip = 0x1,
    recipe = 0x2,
}

tipsitemcolor =
{
    0xadadadff,
    0xf1f1f1ff,
    0xa9feb3ff,
    0x92f4fdff,
    0xf6f56eff,
    0xff8033ff,
    0x800080ff,
}

TipsItemColorRecipe = 0xfff200ff
TipsAttrSpace = "    "

TIPS_COLOR_WHITE = 0xffffffff
TIPS_COLOR_TEXT = 0xededddff
TIPS_COLOR_GREY = 0x7f7f7fff
TIPS_COLOR_DESC = 0xcaba99ff
TIPS_COLOR_RED = 0xe01f1fff
TIPS_COLOR_EQUIPMINE = 0x9696dcff

function tips_create(flag, parent)
    if bit.band(flag, tipsflag.compare1) > 0 then
        m_uitips_current = m_uitips_compare1
    elseif bit.band(flag, tipsflag.compare2) > 0 then
        m_uitips_current = m_uitips_compare2
    else
        m_uitips_current = m_uitips_main
    end
    m_uitips_current:close()
    m_uitips_current:open()
    m_uitips_current:setparent(parent)
    m_uitips_current.flag = flag
    m_uitips_current.list_tips = m_uitips_current:getwidget("tips_root/list_tips")
    m_uitips_current.list_tips:init(bit.bor(uilistflag.vertical, uilistflag.scrolllimit))
    m_uitips_current.contentwidth = 800.0
    m_uitips_current.adjustsplit = {}
    m_uitips_current.adjustdesc = {}
    m_uitips_current.expiretext = nil
    m_uitips_current.expiresecond = nil
end

function tips_close()
    m_uitips_main:close()
    m_uitips_compare1:close()
    m_uitips_compare2:close()
end

function tips_adjustsize(line, x, y, w, h)
    line:setsize(h)
    local wmax = math.min(1500, x + w)
    if m_uitips_current.contentwidth < wmax then
        m_uitips_current.contentwidth = wmax
    end
end

function tips_addtitle(text, rgbhex, extend)
    local r, g, b, a = HexRGBA(rgbhex)
    local line = m_uitips_current.list_tips:add(m_uitips_inst.title)
    local text_title = line:getwidget("text_title")
    text_title:setcolor(r, g, b, a)
    text_title:settext(text)
    local x,y = text_title:getposition()
    local w,h = text_title:getrendersize()
    local buttonsize = math.ternary(extend, 300, 200)
    tips_adjustsize(line, x, y, w + buttonsize, h)
    text_title:updatescale(w, m_uitips_current.contentwidth - buttonsize)
    return text_title
end

function tips_addsplit()
    local line = m_uitips_current.list_tips:add(m_uitips_inst.split)
    m_uitips_current.adjustsplit[#m_uitips_current.adjustsplit + 1] = line
end

function tips_adddesc(text, rgbhex)
    local r, g, b, a = HexRGBA(rgbhex)
    local line = m_uitips_current.list_tips:add(m_uitips_inst.desc)
    local text_desc = line:getwidget("text_desc")
    text_desc:settext(text)
    text_desc:setcolor(r, g, b, a)
    m_uitips_current.adjustdesc[#m_uitips_current.adjustdesc + 1] = line
end

function tips_addchargeprogress(capacity)
    local line = m_uitips_current.list_tips:add(m_uitips_inst.charge)
    local progress_level1 = line:getwidget("progress_level1")
    local progress_level2 = line:getwidget("progress_level2")
    equip_setchargeprogress(progress_level1, progress_level2, capacity)
    m_uitips_current.adjustdesc[#m_uitips_current.adjustdesc + 1] = line
end

function tips_addattr1(attrname, attr, rgbhex, flag)
    local r, g, b, a = HexRGBA(rgbhex)
    if bit.band(flag, tipsflag.addspace) ~= 0 then
        attrname = TipsAttrSpace .. c_textformat(attrname)
    end
    local line = m_uitips_current.list_tips:add(m_uitips_inst.attr1)
    local text_attrname = line:getwidget("text_attrname")
    text_attrname:setcolor(r, g, b, a)
    text_attrname:settext(attrname)

    local text_attr = line:getwidget("text_attr")
    text_attr:setcolor(r, g, b, a)
    text_attr:settext(attr)

    local x,y = text_attr:getposition()
    local w,h = text_attr:getrendersize()
    tips_adjustsize(line, x, y, w, h)
end

function tips_addattr2(name1, val1, name2, val2, rgbhex, rgbhex2, flag)
    local r, g, b, a = HexRGBA(rgbhex)
    if bit.band(flag, tipsflag.addspace) ~= 0 then
        name1 = TipsAttrSpace .. c_textformat(name1)
    end
    local line = m_uitips_current.list_tips:add(m_uitips_inst.attr2)
    local text_attrname1 = line:getwidget("text_attrname1")
    text_attrname1:setcolor(r, g, b, a)
    text_attrname1:settext(name1)

    local text_attr1 = line:getwidget("text_attr1")
    text_attr1:setcolor(r, g, b, a)
    text_attr1:settext(val1)
    
    local text_attrname2 = line:getwidget("text_attrname2")
    local text_attr2 = line:getwidget("text_attr2")
    if name2 ~= nil then
        r, g, b, a = HexRGBA(rgbhex2)
        if bit.band(flag, tipsflag.addspace) ~= 0 then
            name2 = TipsAttrSpace .. c_textformat(name2)
        end
        text_attrname2:setvisiblenothit(true)
        text_attr2:setvisiblenothit(true)
        text_attrname2:setcolor(r, g, b, a)
        text_attrname2:settext(name2)
        text_attr2:setcolor(r, g, b, a)
        text_attr2:settext(val2)
        local x,y = text_attr2:getposition()
        local w,h = text_attr2:getrendersize()
        tips_adjustsize(line, x, y, w, h)
    else
        text_attrname2:setvisiblenothit(false)
        text_attr2:setvisiblenothit(false)
        local x,y = text_attr1:getposition()
        local w,h = text_attr1:getrendersize()
        tips_adjustsize(line, x, y, w, h)
    end
end

function tips_addgem(gemid1, gemid2)
    local line = m_uitips_current.list_tips:add(m_uitips_inst.gem)
    local image_iconbg1 = line:getwidget("gemicon1/image_iconbg")
    local image_icon1 = line:getwidget("gemicon1/image_icon")
    local text_name1 = line:getwidget("text_gem1")
    if gemid1 > 0 then
        local config_gem = csvitem_getfromid(gemid1)
        if config_gem ~= nil then
            image_icon1:seticon(config_gem.icon)
            text_name1:settextscale(config_gem.name)
            text_name1:setcolor(csvitem_getfloatcolor(config_gem))
        end
    else
        image_icon1:setvisible(false)
        text_name1:setvisible(false)
    end

    local image_iconbg2 = line:getwidget("gemicon2/image_iconbg")
    local image_icon2 = line:getwidget("gemicon2/image_icon")
    local text_name2 = line:getwidget("text_gem2")
    if gemid2 ~= nil then
        if gemid2 > 0 then
            local config_gem = csvitem_getfromid(gemid2)
            if config_gem ~= nil then
                image_icon2:seticon(config_gem.icon)
                text_name2:settextscale(config_gem.name)
                text_name2:setcolor(csvitem_getfloatcolor(config_gem))
            end
        else
            image_icon2:setvisible(false)
            text_name2:setvisible(false)
        end
        local x,y = text_name2:getposition()
        local w,h = text_name2:getsize()
        local w2,h2 = image_iconbg2:getsize()
        tips_adjustsize(line, x, y, w, h2)
    else
        image_iconbg2:setvisible(false)
        image_icon2:setvisible(false)
        text_name2:setvisible(false)
        local x,y = text_name1:getposition()
        local w,h = text_name1:getsize()
        local w2,h2 = image_iconbg1:getsize()
        tips_adjustsize(line, x, y, w, h2)
    end
end

function tips_addexpire(expire)
    local text = c_textformat("TIPS_ITEM_EXPIRE", timerdesc_getafter(expire - timer_gettimesecond()))
    local r, g, b, a = HexRGBA(TIPS_COLOR_RED)
    local line = m_uitips_current.list_tips:add(m_uitips_inst.desc)
    local text_expire = line:getwidget("text_desc")
    text_expire:settext(text)
    text_expire:setcolor(r, g, b, a)
    m_uitips_current.adjustdesc[#m_uitips_current.adjustdesc + 1] = line
    m_uitips_current.expiretext = text_expire
    m_uitips_current.expiresecond = expire
    event_register(eventtype.update, tips_updateexpire, m_uitips_current)
end

local function tips_updateexpiretext(expiretext, expiresecond)
    local second = expiresecond - timer_gettimesecond()
    if second >= 0 then
        local text = c_textformat("TIPS_ITEM_EXPIRE", timerdesc_getafter(second))
        expiretext:settext(text)
    end
end
function tips_updateexpire()
    if m_uitips_main:alive() and m_uitips_main.expiretext ~= nil then
        tips_updateexpiretext(m_uitips_main.expiretext, m_uitips_main.expiresecond)
    end
    if m_uitips_compare1:alive() and m_uitips_compare1.expiretext ~= nil then
        tips_updateexpiretext(m_uitips_compare1.expiretext, m_uitips_compare1.expiresecond)
    end
    if m_uitips_compare2:alive() and m_uitips_compare2.expiretext ~= nil then
        tips_updateexpiretext(m_uitips_compare2.expiretext, m_uitips_compare2.expiresecond)
    end
end

local function tips_adjustdesc(line, contentwidth)
    local text_desc = line:getwidget("text_desc")
    if text_desc ~= nil then
        local w, h = text_desc:getsize()
        text_desc:setsize(math.max(w, contentwidth), h)
        w,h = text_desc:setheightfromrendersize()
        line:setsize(h)
        return
    end
    local progress_bg = line:getwidget("progress_bg")
    if progress_bg ~= nil then
        local w, h = progress_bg:getsize()
        local progress_level1 = line:getwidget("progress_level1")
        local progress_level2 = line:getwidget("progress_level2")
        progress_bg:setsize(contentwidth, h)
        progress_level1:setsize(contentwidth, h)
        progress_level2:setsize(contentwidth, h)
        line:setsize(h)
        return
    end
end
function tips_getmainpositiony()
    if m_uitips_main:alive() then
        return m_uitips_main.positiony
    else
        return -1
    end
end
function tips_complete(screen_x, screen_y)
    local contentwidth = m_uitips_current.contentwidth
    for i=1,#m_uitips_current.adjustsplit do
        local line = m_uitips_current.adjustsplit[i]
        local image_split = line:getwidget("image_split")
        local w,h = image_split:getsize()
        image_split:setsize(contentwidth, h)
        line:setsize(h)
    end
    for i=1,#m_uitips_current.adjustdesc do
        tips_adjustdesc(m_uitips_current.adjustdesc[i], contentwidth)
    end
    for i=1,m_uitips_current.list_tips:getcount() do
        m_uitips_current.list_tips:getlinefromindex(i):addspace(10)
    end
    m_uitips_current.list_tips:updatecontentsize()

    local screenwidth, screenheight = c_system_screensize()
    local contentheight = m_uitips_current.list_tips:getcontentsize()
    local imagebgext = 25
    local imagebgwidth = math.min(contentwidth + imagebgext * 2.0, screenheight)
    local imagebgheight = math.min(contentheight + imagebgext * 2.0, screenheight)
    local image_bg = m_uitips_current:getwidget("tips_root/image_bg")
    image_bg:setvisible(true)
    image_bg:setsize(imagebgwidth, imagebgheight)
    m_uitips_current.list_tips:setposition(imagebgext, -imagebgext)
    m_uitips_current.list_tips:setlistsize(imagebgwidth - imagebgext, imagebgheight - imagebgext)

    local button_close = m_uitips_current:getwidget("tips_root/button_close")
    button_close:setvisible(true)
    button_close:setposition(imagebgwidth - 100, -100)
    button_close:setdelegate(tips_delegate_close)

    local button_extend = m_uitips_current:getwidget("tips_root/button_extend")
    button_extend:setvisible(false)

    if bit.band(m_uitips_current.flag, tipsflag.vleft) > 0 then
        screen_x = math.max(0.0, screen_x - imagebgwidth)
    else
        screen_x = math.min(screen_x, screenwidth - imagebgwidth)
    end
    if screen_y < 0 then
        screen_y = math.min(screenheight, screenheight / 2.0 + imagebgheight / 2.0)
    else
        screen_y = math.clamp(screen_y, imagebgheight, screenheight)
    end
    local tips_root = m_uitips_current:getwidget("tips_root")
    tips_root:setposition(screen_x, screen_y)
    m_uitips_current.tips_root = tips_root
    m_uitips_current.positionx = screen_x
    m_uitips_current.positiony = screen_y
    m_uitips_current.bgwidth = imagebgwidth
end

function tips_setextend(data)
    local button_extend = m_uitips_current:getwidget("tips_root/button_extend")
    button_extend:setvisible(true)
    button_extend:setposition(m_uitips_current.bgwidth - 260, -100)
    button_extend:setdelegate(tips_delegate_extend)
    button_extend.extenddata = data
end

function tips_adjustcompare()
    if m_uitips_compare1:null() and m_uitips_compare2:null() then
        return
    end
    local comparewidth = 0.0
    if m_uitips_compare1:alive() then
        comparewidth = comparewidth + m_uitips_compare1.bgwidth
    end
    if m_uitips_compare2:alive() then
        comparewidth = comparewidth + m_uitips_compare2.bgwidth
    end
    local totalwidth = m_uitips_main.bgwidth + comparewidth
    local screenwidth, screenheight = c_system_screensize()
    local screen_x = 0
    if bit.band(m_uitips_main.flag, tipsflag.vleft) > 0 then
        screen_x = math.max(0.0, m_uitips_main.positionx - comparewidth)
        local cutwidth = screenwidth * system_cutwidth
        screen_x = math.max(screen_x, math.min(cutwidth, screenwidth - totalwidth))
    else
        screen_x = math.min(m_uitips_main.positionx, screenwidth - totalwidth)
    end
    if m_uitips_compare1:alive() then
        m_uitips_compare1.tips_root:setposition(screen_x, m_uitips_compare1.positiony)
        screen_x = screen_x + m_uitips_compare1.bgwidth
    end
    if m_uitips_compare2:alive() then
        m_uitips_compare2.tips_root:setposition(screen_x, m_uitips_compare2.positiony)
        screen_x = screen_x + m_uitips_compare2.bgwidth
    end
    m_uitips_main.tips_root:setposition(screen_x, m_uitips_main.positiony)
end

function tips_delegate_extend(sender, event)
    sender:setvisible(false)
    local data = sender.extenddata
    if data.type == tipsextendtype.equip then
        tips_itemcompare(data.slot1, data.slot2, m_uitips_main._parent)
    elseif data.type == tipsextendtype.recipe then
        tips_addrecipeproduct(data.config_item, m_uitips_main._parent)
    end
end

function tips_delegate_close()
    tips_close()
end
