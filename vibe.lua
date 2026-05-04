local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- 🔒 TẮT CORE GUI (top bar, backpack...)
pcall(function()
	StarterGui:SetCore("TopbarEnabled", false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)

-- 📊 DATA
local data = player:WaitForChild("Data", 10)
local beli = data and data:WaitForChild("Beli", 10)

if not beli then
	warn("No Beli found")
	return
end

-- 🌑 LOCK ÁNH SÁNG (đen tuyệt đối)
Lighting.Brightness = 0
Lighting.ClockTime = 0
Lighting.GlobalShadows = true
Lighting.OutdoorAmbient = Color3.new(0,0,0)
Lighting.Ambient = Color3.new(0,0,0)

local blur = Instance.new("BlurEffect")
blur.Size = 60
blur.Parent = Lighting

-- 🖥 GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FULL_BLACK_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = player:WaitForChild("PlayerGui")

-- 🌑 FRAME FULL + CHỐNG HỞ
local bg = Instance.new("Frame")
bg.AnchorPoint = Vector2.new(0.5, 0.5)
bg.Position = UDim2.new(0.5, 0, 0.5, 0)
bg.Size = UDim2.new(2, 0, 2, 0) -- 👈 phủ dư để không bao giờ hở
bg.BackgroundColor3 = Color3.new(0,0,0)
bg.BackgroundTransparency = 0
bg.ZIndex = 999999
bg.Parent = gui

-- 📌 TEXT GIỮA
local mainText = Instance.new("TextLabel")
mainText.Size = UDim2.new(0.6,0,0.5,0)
mainText.Position = UDim2.new(0.2,0,0.25,0)
mainText.BackgroundTransparency = 1
mainText.TextColor3 = Color3.fromRGB(0,255,150)
mainText.Font = Enum.Font.Code
mainText.TextScaled = true
mainText.TextWrapped = true
mainText.ZIndex = 999999
mainText.Text = "Loading..."
mainText.Parent = bg

-- 📊 FPS + PING
local statsText = Instance.new("TextLabel")
statsText.Size = UDim2.new(0,250,0,50)
statsText.Position = UDim2.new(1,-260,0,10)
statsText.BackgroundTransparency = 1
statsText.TextColor3 = Color3.fromRGB(255,255,255)
statsText.Font = Enum.Font.Code
statsText.TextSize = 20
statsText.TextXAlignment = Enum.TextXAlignment.Right
statsText.ZIndex = 999999
statsText.Parent = bg

-- ❌ NÚT THOÁT
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,140,0,45)
closeBtn.Position = UDim2.new(1,-150,1,-60)
closeBtn.Text = "❌ CLOSE"
closeBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.Code
closeBtn.TextSize = 20
closeBtn.ZIndex = 999999
closeBtn.Parent = bg

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
	blur:Destroy()

	-- bật lại UI Roblox
	pcall(function()
		StarterGui:SetCore("TopbarEnabled", true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
	end)
end)

-- ⚙️ CONFIG
local MAX_SPIKE = 10_000_000
local startTime = os.clock()
local lastBeli = beli.Value
local gainedTotal = 0

-- 🎯 FPS
local fps = 0
local frameCount = 0
local lastTime = tick()

RunService.RenderStepped:Connect(function()
	frameCount += 1
	if tick() - lastTime >= 1 then
		fps = frameCount
		frameCount = 0
		lastTime = tick()
	end
end)

-- 💰 TRACK BELI
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

-- ⏱ FORMAT TIME
local function formatTime(sec)
	if sec == math.huge then return "∞" end
	local h = math.floor(sec / 3600)
	local m = math.floor((sec % 3600) / 60)
	local s = math.floor(sec % 60)
	return string.format("%02d:%02d:%02d", h, m, s)
end

-- 🔁 UPDATE LOOP
task.spawn(function()
	while task.wait(1) do
		local elapsed = os.clock() - startTime
		local perHour = elapsed > 0 and (gainedTotal / elapsed) * 3600 or 0
		local current = beli.Value

		local ping = 0
		pcall(function()
			ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		end)

		statsText.Text = "FPS: "..fps.." | Ping: "..ping.."ms"

		mainText.Text =
			"💰 Beli: " .. current .. "\n" ..
			"📈 Farmed: " .. gainedTotal .. "\n" ..
			"⏱ Time: " .. formatTime(elapsed) .. "\n" ..
			"⚡ Beli/h: " .. math.floor(perHour)
	end
end)
