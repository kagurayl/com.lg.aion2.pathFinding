
audiochanneltype = 
{
	ui = "ScriptUI",
    alert = "ScriptAlert",
    skill = "ScriptVFX",
    voice = "ScriptVoice",
    envsfx = "EnvSFX",
}

audiopriority = 
{
    veryhigh = 10,
    high = 20,
    normal = 30,
    low = 160,
}

audioflag = 
{
	loop = 0x1,
}

local audiostate = 
{
	playing = 0x1,
    loop = 0x2,
}

local m_audiomanager_ambientarray = nil
local m_audiomanager_ambientid = nil
local m_audiomanager_musicid = nil
local m_audiomanager_musicfile = nil
local m_audiomanager_voicedirectory = nil
local m_audiomanager_preloaddirectory = nil
local m_audiomanager_preloadaudio = nil
local m_audiomanager_playframe = {}
local m_audiomanager_musicposition = {}

local function audiomanager_addpreload(path)
    m_audiomanager_preloaddirectory[#m_audiomanager_preloaddirectory + 1] = path
end
function audiomanager_init()
    m_audiomanager_voicedirectory = {}
    m_audiomanager_voicedirectory["vattack1"] = "attack"
    m_audiomanager_voicedirectory["vattack2"] = "attack"
    m_audiomanager_voicedirectory["vattack3"] = "attack"
    m_audiomanager_voicedirectory["vattack4"] = "attack"
    m_audiomanager_voicedirectory["vattack4"] = "attack"
    m_audiomanager_voicedirectory["vcast"] = "cast"
    m_audiomanager_voicedirectory["vdamage1"] = "damage"
    m_audiomanager_voicedirectory["vdamage2"] = "damage"
    m_audiomanager_voicedirectory["vdamage3"] = "damage"
    m_audiomanager_voicedirectory["vdefence"] = "defence"
    m_audiomanager_voicedirectory["vlogin1"] = "login"
    m_audiomanager_voicedirectory["vlogin2"] = "login"
    m_audiomanager_voicedirectory["vmotion"] = "motion"
    m_audiomanager_voicedirectory["vsocial"] = "social"

    m_audiomanager_preloaddirectory = {}
    m_audiomanager_preloadaudio = {}
    audiomanager_addpreload("sounds/ui/")
    audiomanager_addpreload("sounds/system/")
    audiomanager_addpreload("sounds/attack/")
    audiomanager_addpreload("sounds/step/")
    audiomanager_addpreload("sounds/motion/voice/voice_male/attack_long")
    audiomanager_addpreload("sounds/motion/voice/voice_male/attack_middle")
    audiomanager_addpreload("sounds/motion/voice/voice_male/attack_short")
    audiomanager_addpreload("sounds/motion/voice/voice_male/cast")
    audiomanager_addpreload("sounds/motion/voice/voice_male/damage")
    audiomanager_addpreload("sounds/motion/voice/voice_male/defence")
    audiomanager_addpreload("sounds/motion/voice/voice_female/attack_long")
    audiomanager_addpreload("sounds/motion/voice/voice_female/attack_middle")
    audiomanager_addpreload("sounds/motion/voice/voice_female/attack_short")
    audiomanager_addpreload("sounds/motion/voice/voice_female/cast")
    audiomanager_addpreload("sounds/motion/voice/voice_female/damage")
    audiomanager_addpreload("sounds/motion/voice/voice_female/defence")
end

function audiomanager_preload(path)
    if path == nil or m_audiomanager_preloadaudio[path] ~= nil then
        return
    end
    for i=1,#m_audiomanager_preloaddirectory do
        if string.startwith(path, m_audiomanager_preloaddirectory[i]) then
            csvasset_preload(path)
            m_audiomanager_preloadaudio[path] = path
            break
        end
    end
end

function audiomanager_playmusic(filepath, fadein, flag)
    if m_audiomanager_musicfile == filepath then
        return
    end
    audiomanager_stopmusic()
    m_audiomanager_musicid = csvconfig_generatescriptid()
    m_audiomanager_musicfile = filepath
    local seek = 0.0
    local position = m_audiomanager_musicposition[m_audiomanager_musicfile]
    if position ~= nil then
        m_audiomanager_musicposition[m_audiomanager_musicfile] = nil
        if time_game - position.timestop < 30 then
            seek = position.musicposition
        end
    end
    c_audio_play2d(m_audiomanager_musicid, flag, 0, 1.0, 0.0, fadein, seek, "ScriptMusic", filepath)
end

function audiomanager_musicplaying()
    if m_audiomanager_musicid ~= nil then
        local state = c_audio_state(m_audiomanager_musicid)
        if bit.band(state, audiostate.playing) ~= 0 then
            return true
        end
    end
    return false
end

function audiomanager_clearseek()
    m_audiomanager_musicposition = {}
end

function audiomanager_stopmusic()
    if m_audiomanager_musicid ~= nil then
        local state, timeposition, timelength = c_audio_state(m_audiomanager_musicid)
        if bit.band(state, audiostate.playing) ~= 0 and timelength > 30.0 and timeposition + 30.0 < timelength then
            local position = {}
            position.timestop = time_game
            position.musicposition = timeposition
            m_audiomanager_musicposition[m_audiomanager_musicfile] = position
        else
            m_audiomanager_musicposition[m_audiomanager_musicfile] = nil
        end
        c_audio_stop(m_audiomanager_musicid, 2.0)
    end
    m_audiomanager_musicid = nil
    m_audiomanager_musicfile = nil
end

function audiomanager_stopaudio(scriptid)
    c_audio_stop(scriptid, 1.0)
end

function audiomanager_setrepeatframe(filepath, frame)
    m_audiomanager_playframe[filepath] = time_framecount + frame
end

function audiomanager_repeatplayable(filepath)
    if m_audiomanager_playframe[filepath] == nil or m_audiomanager_playframe[filepath] < time_framecount then
        m_audiomanager_playframe[filepath] = time_framecount
        return true
    end
    return false
end

function audiomanager_playaudioui(filepath)
    local scriptid = csvconfig_generatescriptid()
    if audiomanager_repeatplayable(filepath) then
        audiomanager_preload(filepath)
        c_audio_play2d(scriptid, 0, audiopriority.veryhigh, 1.0, 0.0, 0.0, 0.0, audiochanneltype.ui, filepath)
    end
    return scriptid
end

function audiomanager_playaudio2d(filepath, type, priority)
    local scriptid = csvconfig_generatescriptid()
    if audiomanager_repeatplayable(filepath) then
        audiomanager_preload(filepath)
        c_audio_play2d(scriptid, 0, priority, 1.0, 0.0, 0.0, 0.0, type, filepath)
    end
    return scriptid
end

function audiomanager_playaudio3d(filepath, flag, x, y, z, volume, inradius, outradius, type, priority)
    local scriptid = csvconfig_generatescriptid()
    audiomanager_preload(filepath)
    c_audio_play3d(scriptid, flag, priority, volume, inradius, outradius, type, filepath, x, y, z)
    return scriptid
end

function audiomanager_playactoraudio(actor, filepath, flag, volume, inradius, outradius, type, priority)
    local scriptid = csvconfig_generatescriptid()
    audiomanager_preload(filepath)
    c_audio_playactor(scriptid, flag, priority, volume, inradius, outradius, type, filepath, actor.id, nil)
    return scriptid
end

function audiomanager_getvoicetype(type)
    if type == 1 then
        return "b"
    elseif type == 2 then
        return "c"
    elseif type == 3 then
        return "d"
    else
        return "a"
    end
end

function audiomanager_playactorvoice(actor, type, volume, inradius, outradius, name, priority)
    local sex = math.ternary(actor.attr.sex == playersex.male, "m", "f")
    local civ = math.ternary(actor.attr.civ == playerciv.light, "l", "d")
    local morph = audiomanager_getvoicetype(actor.attr.voice)
    if type == "login1" then
        type = "vlogin1"
        name = actoranimcareer[actor.attr.career]
    elseif type == "login2" then
        type = "vlogin2"
        name = actoranimcareer[actor.attr.career]
    end
    local dir = m_audiomanager_voicedirectory[type]
    local filepath = nil
    if name == nil then
        if type == "vattack1" then
            name = string.format("%d", math.random(1, 6))
        elseif type == "vattack2" then
            name = string.format("%d", math.random(1, 4))
        elseif type == "vattack3" then
            name = string.format("%d", math.random(1, 3))
        elseif type == "vattack4" then
            name = string.format("%d", math.random(1, 2))
        else
            name = string.format("%d", math.random(1, 4))
        end
    end
    if type == "vsocial" then
        filepath = string.format("sounds/voice/%s/%s_%s_%s%s%s.ogg", dir, type, name, sex, civ, morph)
    elseif type == "vlogin1" or type == "vlogin2" then
        filepath = string.format("sounds/voice/%s/%s_%s_%s%s%s.ogg", dir, type, name, sex, civ, morph)
    else
        filepath = string.format("sounds/voice/%s/%s_%s%s%s_%s.ogg", dir, type, sex, civ, morph, name)
    end
    if actor:isme() then
        return audiomanager_playaudio2d(filepath, audiochanneltype.voice, priority)
    else
        return audiomanager_playactoraudio(actor, filepath, 0, volume, inradius, outradius, audiochanneltype.voice, priority)
    end
end

local function audiomanager_playambient()
    if m_audiomanager_ambient == nil then
        return
    end
    local index = math.random(1, #m_audiomanager_ambient)
    local path = m_audiomanager_ambient[index]
    m_audiomanager_ambientid = csvconfig_generatescriptid()
    local flag = 0
    if #m_audiomanager_ambient == 1 then
        flag = audioflag.loop
    end
    c_audio_play2d(m_audiomanager_ambientid, flag, 0, 1.0, 0.0, 0.5, 0.0, "EnvMusic", path)
end

function audiomanager_setambient(musicarray)
    if m_audiomanager_ambientid ~= nil then
        c_audio_stop(m_audiomanager_ambientid, 1.0)
        m_audiomanager_ambientid = nil
    end
    m_audiomanager_ambient = musicarray
    audiomanager_playambient()
end

function audiomanager_setvolume(name, volume)
    local db = math.log(math.clamp(volume, 0.01, 1.0), 10) * 40
    c_audio_setmixer(name, db)
end

function audiomanager_update()
    if m_audiomanager_ambient == nil then
        return
    end
    if m_audiomanager_ambientid ~= nil then
        local state = c_audio_state(m_audiomanager_ambientid)
        if state == 0 then
            m_audiomanager_ambientid = nil
        end
    end
    if m_audiomanager_ambientid == nil then
        audiomanager_playambient()
    end
end

function audiomanager_updatelistener()
    if cgmask_playing() then
        return
    end
    local px, py, pz
    if m_me ~= nil then
        px = m_me.transform.px
        py = m_me.transform.py + 1.5
        pz = m_me.transform.pz
    else
        px, py, pz = maincamera_getposition()
    end
    local rx, ry, rz = maincamera_getrotation()
    c_audio_listener(px, py, pz, 0, ry, 0)
end

function audiomanager_updatevolume()
    audiomanager_setvolume("EnvMusicVolume", gamesetting_getnumberdata("ENVMUSICVOLUME"))
    audiomanager_setvolume("EnvSFXVolume", gamesetting_getnumberdata("ENVSOUNDVOLUME"))
    audiomanager_setvolume("ScriptMusicVolume", gamesetting_getnumberdata("MUSICVOLUME"))
    audiomanager_setvolume("ScriptUIVolume", gamesetting_getnumberdata("UIVOLUME"))
    audiomanager_setvolume("ScriptVFXVolume", gamesetting_getnumberdata("SKILLVOLUME"))
    audiomanager_setvolume("ScriptVoiceVolume", gamesetting_getnumberdata("VOICEVOLUME"))
    audiomanager_setvolume("ScriptAlertVolume", gamesetting_getnumberdata("ALERTVOLUME"))
    audiomanager_setvolume("MasterVolume",  gamesetting_getnumberdata("DEVICEVOLUME"))
end
