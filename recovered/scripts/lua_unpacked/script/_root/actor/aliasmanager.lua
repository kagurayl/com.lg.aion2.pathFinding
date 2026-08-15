
_animalias = _class("_animalias")

function aliasmanager_create(alias, flag, audiotypename, animspeed, timestart)
	if alias == nil then
		return
	end
	if alias.audiotype == nil then
		audiotypename = nil
	end
	if alias.audiofile == nil and alias.audiotype == nil and alias.attachmesh == nil and alias.vfx == nil then
		return
	end
	local timescale = 1.0 / animspeed
	local aliasplayer = {}
	aliasplayer.timestart = time_game - timestart
	aliasplayer.timescale = timescale
	aliasplayer.timeskip = timestart
	aliasplayer.flag = flag
	aliasplayer.audiotypename = audiotypename

	if bit.band(flag, actorrenderflag.disablealiasaudio) == 0 then
		if alias.audiotype ~= nil then
			aliasplayer.audio = {}
			for i=1,#alias.audiotype do
				local audiotype = alias.audiotype[i]
				local audio = {}
				audio.audiotype = audiotype
				audio.time = audiotype.time * timescale
				audio.loop = audiotype.loop
				aliasplayer.audio[#aliasplayer.audio + 1] = audio
			end
		end
		if alias.audiofile ~= nil then
			if aliasplayer.audio == nil then
				aliasplayer.audio = {}
			end
			for i=1,#alias.audiofile do
				local audiofile = alias.audiofile[i]
				local audio = {}
				audio.audiofile = audiofile
				audio.time = audiofile.time * timescale
				audio.loop = audiofile.loop
				aliasplayer.audio[#aliasplayer.audio + 1] = audio
			end
		end
	end
	if alias.attachmesh ~= nil then
		aliasplayer.mesh = {}
		for i=1,#alias.attachmesh do
			local attachmesh = alias.attachmesh[i]
			local animmesh = {}
			animmesh.attach = attachmesh.time * timescale
			animmesh.detach = attachmesh.detach * timescale
			animmesh.mesh = attachmesh.mesh
			animmesh.bone = attachmesh.bone
			aliasplayer.mesh[#aliasplayer.mesh + 1] = animmesh
		end
	end
	if alias.vfx ~= nil then
		aliasplayer.vfx = {}
		for i=1,#alias.vfx do
			local vfx = alias.vfx[i]
			local animvfx = {}
			animvfx.attach = vfx.time * timescale
			animvfx.name = vfx.name
			animvfx.bone = vfx.bone
			animvfx.x = vfx.x
			animvfx.y = vfx.y
			animvfx.z = vfx.z
			aliasplayer.vfx[#aliasplayer.vfx + 1] = animvfx
		end
	end
	return aliasplayer
end

function aliasmanager_destory(aliasplayer)
	if aliasplayer.mesh ~= nil then
		for i=1,#aliasplayer.mesh do
			local animmesh = aliasplayer.mesh[i]
			if animmesh.meshactor ~= nil then
				animmesh.meshactor:destroyactor()
				animmesh.meshactor = nil
			end
		end
	end
	if aliasplayer.vfx ~= nil then
		for i=1,#aliasplayer.vfx do
			local vfx = aliasplayer.vfx[i]
			if vfx.vfx ~= nil then
				vfx.vfx:setfade()
				vfx.vfx = nil
			elseif vfx.vfxarray ~= nil then
				for j=1,#vfx.vfxarray do
					vfx.vfxarray[j]:setfade()
				end
				vfx.vfxarray = nil
			end
		end
	end
	if aliasplayer.audio ~= nil then
		for i=1,#aliasplayer.audio do
			local audio = aliasplayer.audio[i]
			if audio.scriptid ~= nil then
				if audio.loop or bit.band(aliasplayer.flag, actorrenderflag.syncstopaudio) ~= 0 then
					audiomanager_stopaudio(audio.scriptid)
					audio.scriptid = nil
				end
			end
		end
	end
end

function aliasmanager_loopclear(aliasplayer)
	aliasplayer.timeskip = 0.0
	if aliasplayer.vfx ~= nil then
		for i=1,#aliasplayer.vfx do
			local vfx = aliasplayer.vfx[i]
			if vfx.vfx ~= nil then
				if not vfx.vfx:getloop() then
					vfx.restart = true
				end
			elseif vfx.vfxarray ~= nil then
				if not vfx.vfxarray[1]:getloop() then
					vfx.restart = true
				end
			end
		end
	end
	if aliasplayer.audio ~= nil then
		for i=1,#aliasplayer.audio do
			local audio = aliasplayer.audio[i]
			if audio.scriptid ~= nil and not audio.loop then
				audio.scriptid = 0
			end
		end
	end
end

function aliasmanager_update(aliasplayer, actor, entity)
	if scene_isloading() then
		return
	end
	if actor ~= nil and actor.actordata ~= nil and not actor.actordata.assetvisible then
		return
	end
	local animtime = time_game - aliasplayer.timestart
	if bit.band(aliasplayer.flag, actorrenderflag.loopanim) ~= 0 then
		if aliasplayer.timeloop == nil or aliasplayer.timeloop < time_game then
			local position, length
			if actor ~= nil then
				position, length = c_actor_getanimposition(actor.id, 0)
			else
				position, length = c_entity_getanimposition(entity.entityid)
			end
			if length > 0 then
				position = math.fmod(position, length)
				if aliasplayer.timeloop ~= nil then
					aliasmanager_loopclear(aliasplayer)
				end
				aliasplayer.timestart = time_game - position
				aliasplayer.timeloop = aliasplayer.timestart + length
				animtime = position
			end
		end
	end
	if aliasplayer.audio ~= nil then
		for i=1,#aliasplayer.audio do
			local audio = aliasplayer.audio[i]
			if audio.time >= aliasplayer.timeskip and audio.time <= animtime and (audio.scriptid == nil or audio.scriptid == 0) then
				local flag = 0
				if audio.loop then
					flag = audioflag.loop
				end
				if audio.audiotype ~= nil then
					if actor ~= nil then
						local audiotype = audio.audiotype
						if audiotype.type == "walk" then
							--actor:playeventaudio(audiotype.type, nil, actor.transform.physicmaterial, actor.transform.px, actor.transform.py, actor.transform.pz)
						elseif actor.attr ~= nil then
							audio.scriptid = audiomanager_playactorvoice(actor, audiotype.type, audiotype.volume, audiotype.inradius, audiotype.outradius, aliasplayer.audiotypename, audiopriority.high)
						end
					end
				else
					local audiofile = audio.audiofile
					if actor ~= nil then
						audio.scriptid = audiomanager_playactoraudio(actor, audiofile.file, flag,  audiofile.volume, audiofile.inradius, audiofile.outradius, audiochanneltype.skill, audiopriority.high)
					else
						audio.scriptid = audiomanager_playaudio3d(audiofile.file, flag, entity.px, entity.py, entity.pz, audiofile.volume, audiofile.inradius, audiofile.outradius, audiochanneltype.skill, audiopriority.low)
					end
				end
			end
		end
	end
	if aliasplayer.mesh ~= nil then
		for i=1,#aliasplayer.mesh do
			local animmesh = aliasplayer.mesh[i]
			if animmesh.detach >= 0.0 and animmesh.detach <= animtime then
				if animmesh.meshactor ~= nil then
					animmesh.meshactor:destroyactor()
					animmesh.meshactor = nil
				end
			elseif animmesh.attach >= 0.0 and animmesh.attach <= animtime then
				if animmesh.meshactor == nil then
					local meshfile = nil
					if string.endwith(animmesh.mesh, ".cgf") then
						meshfile = string.format("%s.prefab", animmesh.mesh)
					elseif animmesh.mesh == "wing" then
						actor.actordata.winganimvisible = true
					elseif animmesh.mesh == "arrow" then
						if actor.attr.config_weapon2 ~= nil and actor.attr.config_weapon2.itemtype == csvitemtype.weapon_sub then
							meshfile = string.format("objects/items/%s.cgf.prefab", actor.attr.config_weapon.mesh)
						else
							meshfile = "objects/items/702_testarrow.cgf.prefab"
						end
					end
					if meshfile ~= nil then
						animmesh.meshactor = _actorclass.new()
						animmesh.meshactor.renderlayer = actor.renderlayer
						animmesh.meshactor:settransform(0, 0, 0, 0, 0, 0, 1, 1, 1)
						animmesh.meshactor:createactor(0, string.format("animmesh_%d", i))
						animmesh.meshactor:loadbprender(meshfile)
						if actor ~= nil then
							animmesh.meshactor:bindactor(actor, animmesh.bone, 0, 0)
						else
							animmesh.meshactor:setpositionrotation(entity.px, entity.py, entity.pz, entity.rx, entity.ry, entity.rz)
							animmesh.meshactor:setscale(entity.sx, entity.sy, entity.sz)
						end
					end
				end
			end
		end
	end
	if aliasplayer.vfx ~= nil then
		for vfxindex=1,#aliasplayer.vfx do
			local vfx = aliasplayer.vfx[vfxindex]
			if vfx.attach >= aliasplayer.timeskip and vfx.attach <= animtime then
				if vfx.vfx == nil and vfx.vfxarray == nil then
					local bonegroup = nil
					if actor ~= nil and vfx.bone ~= nil and actor.actordata.skillbone ~= nil then
						bonegroup = actor.actordata.skillbone[vfx.bone]
					end
					if bonegroup ~= nil and #bonegroup > 0 then
						vfx.vfxarray = {}
						for j=1, #bonegroup do
							vfx.vfxarray[j] = vfxmanager_createvfx(vfx.name)
							vfx.vfxarray[j]:setbind(actor, bonegroup[j], vfxflag.bindposition)
						end
					else
						vfx.vfx = vfxmanager_createvfx(vfx.name)
						if actor ~= nil then
							vfx.vfx:setbind(actor, vfx.bone, vfxflag.bindposition)
						else
							vfx.vfx:setpositionrotation(entity.px, entity.py, entity.pz, entity.rx, entity.ry, entity.rz)
							vfx.vfx:setscale(entity.sx, entity.sy, entity.sz)
						end
					end
				elseif vfx.restart then
					vfx.restart = false
					if vfx.vfx ~= nil then
						vfx.vfx:restart()
					elseif vfx.vfxarray ~= nil then
						for j=1,#vfx.vfxarray do
							vfx.vfxarray[j]:restart()
						end
					end
				end
			end
		end
	end
end
