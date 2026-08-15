
include("skill/tabshortcut")
include("skill/tabnormal")
include("skill/tabstigma")
include("skill/tabpassive")
include("skill/tabcrafting")
include("skill/tabsocial")
include("skill/tabsystem")
include("skill/tabstigmaex")
include("skill/tabqte")
include("skill/tabpreset")
include("skill/presetsetting")
include("skill/skillsort")
include("skill/skillstigma")
include("skill/skillbarsetting")
include("skill/iconlink")

local skilltab =
{
    shortcut = 1,
    normal = 2,
    stigma = 3,
    passive = 4,
    crafting = 5,
    social = 6,
    system = 7,
    stigmaex = 8,
    qte = 9,
    preset = 10,
}
local m_skillmain_tab = skilltab.shortcut

m_uiskill_main = uipanel_createhandle("skill/skill_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)
local m_uiskill_main_inst = {desc = "skill/inst_desc"}

function skill_main_onopen()
    m_uiskill_main:setwidgetdelegate("button_shortcut", skill_main_delegate_shortcut)
    m_uiskill_main:setwidgetdelegate("button_normal", skill_main_delegate_normal)
    m_uiskill_main:setwidgetdelegate("button_stigma", skill_main_delegate_stigma)
    m_uiskill_main:setwidgetdelegate("button_passive", skill_main_delegate_passive)
    m_uiskill_main:setwidgetdelegate("button_crafting", skill_main_delegate_crafting)
    m_uiskill_main:setwidgetdelegate("button_social", skill_main_delegate_social)
    m_uiskill_main:setwidgetdelegate("button_system", skill_main_delegate_system)
    m_uiskill_main:setwidgetdelegate("button_stigmaex", skill_main_delegate_stigmaex)
    m_uiskill_main:setwidgetdelegate("button_qte", skill_main_delegate_qte)
    m_uiskill_main:setwidgetdelegate("button_preset", skill_main_delegate_preset)
    m_uiskill_main:setwidgetdelegate("image_bg/button_close", skill_main_delegate_close)

    m_skillmain_tab = skilltab.shortcut

    skill_tabshortcut_init()
    skill_tabnormal_init()
    skill_tabstigma_init()
    skill_tabpassive_init()
    skill_tabcrafting_init()
    skill_tabsocial_init()
    skill_tabsystem_init()
    skill_tabstigmaex_init()
    skill_tabqte_init()
    skill_tabpreset_init()

    skill_main_updateui()
end

function skill_main_setdesctext(tabname, name, desc)
    local text_skillname = m_uiskill_main:getwidget(tabname .. "/text_skillname")
    text_skillname:settext(name)

    local text_desc = m_uiskill_main:getwidget(tabname .. "/text_desc")
    text_desc:settext(desc)
end

function skill_main_setskilldescsplit(tabname, str)
    str = c_textformat(str)
    skill_main_setdesctext(tabname, csvconfig_getsubvalue(str, 1, configsubtype.str), csvconfig_getsubvalue(str, 2, configsubtype.str))
end

function skill_main_setskilldesc(tabname, config_skill, toplevel)
    if config_skill ~= nil then
        if toplevel then
            local config_toplevel = playerskill_gettoplevelavailable(config_skill)
            if config_toplevel ~= nil then
                config_skill = config_toplevel
            end
        end
        skill_main_setdesctext(tabname, config_skill.name, skilltext_getdesc(config_skill.desc, config_skill, nil, skilltextflag.spellcost))
    else
        skill_main_setdesctext(tabname, "", "")
    end
end

function skill_main_setpresetdesc(tabname, preset)
    if preset ~= nil then
        skill_main_setdesctext(tabname, preset.name, c_textformat("SKILL_SHORTCUT_PRESETDESC", preset.name))
    else
        skill_main_setdesctext(tabname, "", "")
    end
end

function skill_main_setsocialdesc(tabname, config_social)
    if config_social ~= nil then
        skill_main_setdesctext(tabname, config_social.name, "")
    else
        skill_main_setdesctext(tabname, "", "")
    end
end

function skill_main_setitemdesc(tabname, config_item)
    if config_item ~= nil then
        local itemdesc, itemspell = csvitem_getdesc(config_item)
        if itemdesc ~= nil then
            if #itemspell > 0 then
                itemdesc = itemdesc .. "\n" .. itemspell
            end
            skill_main_setdesctext(tabname, config_item.name, itemdesc)
        else
            skill_main_setdesctext(tabname, config_item.name, "")
        end
    else
        skill_main_setdesctext(tabname, "", "")
    end
end

function skill_main_updateui()
    if m_uiskill_main:null() then
        return
    end

    m_uiskill_main:setwidgetenable("button_shortcut", m_skillmain_tab ~= skilltab.shortcut)
    m_uiskill_main:setwidgetenable("button_normal", m_skillmain_tab ~= skilltab.normal)
    m_uiskill_main:setwidgetenable("button_stigma", m_skillmain_tab ~= skilltab.stigma)
    m_uiskill_main:setwidgetenable("button_passive", m_skillmain_tab ~= skilltab.passive)
    m_uiskill_main:setwidgetenable("button_crafting", m_skillmain_tab ~= skilltab.crafting)
    m_uiskill_main:setwidgetenable("button_social", m_skillmain_tab ~= skilltab.social)
    m_uiskill_main:setwidgetenable("button_system", m_skillmain_tab ~= skilltab.system)
    m_uiskill_main:setwidgetenable("button_stigmaex", m_skillmain_tab ~= skilltab.stigmaex)
    m_uiskill_main:setwidgetenable("button_qte", m_skillmain_tab ~= skilltab.qte)
    m_uiskill_main:setwidgetenable("button_preset", m_skillmain_tab ~= skilltab.preset)

    m_uiskill_main:setwidgetvisible("tab_shortcut", m_skillmain_tab == skilltab.shortcut)
    m_uiskill_main:setwidgetvisible("tab_normal", m_skillmain_tab == skilltab.normal)
    m_uiskill_main:setwidgetvisible("tab_stigma", m_skillmain_tab == skilltab.stigma)
    m_uiskill_main:setwidgetvisible("tab_passive", m_skillmain_tab == skilltab.passive)
    m_uiskill_main:setwidgetvisible("tab_crafting", m_skillmain_tab == skilltab.crafting)
    m_uiskill_main:setwidgetvisible("tab_social", m_skillmain_tab == skilltab.social)
    m_uiskill_main:setwidgetvisible("tab_system", m_skillmain_tab == skilltab.system)
    m_uiskill_main:setwidgetvisible("tab_stigmaex", m_skillmain_tab == skilltab.stigmaex)
    m_uiskill_main:setwidgetvisible("tab_qte", m_skillmain_tab == skilltab.qte)
    m_uiskill_main:setwidgetvisible("tab_preset", m_skillmain_tab == skilltab.preset)

    if m_skillmain_tab == skilltab.shortcut then
        skill_tabshortcut_updateui()
    elseif m_skillmain_tab == skilltab.normal then
        skill_tabnormal_updateui()
    elseif m_skillmain_tab == skilltab.stigma then
        skill_tabstigma_updateui()
    elseif m_skillmain_tab == skilltab.passive then
        skill_tabpassive_updateui()
    elseif m_skillmain_tab == skilltab.crafting then
        skill_tabcrafting_updateui()
    elseif m_skillmain_tab == skilltab.social then
        skill_tabsocial_updateui()
    elseif m_skillmain_tab == skilltab.system then
        skill_tabsystem_updateui()
    elseif m_skillmain_tab == skilltab.stigmaex then
        skill_tabstigmaex_updateui()
    elseif m_skillmain_tab == skilltab.qte then
        skill_tabqte_updateui()
    elseif m_skillmain_tab == skilltab.preset then
        skill_tabpreset_updateui()
    end
end

function skill_main_updatetabqte()
    if m_uiskill_main:alive() and m_skillmain_tab == skilltab.qte then
        skill_tabqte_updateui()
    end
end

function skill_main_delegate_shortcut()
    m_skillmain_tab = skilltab.shortcut
    skill_main_setdesctext("tab_shortcut", "", "")
    skill_main_updateui()
end

function skill_main_delegate_normal()
    m_skillmain_tab = skilltab.normal
    skill_main_setdesctext("tab_normal", "", "")
    skill_main_updateui()
end

function skill_main_delegate_stigma()
    m_skillmain_tab = skilltab.stigma
    skill_main_setdesctext("tab_stigma", "", "")
    skill_main_updateui()
end

function skill_main_delegate_passive()
    m_skillmain_tab = skilltab.passive
    skill_main_setdesctext("tab_passive", "", "")
    skill_main_updateui()
end

function skill_main_delegate_crafting()
    m_skillmain_tab = skilltab.crafting
    skill_main_setdesctext("tab_crafting", "", "")
    skill_main_updateui()
end

function skill_main_delegate_social()
    m_skillmain_tab = skilltab.social
    skill_main_setdesctext("tab_social", "", "")
    skill_main_updateui()
end

function skill_main_delegate_system()
    m_skillmain_tab = skilltab.system
    skill_main_setdesctext("tab_system", "", "")
    skill_main_updateui()
end

function skill_main_delegate_stigmaex()
    m_skillmain_tab = skilltab.stigmaex
    skill_main_setdesctext("tab_stigmaex", "", "")
    skill_main_updateui()
end

function skill_main_delegate_qte()
    m_skillmain_tab = skilltab.qte
    skill_main_setdesctext("tab_qte", "", "")
    skill_main_updateui()
end

function skill_main_delegate_preset()
    m_skillmain_tab = skilltab.preset
    skill_main_setdesctext("tab_preset", "", "")
    skill_main_updateui()
end

function skill_main_delegate_close()
    m_uiskill_main:close()
end
