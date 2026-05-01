local Players = game:GetService("Players")
local player = Players.LocalPlayer
local MAX_SPIKE = 10_000_000
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
frame.Size = UDim2.new(0, 260, 0, 180)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, -10, 0, 130)
text.Position = UDim2.new(0, 5, 0, 5)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.fromRGB(0, 255, 120)
text.Font = Enum.Font.Code
text.TextSize = 14
text.TextXAlignment = Enum.TextXAlignment.Left
text.TextYAlignment = Enum.TextYAlignment.Top
text.Parent = frame

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -10, 0, 30)
input.Position = UDim2.new(0, 5, 1, -35)
input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
input.TextColor3 = Color3.fromRGB(255,255,255)
input.PlaceholderText = "Target (vd: 50000000)"
input.Font = Enum.Font.Code
input.TextSize = 14
input.Parent = frame

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
	local num = tonumber(input.Text)
	target = num or 0
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

task.spawn(function()
	while task.wait(1) do
		local elapsed = os.clock() - startTime
		local perHour = elapsed > 0 and (gainedTotal / elapsed) * 3600 or 0
		local current = beli.Value
		local remaining = target - current
		local eta = math.huge
		if target > 0 and perHour > 0 then
			if remaining <= 0 then
				eta = 0
			else
				eta = (remaining / perHour) * 3600
			end
		end

		text.Text =
			"Beli hiện tại: " .. current .. "\n" ..
			"Beli đã farm: " .. gainedTotal .. "\n" ..
			"Thời gian farm: " .. formatTime(elapsed) .. "\n" ..
			"Beli/giờ: " .. math.floor(perHour) .. "\n" ..
			"Mục tiêu: " .. target .. "\n" ..
			"Thời gian cần farm: " .. formatTime(eta)
	end
end)
