# Communicator

A lightweight client-to-client communication module for Roblox built on top of TextChatService.

## Features

- Lightweight and easy to use
- No server infrastructure required
- Supports simple arguments
- Built-in ping system to detect other clients on the same frequency

## Limitations

- Both clients must have access to Roblox chat
- Arguments are limited to types that can be JSON-encoded (`string`, `number`, `boolean`)
- Not true peer-to-peer (messages still relay through Roblox servers)
- Any client or exploit that can send messages with the correct frequency and format can inject or spoof commands

## Usage

### Setting the Frequency

```lua
Communicator:SetFrequency("MyChannel")
```
Only clients using the same frequency will receive messages.

### Sending Commands

```lua
Communicator:Send("Test")
Communicator:Send("RandomNumber", math.random(1, 100))
```
Arguments are serialized using JSON.

### Listening For Commands

```lua
Communicator:Listen("Test", function(sender: Player)
    print(sender.DisplayName .. " sent Test command")
end)

Communicator:Listen("RandomNumber", function(sender: Player, rdmNum: number)
    print("Random number received:", rdmNum)
end)
```

### Pinging Listeners

Detect other clients on the same frequency:

```lua
local listeners = Communicator:Ping(1) -- wait 1 second
warn(#listeners, "clients detected on this frequency")
```

### Example

Detect clients using the Communicator module.
This example can be adapted to identify which users are running your script hub in-game.

```lua
-- Initialize the Communicator module
local Communicator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Communicator/main/init.luau"))()

-- Set the frequency
Communicator:SetFrequency("Example")

-- Listener: notify when someone is using Communicator
Communicator:Listen("USING_COMMUNICATOR", function(sender: Player)
	sender:SetAttribute("USING_COMMUNICATOR", true)
	print(sender.DisplayName .. " is using Communicator")
	
    -- Reply back
	Communicator:Send("USING_COMMUNICATOR_RESPONSE")
end)

-- Listener: handle response from other clients
Communicator:Listen("USING_COMMUNICATOR_RESPONSE", function(sender: Player)
	sender:SetAttribute("USING_COMMUNICATOR", true)
	print(sender.DisplayName .. " is using Communicator")
end)

-- Broadcast initial command
Communicator:Send("USING_COMMUNICATOR")
```