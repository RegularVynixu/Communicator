-- \\ Services // --

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")

-- \\ Variables // --

local LocalPlayer = Players.LocalPlayer
local TextChannels = TextChatService:WaitForChild("TextChannels") :: Folder
local RBXGeneral = TextChannels:WaitForChild("RBXGeneral") :: TextChannel

-- \\ Main // --

local Internal = {
	Frequency = "VynixuCommunicator",
	Connections = {} :: { [string]: RBXScriptConnection },
	Callbacks = {} :: { [string]: (Player, ...any?) -> () },
	Pings = {} :: { [string]: (Player) -> () }
}

local Communicator = {
	Config = {
		ExcludeSelf = true
	}
}

function Communicator:SetFrequency(freq: string)
	assert(freq:find("|") == nil, "Invalid frequency: character '|' is reserved.")
	Internal.Frequency = freq
end

function Communicator:Send(command: string, ...)
	local args = {...}
	for i, v in next, args do
		if typeof(v) == "string" then
			assert(v:find("|") == nil, `Invalid argument #{i}: character '|' is reserved.`)
		end
	end
	RBXGeneral:SendAsync("", `{Internal.Frequency}|{command}|{HttpService:JSONEncode(args)}`)
end

function Communicator:Listen(command: string, callback: (Player, ...any?) -> ())
	assert(typeof(callback) == "function", "Callback must be a function.")
	Internal.Callbacks[command] = callback
end

function Communicator:Ping(timeOut: number): { Player }
	timeOut = timeOut or 1
	local responders = {} :: { Player }

	if #Players:GetPlayers() > 1 then
		local t = tick()
		Internal.Pings["Pong_"..t] = function(sender: Player)
			responders[#responders + 1] = sender
		end

		self:Send("Ping_"..t)
		task.wait(timeOut)
		Internal.Pings["Pong_"..t] = nil
	end

	return responders
end

function Communicator:Destroy()
	for i, v in next, Internal.Connections do
		v:Disconnect()
		Internal.Connections[i] = nil
	end
	for i in next, Internal do
		Internal[i] = nil
	end
	for i in next, self do
		self[i] = nil
	end
end

Internal.Connections.MessageReceived = TextChatService.MessageReceived:Connect(function(message: TextChatMessage)
	local metadata = message.Metadata
	local textSource = message.TextSource
	local isLocal = textSource and textSource.UserId == LocalPlayer.UserId
	if
		not metadata
		or not textSource
		or (Communicator.Config.ExcludeSelf and isLocal)
	then
		return
	end

	local split = metadata:split("|")
	local frequency = split[1]
	if frequency ~= Internal.Frequency then return end

	local command = split[2]
	local args = HttpService:JSONDecode(split[3] or "[]")
	local sender: Player = Players:GetPlayerByUserId(textSource.UserId)

	if command:sub(1, 5) == "Ping_" and not isLocal then
		local id = command:sub(6)
		Communicator:Send("Pong_"..id)
		return
	elseif command:sub(1, 5) == "Pong_" then
		local callback = Internal.Pings[command]
		if typeof(callback) == "function" then
			callback(sender)
		end
		return
	end

	local callback = Internal.Callbacks[command]
	if typeof(callback) == "function" then
		callback(sender, unpack(args))
	end
end)

return Communicator