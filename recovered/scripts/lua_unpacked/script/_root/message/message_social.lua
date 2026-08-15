
function SC_SocialList(msg)
    playerattr_social = {}
    for i=1,#msg.socialid do
        playerattr_social[msg.socialid[i]] = msg.socialid[i]
    end
end

function SC_SocialAdd(msg)
    playerattr_social[msg.socialid] = msg.socialid
    local config_social = csvskillsocial_getfromid(msg.socialid)
    if config_social ~= nil then
        chat_addsystemalert(textformat_args("STR_MSG_GET_CASH_SOCIALACTION", config_social.name))
    end
end

function SC_Social(msg)
    local actor = actormanager_getfromactorid(msg.attacker)
    if actor ~= nil then
        actor:clearspell()
        local config_social = csvskillsocial_getfromid(msg.skillid)
        if config_social ~= nil then
            actor.actionmain.spelltype = playerspellstate.spellsocial
            actor.actionmain.config_skill = config_social
            local srcname = nil
            local dstname = nil
            if actor:isme() then
                srcname = c_textformat("UI_ME")
            else
                srcname = actor.attr.name
            end
            if msg.target ~= 0 and msg.target ~= msg.attacker then
                local target = actormanager_getfromactorid(msg.target)
                if target ~= nil then
                    if target:isme() then
                        dstname = c_textformat("UI_ME")
                    else
                        dstname = target.attr.name
                    end
                end
            end
            if dstname ~= nil then
                chat_addsimple(chatchanneltype.chatemoji, textformat_raw(config_social.messagetarget, srcname, dstname))
            else
                chat_addsimple(chatchanneltype.chatemoji, textformat_raw(config_social.message, srcname))
            end
        end
    end
end

function SC_AnimCardList(msg)
    playerattr_animcard = {}
    for i=1,#msg.cardid do
        playerattr_animcard[msg.cardid[i]] = msg.expiredate[i]
    end
end

function SC_AnimCardAdd(msg)
    for i=1,#msg.cardid do
        local config_animcard = csvanimcard_getfromid(msg.cardid[i])
        if config_animcard ~= nil then
            chat_addsystemalert(textformat_args("STR_MSG_GET_CASH_CUSTOMIZE_MOTION", config_animcard.name))
        end
        playerattr_animcard[msg.cardid[i]] = msg.expiredate[i]
    end
end

function SC_AnimCard(msg)
    local actor = actormanager_getfromactorid(msg.actor)
    if actor ~= nil then
        if msg.type == csvanimcardtype.idle then
            actor.attr.animidle = msg.cardid
            actor.attr.animidlekey = csvanimcard_getkey(actor.attr.animidle)
            local action = actionmanager_getactionid(actor)
            if action ~= nil and action == actionname.idle then
                actionmanager_reload(actor)
            end
        elseif msg.type == csvanimcardtype.run then
            actor.attr.animrun = msg.cardid
            actor.attr.animrunkey = csvanimcard_getkey(actor.attr.animrun)
            local action = actionmanager_getactionid(actor)
            if action ~= nil and action == actionname.move then
                actionmanager_reload(actor)
            end
        elseif msg.type == csvanimcardtype.jump then
            actor.attr.animjump = msg.cardid
            actor.attr.animjumpkey = csvanimcard_getkey(actor.attr.animjump)
        elseif msg.type == csvanimcardtype.rest then
            actor.attr.animrest = msg.cardid
            actor.attr.animrestkey = csvanimcard_getkey(actor.attr.animrest)
            local action = actionmanager_getactionid(actor)
            if action ~= nil and action == actionname.idle then
                actionmanager_reload(actor)
            end
        end
        if actor:isme() then
            player_main_updateui()
        end
    end
end

function SC_AnimExpire(msg)
    playerattr_animcard[msg.cardid] = nil
    player_main_updateui()
    local config_animcard = csvanimcard_getfromid(msg.cardid)
    if config_animcard ~= nil then
        chat_addsystemalert(textformat_args("STR_MSG_DELETE_CASH_CUSTOMANIMATION_BY_TIMEOUT", config_animcard.name))
    end
end
