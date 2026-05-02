local Players = game:GetService("Players")
local player = Players.LocalPlayer

local data = player:WaitForChild("Data", 10)
local beli = data and data:WaitForChild("Beli", 10)

if not beli then
	warn("No Beli found")
	return
end

-- CONFIG
local MAX_SPIKE = 10_000_000
local LOG_INTERVAL = 300 -- 5 phút

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FarmStatsGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 90, 160)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Parent = gui

-- bo góc frame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

-- glow nhẹ
local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(120, 200, 255)
stroke.Transparency = 0.4
stroke.Parent = frame

-- text
local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, -10, 0, 140)
text.Position = UDim2.new(0, 5, 0, 5)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.fromRGB(200, 240, 255)
text.Font = Enum.Font.Code
text.TextSize = 14
text.TextXAlignment = Enum.TextXAlignment.Left
text.TextYAlignment = Enum.TextYAlignment.Top
text.Parent = frame

-- input
local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -10, 0, 30)
input.Position = UDim2.new(0, 5, 1, -35)
input.BackgroundColor3 = Color3.fromRGB(20, 60, 120)
input.BackgroundTransparency = 0.2
input.TextColor3 = Color3.fromRGB(255,255,255)
input.PlaceholderText = "Target Beli..."
input.Font = Enum.Font.Code
input.TextSize = 14
input.BorderSizePixel = 0
input.Parent = frame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 10)
inputCorner.Parent = input

-- logic
local startTime = os.clock()
local lastBeli = beli.Value
local gainedTotal = 0
local target = 0

local function formatTime(sec)
	if sec == math.huge then return "∞" end
	local h = math.floor(sec / 3600)
	local m = math.floor((sec % 3600) / 60)
	local s = math.floor(sec % 60)
	return string.format("%02d:%02d:%02d", h, m, s)
end

input.FocusLost:Connect(function()
	target = tonumber(input.Text) or 0
end)

beli:GetPropertyChangedSignal("Value"):Connect(function()
	local now = beli.Value
	local diff = now - lastBeli

	if diff > 0 and diff < MAX_SPIKE then
		gainedTotal += diff
	end

	if diff >= 0 then
		lastBeli = now
	end
end)

-- LOG SYSTEM
local function writeLog()
	local t = os.date("%Y-%m-%d %H:%M:%S")
	local line = string.format("[%s] Beli: %d\n", t, beli.Value)

	print(line)

	if writefile then
		local file = "beli_log.txt"
		if isfile and isfile(file) then
			appendfile(file, line)
		else
			writefile(file, line)
		end
	end
end

task.spawn(function()
	while task.wait(LOG_INTERVAL) do
		writeLog()
	end
end)

-- UI update loop
task.spawn(function()
	while task.wait(1) do
		local elapsed = os.clock() - startTime
		local perHour = elapsed > 0 and (gainedTotal / elapsed) * 3600 or 0

		local current = beli.Value
		local remaining = target - current

		local eta = math.huge
		if target > 0 and perHour > 0 then
			eta = remaining > 0 and (remaining / perHour) * 3600 or 0
		end

		text.Text =
			"💰 Beli: " .. current .. "\n" ..
			"📈 Farmed: " .. gainedTotal .. "\n" ..
			"⏱ Time: " .. formatTime(elapsed) .. "\n" ..
			"⚡ Beli/h: " .. math.floor(perHour) .. "\n" ..
			"🎯 Target: " .. target .. "\n" ..
			"⌛ ETA: " .. formatTime(eta)
	end
end)
