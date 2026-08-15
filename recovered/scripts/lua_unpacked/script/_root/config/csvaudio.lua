
local m_csv_audio = nil

function csvaudio_load()
    m_csv_audio = {}
    local audiofile = c_config_loadscripttable(csvconfig_filename("audio_file"))
    for key, val in pairs(audiofile) do
		val.volume = val.volume / 100.0
	end
    local audioevent = c_config_loadscriptarray(csvconfig_filename("audio_event"))
    for i=1,#audioevent do
        local evt = audioevent[i]
        local audio = m_csv_audio[evt.evt]
        if audio == nil then
            audio = {}
            audio.evt = {}
            m_csv_audio[evt.evt] = audio
        end
        local src = audio[evt.src]
        if src == nil then
            src = {}
            audio[evt.src] = src
        end
        local dst = {}
        local subfile = string.split(evt.file, ";")
        for j=1,#subfile do
            local data = string.split(subfile[j], ",")
            local file = {}
            file.file = audiofile[string.tointeger(data[1])]
            file.prob = string.tointeger(data[2])
            dst[#dst + 1] = file
        end
        src[evt.dst] = dst
    end
end

function csvaudio_getevent(evtname)
    return m_csv_audio[evtname]
end
