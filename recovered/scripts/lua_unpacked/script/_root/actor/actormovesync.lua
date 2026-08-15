
function _actorclass:moveplayersetmovedest(px, py, pz, time)
	if time <= 0.0 then
		self.move.sync_recvmovedesttime = nil
		return
	end
	self.move.sync_recvmovedesttime = time
	self.move.sync_recvmovedesttimestart = time_game
	self.move.sync_recvmovedeststartx = self.attr.posx
	self.move.sync_recvmovedeststarty = self.attr.posy
	self.move.sync_recvmovedeststartz = self.attr.posz
	self.move.sync_recvmovedestdestx = px
	self.move.sync_recvmovedestdesty = py
	self.move.sync_recvmovedestdestz = pz
	self.move.sync_recvmovedestrot = vector2_angle3d(vector2_normalize(px - self.attr.posx, pz - self.attr.posz))
end

function _actorclass:moveplayerupdatemovedest()
	if self.move.sync_recvmovedesttime ~= nil then
		local t = (time_game - self.move.sync_recvmovedesttimestart) / self.move.sync_recvmovedesttime
		if t > 1.0 then
			t = 1.0
			self.move.sync_recvmovedesttime = nil
		end
		local px = math.lerp(self.move.sync_recvmovedeststartx, self.move.sync_recvmovedestdestx, t)
		local py = math.lerp(self.move.sync_recvmovedeststarty, self.move.sync_recvmovedestdesty, t)
		local pz = math.lerp(self.move.sync_recvmovedeststartz, self.move.sync_recvmovedestdestz, t)
		self:setactorposition(px, py, pz, self.move.sync_recvmovedestrot)
		self.move.framevelocity = 0.0
		return true
	end
	return false
end
