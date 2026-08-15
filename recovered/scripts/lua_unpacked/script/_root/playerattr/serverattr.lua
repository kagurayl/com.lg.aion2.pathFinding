
serverattr_abysscastle = nil
serverattr_abyssartifact = nil

function serverattr_clear()
	serverattr_abysscastle = {}
	serverattr_abyssartifact = {}
end

function serverattr_set(msg)
	for i=1,#msg.abyss do
		local serverabyss = msg.abyss[i]
		local abyss = {}
		abyss.id = serverabyss.id
		abyss.civ = serverabyss.civ
		abyss.mist = serverabyss.mist
		abyss.teleport = serverabyss.teleport
		abyss.shield = serverabyss.shield
		if serverabyss.carrier > 0 then
			abyss.carrier = time_game + serverabyss.carrier
		else
			abyss.carrier = 0
		end
		serverattr_abysscastle[abyss.id] = abyss
	end
	for i=1,#msg.artifact do
		local artifact = {}
		artifact.id = msg.artifact[i]
		artifact.civ = msg.artifactciv[i]
		serverattr_abyssartifact[artifact.id] = artifact
	end
end

function serverattr_update()
	for key, val in pairs(serverattr_abysscastle) do
		sceneentity_updatecastleshield(val)
	end
end
