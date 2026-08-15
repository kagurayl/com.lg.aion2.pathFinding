
function tips_skill(config_skill, x, y, flag, parent)
    tips_close()
    tips_create(flag, parent)
    tips_addtitle(config_skill.name, TIPS_COLOR_WHITE)
    local skilldesc = skilltext_getdesc(config_skill.desc, config_skill, nil, skilltextflag.spellcost)
    tips_adddesc(skilldesc, TIPS_COLOR_DESC)
    tips_complete(x, y)
end

function tips_social(config_social, x, y, flag, parent)
    tips_close()
    tips_create(flag, parent)
    tips_addtitle(config_social.name, TIPS_COLOR_WHITE)
    tips_adddesc(config_social.desc, TIPS_COLOR_DESC)
    tips_complete(x, y)
end
