if onServer() then

function initialize()
	player = Player()
	local distanceFromCenter = length(vec2(Sector():getCoordinates()))
	player:sendChatMessage("Server", 0, "Distance from core : "..distanceFromCenter)
	terminate()
end

end
