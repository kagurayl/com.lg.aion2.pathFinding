
function _actorclass:movesetnpcmovesync(px, py, pz, speed, animname)
	if speed <= 0.0 then
		self.move.sync_npcmovespeed = 0.0
		return
	end
	self.move.sync_npcmovespeed = speed
	self.move.sync_npcmovetimestart = time_game
	self.move.sync_npcmovetimelength = vector3_distance(px, py, pz, self.attr.posx, self.attr.posy, self.attr.posz) / speed
	self.move.sync_npcmovestartx = self.attr.posx
	self.move.sync_npcmovestarty = self.attr.posy
	self.move.sync_npcmovestartz = self.attr.posz
	self.move.sync_npcmovedestx = px
	self.move.sync_npcmovedesty = py
	self.move.sync_npcmovedestz = pz
	self.move.sync_npcmoverot = vector2_angle3d(vector2_normalize(px - self.attr.posx, pz - self.attr.posz))
	self.move.sync_npcmoveanim = animname
end

function _actorclass:movenpcmove()
	if self:moveplayerupdatemovedest() then
		return
	end
	if self.move.sync_npcmovespeed ~= nil and self.move.sync_npcmovespeed ~= 0.0 and self.move.sync_npcmovetimelength ~= 0 then
		local t = (time_game - self.move.sync_npcmovetimestart) / self.move.sync_npcmovetimelength
		if t > 1.0 then
			t = 1.0
		end
		local px = math.lerp(self.move.sync_npcmovestartx, self.move.sync_npcmovedestx, t)
		local py = math.lerp(self.move.sync_npcmovestarty, self.move.sync_npcmovedesty, t)
		local pz = math.lerp(self.move.sync_npcmovestartz, self.move.sync_npcmovedestz, t)
		self:setactorposition(px, py, pz, self.move.sync_npcmoverot)
	end
end
