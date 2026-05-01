local Players = game:GetService("Players")
local player = Players.LocalPlayer
local data = player:WaitForChild("Data", 10)
local beli = data and data:WaitForChild("Beli", 10)

if not beli then
	warn("No Beli found")
	return
end

local gui = Instance.new("ScreenGui")
gui.Name = "FarmStatsGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 90)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, 0, 1, 0)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.fromRGB(0, 255, 120)
text.Font = Enum.Font.Code
text.TextSize = 14
text.TextXAlignment = Enum.TextXAlignment.Left
text.TextYAlignment = Enum.TextYAlignment.Top
text.Parent = frame

local startTime = os.clock()
local lastBeli = beli.Value
local gainedTotal = 0

local function formatTime(sec)
	local h = math.floor(sec / 3600)
	local m = math.floor((sec % 3600) / 60)
	local s = math.floor(sec % 60)
	return string.format("%02d:%02d:%02d", h, m, s)
end

beli:GetPropertyChangedSignal("Value"):Connect(function()
	local now = beli.Value

	if now > lastBeli then
		gainedTotal += (now - lastBeli)
	end

	lastBeli = now
end)

task.spawn(function()
	while task.wait(1) do
		local elapsed = os.clock() - startTime
		local perHour = elapsed > 0 and (gainedTotal / elapsed) * 3600 or 0

		text.Text =
			"Beli Gain: " .. tostring(gainedTotal) .. "\n" ..
			"Time Farm: " .. formatTime(elapsed) .. "\n" ..
			"Beli/Hour: " .. math.floor(perHour)
	end
end)
