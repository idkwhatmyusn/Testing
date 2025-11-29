local Version = "1.6.53"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" ..
Version .. "/main.lua"))()

-- =========================================================
-- ===============  REAL-TIME AVATAR SYNC SYSTEM ============
-- =========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Http = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- =========================================================
-- =============== GLOBAL SYNC EVENT BUS ====================
-- =========================================================

local Bus = CoreGui:FindFirstChild("NKZ_AVATAR_BUS")
if not Bus then
    Bus = Instance.new("Folder")
    Bus.Name = "NKZ_AVATAR_BUS"
    Bus.Parent = CoreGui
end

local SyncEvent = Bus:FindFirstChild("SyncAvatar")
if not SyncEvent then
    SyncEvent = Instance.new("BindableEvent")
    SyncEvent.Name = "SyncAvatar"
    SyncEvent.Parent = Bus
end

-- 🌐 RAW STATUS (isi: true / false / update)
local statusLink = "https://pastebin.com/raw/gu1NaSFq" -- ganti punya kamu

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Ambil status dari raw
local function getRawStatus()
    local success, body = pcall(function()
        return game:HttpGet(statusLink)
    end)

    if not success or not body then
        return "true" -- default aman jika raw error
    end

    body = string.lower(body):gsub("%s+", "")

    if body == "true" or body == "false" or body == "update" then
        return body
    end

    return "true"
end

-- 🔥 Fungsi KICK dengan dialog + kick real
local function ForceKick(reason)
    pcall(function()
        localPlayer:Kick(reason)
    end)
end

-- 🔁 REAL-TIME CHECK SETIAP 3 DETIK
task.spawn(function()
    while task.wait(3) do
        local status = getRawStatus()

        -- Jika developer set false → langsung kick
        if status == "false" then
            ForceKick("⚠️ Script Anda Dinonaktifkan Oleh Developer (Code: FALSE)")
            break

        -- Jika developer set update → kick + info update
        elseif status == "update" then
            ForceKick("🔄 Script Memerlukan Update! Silakan Ambil Versi Terbaru.")
            break
        end
    end
end)

-------------------------------------------
----- =======[ GLOBAL FUNCTION ]
-------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local VirtualUser = game:GetService("VirtualUser")
local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")
local EquipOxy =  net:WaitForChild("RF/EquipOxygenTank")
local UnequipOxy =  net:WaitForChild("RF/UnequipOxygenTank")
local Radar = net:WaitForChild("RF/UpdateFishingRadar")
local Constants = require(ReplicatedStorage:WaitForChild("Shared", 20):WaitForChild("Constants"))

_G.Characters = workspace:FindFirstChild("Characters"):WaitForChild(LocalPlayer.Name)
_G.HRP = _G.Characters:WaitForChild("HumanoidRootPart")
_G.Overhead = _G.HRP:WaitForChild("Overhead")
_G.Header = _G.Overhead:WaitForChild("Content"):WaitForChild("Header")
_G.LevelLabel = _G.Overhead:WaitForChild("LevelContainer"):WaitForChild("Label")
local Player = Players.LocalPlayer
_G.XPBar = Player:WaitForChild("PlayerGui"):WaitForChild("XP")
_G.XPLevel = _G.XPBar:WaitForChild("Frame"):WaitForChild("LevelCount")
_G.Title = _G.Overhead:WaitForChild("TitleContainer"):WaitForChild("Label")
_G.TitleEnabled = _G.Overhead:WaitForChild("TitleContainer")

if Player and VirtualUser then
    Player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

task.spawn(function()
    if _G.XPBar then
        _G.XPBar.Enabled = false
    end
end)

_G.TeleportService = game:GetService("TeleportService")
_G.PlaceId = game.PlaceId

local function AutoReconnect()
    while task.wait(5) do
        if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
            _G.TeleportService:Teleport(_G.PlaceId)
        end
    end
end

Players.LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        TeleportService:Teleport(PlaceId)
    end
end)

task.spawn(AutoReconnect)

local ijump = false

local RodIdle = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("ReelingIdle")

local RodShake = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("RodThrow")

local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")


local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local RodShake = animator:LoadAnimation(RodShake)
local RodIdle = animator:LoadAnimation(RodIdle)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
-----------------------------------------------------
-- SERVICES
-----------------------------------------------------

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Modules = ReplicatedStorage:WaitForChild("Modules", 5)

if Shared then
    if not _G.ItemUtility then
        local success, utility = pcall(require, Shared:WaitForChild("ItemUtility", 5))
        if success and utility then
            _G.ItemUtility = utility
        else
            warn("ItemUtility module not found or failed to load.")
        end
    end
    if not _G.ItemStringUtility and Modules then
        local success, stringUtility = pcall(require, Modules:WaitForChild("ItemStringUtility", 5))
        if success and stringUtility then
            _G.ItemStringUtility = stringUtility
        else
            warn("ItemStringUtility module not found or failed to load.")
        end
    end
    -- Memuat Replion, Promise, PromptController untuk Auto Accept Trade
    if not _G.Replion then pcall(function() _G.Replion = require(ReplicatedStorage.Packages.Replion) end) end
    if not _G.Promise then pcall(function() _G.Promise = require(ReplicatedStorage.Packages.Promise) end) end
    if not _G.PromptController then pcall(function() _G.PromptController = require(ReplicatedStorage.Controllers.PromptController) end) end
end


-- =======================================================
-- == NIKZZ PERFECTION SYSTEM (AUTO REGISTER, HIDE CHAT)
-- =======================================================

_G.AUTO_MESSAGE = "!p"
_G.NEWBIE_MESSAGE = "!n"
_G.HideLocalChat = true
_G.Players = game:GetService("Players")
_G.LocalPlayer = _G.Players.LocalPlayer
_G.TextChatService = game:GetService("TextChatService")
_G.ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============ HIDE LOCAL CHAT ============
if _G.HideLocalChat and not _G.ChatHiddenHooked then
    _G.ChatHiddenHooked = true

    if _G.TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        _G.TextChatService.MessageReceived:Connect(function(msg)
            if msg.TextSource and msg.TextSource.UserId == _G.LocalPlayer.UserId then
                msg:Cancel() -- hide pesan sendiri
            end
        end)

    else
        local chatEvents = _G.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents and chatEvents:FindFirstChild("OnMessageDoneFiltering") then
            chatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
                if data.FromSpeaker == _G.LocalPlayer.Name then
                    return nil
                end
            end)
        end
    end
end

-- ============ SEND CHAT API (TETAP ADA, TAPI TIDAK DIPAKAI) ============
function _G.SendChat(msg)
    task.spawn(function()
        pcall(function()
            if _G.TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local channel = _G.TextChatService.TextChannels.RBXGeneral
                if channel then channel:SendAsync(msg) end
            end
        end)

        local chatEvents = _G.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
            pcall(function()
                chatEvents.SayMessageRequest:FireServer(msg, "All")
            end)
        end
    end)
end

-- =======================================================
-- == PERFECTION SETTINGS
-- =======================================================

_G.PerfText = "PERFECTION!"
_G.PerfColor = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(64, 255, 118)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(64, 255, 118))
})

_G.TargetTexts = {
    ["ok"] = true, ["good"] = true, ["great"] = true,
    ["amazing"] = true, ["perfect!"] = true
}

_G.Rep = _G.ReplicatedStorage
_G.Effects = require(_G.Rep.Shared.Effects)
_G.VFX = require(_G.Rep.Controllers.VFXController)
_G.Sounds = require(_G.Rep.Shared.Soundbook)

_G.PerfPlayers = _G.PerfPlayers or {}

if not _G.OriginalTextEffect then
    _G.OriginalTextEffect = _G.Effects.TextEffect
end



function _G.ListenToPlayer(player)
    if player == _G.LocalPlayer then return end

    player.Chatted:Connect(function(msg)
        msg = msg:lower()

        if msg == _G.NEWBIE_MESSAGE then
            task.delay(0.3, function()
                _G.SendChat(_G.AUTO_MESSAGE)
            end)
            return
        end


        if msg == "!p" then
            _G.PerfPlayers[player.Name] = true
            print("[PERFECTION] Enabled for:", player.Name)
        end

        if msg == "!unp" then
            _G.PerfPlayers[player.Name] = nil
            print("[PERFECTION] Disabled for:", player.Name)
        end
    end)
end


for _, p in ipairs(_G.Players:GetPlayers()) do
    _G.ListenToPlayer(p)
end

_G.Players.PlayerAdded:Connect(function(player)
    _G.ListenToPlayer(player)
end)


_G.Effects.TextEffect = function(self, data, ...)
    if data and data.Container and data.TextData and data.TextData.Text then

        local character = data.Container.Parent
        local owner = game.Players:GetPlayerFromCharacter(character)

        local isLocal = owner == _G.LocalPlayer
        local forced = owner and _G.PerfPlayers[owner.Name]

        if (isLocal or forced) then
            local text = string.lower(data.TextData.Text)

            if _G.TargetTexts[text] or text == string.lower(_G.PerfText) then
                data.TextData.Text = _G.PerfText
                data.TextData.TextColor = _G.PerfColor

                task.spawn(function()
                    pcall(function()
                        _G.VFX.Handle(_G.PerfText, data.Container)
                    end)
                end)

                task.spawn(function()
                    pcall(function()
                        if _G.Sounds.Sounds.Perfect then
                            _G.Sounds.Sounds.Perfect:Play()
                        elseif _G.Sounds.Sounds.PerfectCast then
                            _G.Sounds.Sounds.PerfectCast:Play()
                        end
                    end)
                end)
            end
        end
    end

    return _G.OriginalTextEffect(self, data, ...)
end

-------------------------------------------
----- =======[ NOTIFY FUNCTION ]
-------------------------------------------

local function NotifySuccess(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "circle-check"
    })
end

local function NotifyError(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "ban"
    })
end

local function NotifyInfo(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "info"
    })
end

local function NotifyWarning(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "triangle-alert"
    })
end

-------------------------------------------
----- =======[ LOAD WINDOW ]
-------------------------------------------


WindUI:AddTheme({
    Name = "Royal Void",
    Accent = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#FF3366"), Transparency = 0 },  -- Merah Cerah
        ["50"]  = { Color = Color3.fromHex("#1E90FF"), Transparency = 0 },  -- Cyan Cerah
        ["100"] = { Color = Color3.fromHex("#9B30FF"), Transparency = 0 },  -- Ungu Terang
    }, {
        Rotation = 45,
    }),

    Dialog = Color3.fromHex("#0A0011"),         -- Latar hitam ke ungu gelap
    Outline = Color3.fromHex("#1E90FF"),        -- Pinggir Cyan Cerah
    Text = Color3.fromHex("#FFE6FF"),           -- Putih ke ungu muda
    Placeholder = Color3.fromHex("#B34A7F"),    -- Ungu-merah pudar
    Background = Color3.fromHex("#050008"),     -- Hitam pekat dengan nuansa ungu
    Button = Color3.fromHex("#FF00AA"),         -- Merah ke ungu neon
    Icon = Color3.fromHex("#0066CC")            -- Aksen Cyan
})
WindUI.TransparencyValue = 0.3

local Window = WindUI:CreateWindow({
    Title = "Nikzz7ZXit",
    Icon = "flame",
    Author = "Fishit | NewUpdate [Premium | Normal]",
    Folder = "Nikzz7ZXit",
    Size = UDim2.fromOffset(600, 400),
    Transparent = true,
    Theme = "Royal Void",
    KeySystem = false,
    ScrollBarEnabled = true,
    HideSearchBar = true,
    NewElements = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() end,
    }
})

Window:EditOpenButton({
    Title = "Nikzz7ZXit",
    Icon = "star",
    CornerRadius = UDim.new(0,30),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#FF3366")), -- Merah
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("#1E90FF")), -- Cyan
        ColorSequenceKeypoint.new(1, Color3.fromHex("#9B30FF")) -- Ungu
    }),
    Draggable = true,
})

local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("NikzzConfig")

WindUI:SetNotificationLower(true)

WindUI:Notify({
    Title = "Nikzz7ZXit",
    Content = "All Features Loaded!",
    Duration = 5,
    Image = "square-check-big"
})

-------------------------------------------
----- =======[ ALL TAB ]
-------------------------------------------

local Home = Window:Tab({
    Title = "Developer Info",
    Icon = "hard-drive"
})

_G.ServerPage = Window:Tab({
    Title = "Server List",
    Icon = "server"
})

_G.FishSec = Window:Tab({
    Title = "Menu Fishing",
    Icon = "fish"
})

local AutoFarmTab = Window:Tab({
    Title = "Menu Farming",
    Icon = "leaf"
})

_G.AutoQuestTab = Window:Tab({
    Title = "Auto Quest",
    Icon = "list-checks"
})

local AutoFav = Window:Tab({
    Title = "Auto Favorite",
    Icon = "star"
})

local Trade = Window:Tab({
    Title = "Menu Trade",
    Icon = "arrow-left-right"
})

_G.DStones = Window:Tab({
    Title = "Enchant Rod",
    Icon = "wand"
})

local Player = Window:Tab({
    Title = "Player Menu",
    Icon = "user"
})

local HookTab = Window:Tab({
    Title = "Hook Telegram",
    Icon = "webhook"
})

local Utils = Window:Tab({
    Title = "Utility",
    Icon = "earth"
})

local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "cog"
})

-------------------------------------------
----- =======[ HOME TAB ]
-------------------------------------------

Home:Section({
	Title = "Developer Information",
	TextSize = 22,
	TextXAlignment = "Center",
})

Home:Paragraph({
	Title = "NikZzzXit",
	Color = "Red",
	Desc = [[
Developer : NikZz
Game Script : Fish it Only
Version : New Update
Script  : Premium
]]
})

Home:Space()

local function safeLoad(url)
    local s = game:HttpGet(url)
    if s and #s > 5 then
        local f = loadstring(s)
        if f then
            f()
        else
            warn("Loadstring gagal")
        end
    else
        warn("HTTPGet kosong")
    end
end

Home:Section({
	Title = "Ultra Fish Executor",
	TextSize = 22,
	TextXAlignment = "Center",
})

Home:Button({
    Title = "Execute Ultra Fishing",
    Callback = function()
        pcall(function()
            safeLoad("https://raw.githubusercontent.com/idkwhatmyusn/idkforrepostory/refs/heads/main/UltraFishing.lua")
        end)
    end
})

Home:Space()

-------------------------------------------
----- =======[ SERVER PAGE TAB ]
-------------------------------------------

_G.ServerList = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" ..
game.PlaceId .. "/servers/Private?sortOrder=Asc&limit=100"))

_G.ButtonList = {}

_G.ServerListAll = _G.ServerPage:Section({
    Title = "All Server List",
    TextSize = 22,
    TextXAlignment = "Center"
})

_G.ShowServersButton = _G.ServerListAll:Button({
    Title = "Show Server List",
    Desc = "Klik untuk menampilkan daftar server yang tersedia.",
    Locked = false,
    Icon = "",
    Callback = function()
        if _G.ServersShown then return end
        _G.ServersShown = true

        for _, server in ipairs(_G.ServerList.data) do
            _G.playerCount = string.format("%d/%d", server.playing, server.maxPlayers)
            _G.ping = server.ping
            _G.id = server.id

            local buttonServer = _G.ServerListAll:Button({
                Title = "Server",
                Desc = "Player: " .. tostring(_G.playerCount) .. "\nPing: " .. tostring(_G.ping),
                Locked = false,
                Icon = "",
                Callback = function()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, _G.id,
                        game.Players.LocalPlayer)
                end
            })

            buttonServer:SetTitle("Server")
            buttonServer:SetDesc("Player: " .. tostring(_G.playerCount) .. "\nPing: " .. tostring(_G.ping))

            table.insert(_G.ButtonList, buttonServer)
        end

        if #_G.ButtonList == 0 then
            _G.ServerListAll:Button({
                Title = "No Servers Found",
                Desc = "Tidak ada server yang ditemukan.",
                Locked = true,
                Callback = function() end
            })
        end
    end
})

-------------------------------------------
----- =======[ AUTO FISH TAB ]
-------------------------------------------

_G.REFishingStopped = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingStopped"]
_G.RFCancelFishingInputs = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]
_G.REUpdateChargeState = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/UpdateChargeState"]


_G.StopFishing = function()
    _G.RFCancelFishingInputs:InvokeServer()
    firesignal(_G.REFishingStopped.OnClientEvent)
end

local FuncAutoFish = {
    REReplicateTextEffect = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateTextEffect"],
    autofish5x = false,
    perfectCast5x = true,
    fishingActive = false,
    delayInitialized = false,
    lastCatchTime5x = 0,
    CatchLast = tick(),
}



_G.REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]
_G.REPlayFishingEffect = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/PlayFishingEffect"]
_G.equipRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]
_G.REObtainedNewFishNotification = ReplicatedStorage
    .Packages._Index["sleitnick_net@0.2.0"]
    .net["RE/ObtainedNewFishNotification"]


_G.isSpamming = false
_G.rSpamming = false
_G.spamThread = nil
_G.rspamThread = nil
_G.lastRecastTime = 0
_G.DELAY_ANTISTUCK = 10
_G.isRecasting5x = false
_G.STUCK_TIMEOUT = 10
_G.AntiStuckEnabled = false
_G.lastFishTime = tick()
_G.FINISH_DELAY = 1
_G.fishCounter = 0
_G.sellThreshold = 5
_G.sellActive = false
_G.AutoFishHighQuality = false

-- [[ KONFIGURASI DELAY ]] --


_G.RemotePackage = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
_G.RemoteFish = _G.RemotePackage["RE/ObtainedNewFishNotification"]
_G.RemoteSell = _G.RemotePackage["RF/SellAllItems"]

_G.RemoteFish.OnClientEvent:Connect(function(_, _, data)
    if _G.sellActive and data then
        _G.fishCounter += 1
        if _G.fishCounter >= _G.sellThreshold then
            _G.TrySellNow()
            _G.fishCounter = 0
        end
    end
end)

_G.LastSellTick = 0

function _G.TrySellNow()
    local now = tick()
    if now - _G.LastSellTick < 1 then 
        return 
    end
    _G.LastSellTick = now
    _G.RemoteSell:InvokeServer()
end

function InitialCast5X()
    _G.StopFishing()
    local getPowerFunction = Constants.GetPower
    local perfectThreshold = 0.99
    local chargeStartTime = workspace:GetServerTimeNow()
    rodRemote:InvokeServer(chargeStartTime)
    local calculationLoopStart = tick()
    local timeoutDuration = 0.01 -- Loop 1 detik ini TETAP DI SINI
    local lastPower = 0
    while (tick() - calculationLoopStart < timeoutDuration) do
        local currentPower = getPowerFunction(Constants, chargeStartTime)
        if currentPower < lastPower and lastPower >= perfectThreshold then
            break
        end

        lastPower = currentPower
        task.wait(0) -- task.wait(0) diganti dari task.wait() agar lebih cepat
    end
    miniGameRemote:InvokeServer(-1.25, 1.0, workspace:GetServerTimeNow())
end

function _G.RecastSpam()
    if _G.rSpamming then return end
    _G.rSpamming = true
    
    _G.rspamThread = task.spawn(function()
        while _G.rSpamming do
            task.wait(0.01) 
            InitialCast5X()
        end
    end)
end

function _G.StopRecastSpam()
    _G.rSpamming = false
    if _G.rspamThread then
        task.cancel(_G.rspamThread) -- Membunuh thread
        _G.rspamThread = nil
    end
end

    

function _G.startSpam()
    if _G.isSpamming then return end
    _G.isSpamming = true
    _G.spamThread = task.spawn(function()
        task.wait(tonumber(_G.FINISH_DELAY))
        finishRemote:FireServer()
    end)
end
    
function _G.stopSpam()
   _G.isSpamming = false
end


_G.REPlayFishingEffect.OnClientEvent:Connect(function(player, head, data)
    if player == Players.LocalPlayer and FuncAutoFish.autofish5x then
        _G.StopRecastSpam() -- Menghentikan spam cast (sudah di-fix)
        _G.stopSpam()
    end
end)



local lastEventTime = tick()

task.spawn(function()
    while task.wait(1) do
        if _G.AutoFishHighQuality and FuncAutoFish.autofish5x and FuncAutoFish.REReplicateTextEffect then
            if tick() - lastEventTime > 10 then
                StopAutoFish5X()
                lastEventTime = tick()
                task.wait(0.5)
                StartAutoFish5X()
            end
        end
    end
end)

local function approx(a, b, tolerance)
    return math.abs(a - b) <= (tolerance or 0.02)
end

local function isColor(r, g, b, R, G, B)
    return approx(r, R) and approx(g, G) and approx(b, B)
end

local BAD_COLORS = {
    COMMON    = {1,       0.980392, 0.964706},
    UNCOMMON  = {0.764706, 1,        0.333333},
    RARE      = {0.333333, 0.635294, 1},
    EPIC      = {0.678431, 0.309804, 1},
}

FuncAutoFish.REReplicateTextEffect.OnClientEvent:Connect(function(data)

    if not FuncAutoFish.autofish5x then return end

    local myHead = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head")
    if not (data and data.TextData and data.TextData.TextColor and data.TextData.EffectType == "Exclaim" and myHead and data.Container == myHead) then
        return
    end

    lastEventTime = tick()
    if _G.AutoFishHighQuality then
        local colorValue = data.TextData.TextColor
        local r, g, b
    
        if typeof(colorValue) == "Color3" then
            r, g, b = colorValue.R, colorValue.G, colorValue.B
        elseif typeof(colorValue) == "ColorSequence" and #colorValue.Keypoints > 0 then
            local c = colorValue.Keypoints[1].Value
            r, g, b = c.R, c.G, c.B
        end
    
        if not (r and g and b) then return end
    
        local isBadFish = false
    
        for _, col in pairs(BAD_COLORS) do
            if isColor(r, g, b, col[1], col[2], col[3]) then
                isBadFish = true
                break
            end
        end
    
        if isBadFish then
            _G.StopFishing()
            _G.RecastSpam()
        else
            _G.startSpam()
        end
    else
        _G.startSpam()
    end
end)



_G.REFishCaught.OnClientEvent:Connect(function(fishName, info)
    if FuncAutoFish.autofish5x then
        _G.stopSpam()
        _G.lastFishTime = tick()
        _G.RecastSpam()
    end
end)

task.spawn(function()
	while task.wait(1) do
		if _G.AntiStuckEnabled and FuncAutoFish.autofish5x and not _G.AutoFishHighQuality then
			if tick() - _G.lastFishTime > tonumber(_G.STUCK_TIMEOUT) then
				StopAutoFish5X()
				task.wait(0.5)
				StartAutoFish5X()
				_G.lastFishTime = tick()
			end
		end
	end
end)


function StartAutoFish5X()
    FuncAutoFish.autofish5x = true
    _G.AntiStuckEnabled = true
    lastEventTime = tick()
    _G.lastFishTime = tick()
    _G.equipRemote:FireServer(1)
    task.wait(0.5)
    InitialCast5X()
end


function StopAutoFish5X()
    FuncAutoFish.autofish5x = false
    _G.AntiStuckEnabled = false
    _G.StopFishing()
    _G.isRecasting5x = false
    _G.stopSpam()
    _G.StopRecastSpam()
end


--[[

INI AUTO FISH LEGIT 

]]


_G.RunService = game:GetService("RunService")
_G.ReplicatedStorage = game:GetService("ReplicatedStorage")
_G.FishingControllerPath = _G.ReplicatedStorage.Controllers.FishingController
_G.FishingController = require(_G.FishingControllerPath)

_G.AutoFishingControllerPath = _G.ReplicatedStorage.Controllers.AutoFishingController
_G.AutoFishingController = require(_G.AutoFishingControllerPath)
_G.Replion = require(_G.ReplicatedStorage.Packages.Replion)

_G.AutoFishState = {
    IsActive = false,
    MinigameActive = false
}

_G.SPEED_LEGIT = 0.5

function _G.performClick()
    _G.FishingController:RequestFishingMinigameClick()
    task.wait(tonumber(_G.SPEED_LEGIT))
end

_G.originalAutoFishingStateChanged = _G.AutoFishingController.AutoFishingStateChanged
function _G.forceActiveVisual(arg1)
    _G.originalAutoFishingStateChanged(true)
end

_G.AutoFishingController.AutoFishingStateChanged = _G.forceActiveVisual

function _G.ensureServerAutoFishingOn()
    local replionData = _G.Replion.Client:WaitReplion("Data")
    local currentAutoFishingState = replionData:GetExpect("AutoFishing")

    if not currentAutoFishingState then
        local remoteFunctionName = "UpdateAutoFishingState"
        local Net = require(_G.ReplicatedStorage.Packages.Net)
        local UpdateAutoFishingRemote = Net:RemoteFunction(remoteFunctionName)

        local success, result = pcall(function()
            return UpdateAutoFishingRemote:InvokeServer(true)
        end)

        if success then
        else
        end
    else
    end
end

-- ===================================================================
-- BAGIAN 2: AUTO CLICK MINIGAME
-- ===================================================================

_G.originalRodStarted = _G.FishingController.FishingRodStarted
_G.originalFishingStopped = _G.FishingController.FishingStopped
_G.clickThread = nil

_G.FishingController.FishingRodStarted = function(self, arg1, arg2)
    _G.originalRodStarted(self, arg1, arg2)

    if _G.AutoFishState.IsActive and not _G.AutoFishState.MinigameActive then
        _G.AutoFishState.MinigameActive = true

        if _G.clickThread then
            task.cancel(_G.clickThread)
        end

        _G.clickThread = task.spawn(function()
            while _G.AutoFishState.IsActive and _G.AutoFishState.MinigameActive do
                _G.performClick()
            end
        end)
    end
end

_G.FishingController.FishingStopped = function(self, arg1)
    _G.originalFishingStopped(self, arg1)

    if _G.AutoFishState.MinigameActive then
        _G.AutoFishState.MinigameActive = false
        task.wait(1)
        _G.ensureServerAutoFishingOn()
    end
end

function _G.ToggleAutoClick(shouldActivate)
    _G.AutoFishState.IsActive = shouldActivate

    if shouldActivate then
        _G.ensureServerAutoFishingOn()
    else
        if _G.clickThread then
            task.cancel(_G.clickThread)
            _G.clickThread = nil
        end
        _G.AutoFishState.MinigameActive = false
    end
end

_G.FishSec:Section({
    Title = "Auto Fishing V1 (Instant Fishing)",
    TextSize = 22,
    TextXAlignment = "Center",
})

_G.DelayFinish = _G.FishSec:Input({
    Title = "Delay Fishing",
    Desc = [[
Enter a valid delay settings
]],
    Value = _G.FINISH_DELAY,
    Type = "Input",
    Placeholder = "Input Delay Finish..",
    Callback = function(input)
        fDelays = tonumber(input)
        if not fDelays then
            NotifyWarning("The number you entered is invalid")
        end
        _G.FINISH_DELAY = fDelays
    end
})
myConfig:Register("DelayFinish", _G.DelayFinish)

_G.StuckDelay = _G.FishSec:Input({
    Title = "Anti Stuck Delay",
    Desc = "Cooldown for anti stuck Auto Fish",
    Value = _G.STUCK_TIMEOUT,
    Type = "Input",
    Placeholder = "Input Delay Finish..",
    Callback = function(input)
        stuck = tonumber(input)
        if not stuck then
            NotifyWarning("The number you entered is invalid")
        end
        _G.STUCK_TIMEOUT = stuck
    end
})

myConfig:Register("StuckDelay", _G.StuckDelay)

_G.AutoFishes = _G.FishSec:Toggle({
    Title = "Auto Fish Instant",
    Callback = function(value)
        if value then
            StartAutoFish5X()
        else
            StopAutoFish5X()
        end
    end
})
myConfig:Register("AutoFishing", _G.AutoFishes)

_G.FishSec:Space()

_G.FishSec:Section({
    Title = "Auto Fishing V2 (Otomotis Ingame)",
    TextSize = 22,
    TextXAlignment = "Center",
})

_G.SpeedLegit = _G.FishSec:Input({
    Title = "Speed Click",
    Desc = "Speed Click for Auto Fish Otomatis",
    Value = _G.SPEED_LEGIT,
    Type = "Input",
    Placeholder = "Input Speed..",
    Callback = function(input)
        DelayLegit = tonumber(input)
        if not DelayLegit then
            NotifyWarning("The number you entered is invalid")
        end
        _G.SPEED_LEGIT = DelayLegit
    end
})
myConfig:Register("SpeedLegit", _G.SpeedLegit)

_G.FishSec:Toggle({
    Title = "Auto Fish Otomatis",
    Value = false,
    Callback = function(state)
        _G.equipRemote:FireServer(1)
        _G.ToggleAutoClick(state)

        local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local fishingGui = playerGui:WaitForChild("Fishing"):WaitForChild("Main")
        local chargeGui = playerGui:WaitForChild("Charge"):WaitForChild("Main")

        if state then
            fishingGui.Visible = false
            chargeGui.Visible = false
        else
            fishingGui.Visible = true
            chargeGui.Visible = true
        end
    end
})

_G.FishSec:Space()

_G.FishSec:Button({
    Title = "Stop Fishing",
    Locked = false,
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.StopFishing()
        RodIdle:Stop()
        RodIdle:Stop()
        _G.stopSpam()
        _G.StopRecastSpam()
    end
})

_G.FishSec:Space()

_G.FishSec:Section({
    Title = "Auto Sell Fish Settings",
    TextSize = 22,
    TextXAlignment = "Center",
})

_G.SellThress = _G.FishSec:Input({
    Title = "Sell Threesold",
    Value = _G.sellThreshold,
    Type = "Input",
    Placeholder = "Input Delay Finish..",
    Callback = function(input)
        thresold = tonumber(input)
        if not thresold then
            NotifyWarning("The number you entered is invalid")
        end
        _G.sellThreshold = thresold
    end
})
myConfig:Register("SellThresold", _G.SellThress)

_G.InvenSize = _G.FishSec:Input({
    Title = "Max Inventory Size",
    Value = tostring(Constants.MaxInventorySize or 0),
    Placeholder = "Input Number...",
    Callback = function(input)
        local newSize = tonumber(input)
        if not newSize then
            NotifyWarning("Inventory Size", "Must be numbers!")
            return
        end
        Constants.MaxInventorySize = newSize
    end
})
myConfig:Register("InventorySize", _G.InvenSize)

_G.AutoSell = _G.FishSec:Toggle({
    Title = "Auto Sell",
    Value = false,
    Callback = function(state)
        _G.sellActive = state
        if state then
            NotifySuccess("Auto Sell", "Limit: " .. _G.sellThreshold)
        else
            NotifySuccess("Auto Sell", "Disabled")
        end
    end
})
myConfig:Register("AutoSell", _G.AutoSell)

_G.REReplicateCutscene = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateCutscene"]
_G.BlockCutsceneEnabled = false
_G.REReplicateCutscene.OnClientEvent:Connect(function(rarity, player, position, fishName, data)
    if _G.BlockCutsceneEnabled then
        print("[NikZzz] Cutscene diblokir:", fishName, "(Rarity:", rarity .. ")")
        return nil -- blokir event agar tidak muncul cutscene
    end
end)

_G.BlockCutscene = _G.FishSec:Toggle({
    Title = "Block Cutscene",
    Value = false,
    Callback = function(state)
        _G.BlockCutsceneEnabled = state
        print("Block Cutscene: " .. tostring(state))
    end
})
myConfig:Register("BlockCutscene", _G.BlockCutscene)

local REEquipItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipItem"]
local RFSellItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellItem"]

function ToggleAutoSellMythic(state)
    autoSellMythic = state
    if autoSellMythic then
        NotifySuccess("AutoSellMythic", "Status: ON")
    else
        NotifyWarning("AutoSellMythic", "Status: OFF")
    end
end

local oldFireServer
oldFireServer = hookmetamethod(game, "__namecall", function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()

    if autoSellMythic
        and method == "FireServer"
        and self == REEquipItem
        and typeof(args[1]) == "string"
        and args[2] == "Fishes" then
        local uuid = args[1]

        task.delay(1, function()
            pcall(function()
                local result = RFSellItem:InvokeServer(uuid)
                if result then
                    NotifySuccess("AutoSellMythic", "Items Sold!!")
                else
                    NotifyError("AutoSellMythic", "Failed to sell item!!")
                end
            end)
        end)
    end

    return oldFireServer(self, ...)
end)

_G.FishSec:Toggle({
    Title = "Auto Sell Mythic",
    Desc = "Automatically sells clicked fish",
    Default = false,
    Callback = function(state)
        ToggleAutoSellMythic(state)
    end
})


function sellAllFishes()
    local charFolder = workspace:FindFirstChild("Characters")
    local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        NotifyError("Character Not Found", "HRP tidak ditemukan.")
        return
    end

    local originalPos = hrp.CFrame
    local sellRemote = net:WaitForChild("RF/SellAllItems")

    task.spawn(function()
        NotifyInfo("Selling...", "I'm going to sell all the fish, please wait...", 3)

        task.wait(1)
        local success, err = pcall(function()
            sellRemote:InvokeServer()
        end)

        if success then
            NotifySuccess("Sold!", "All the fish were sold successfully.", 3)
        else
            NotifyError("Sell Failed", tostring(err, 3))
        end
    end)
end

_G.FishSec:Space()

_G.FishSec:Button({
    Title = "Sell All Fishes",
    Locked = false,
    Justify = "Center",
    Icon = "",
    Callback = function()
        sellAllFishes()
    end
})

_G.FishSec:Space()

-------------------------------------------
----- =======[ AUTO FAV TAB ]
-------------------------------------------


local GlobalFav = {
    REObtainedNewFishNotification = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"],
    REFavoriteItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FavoriteItem"],

    FishIdToName = {},
    FishNameToId = {},
    FishNames = {},
    FishRarity = {},
    Variants = {},
    SelectedFishIds = {},
    SelectedVariants = {},
    SelectedRarities = {},
    AutoFavoriteEnabled = false
}

local TierToRarityName = {
    [3] = "RARE",
    [4] = "EPIC",
    [5] = "LEGENDARY",
    [6] = "MYTHIC",
    [7] = "SECRET"
}

for _, item in ipairs(ReplicatedStorage.Items:GetChildren()) do
    local ok, data = pcall(require, item)
    if ok and data.Data and data.Data.Type == "Fish" then
        local id = data.Data.Id
        local name = data.Data.Name
        local tier = data.Data.Tier or 1

        GlobalFav.FishIdToName[id] = name
        GlobalFav.FishNameToId[name] = id
        GlobalFav.FishRarity[id] = tier
        table.insert(GlobalFav.FishNames, name)
    end
end

-- Load Variants
for _, variantModule in pairs(ReplicatedStorage.Variants:GetChildren()) do
    local ok, variantData = pcall(require, variantModule)
    if ok and variantData.Data.Name then
        local name = variantData.Data.Name
        GlobalFav.Variants[name] = name
    end
end

AutoFav:Section({
    Title = "Auto Favorite Menu",
    TextSize = 22,
    TextXAlignment = "Center",
})

AutoFav:Toggle({
    Title = "Enable Auto Favorite",
    Value = false,
    Callback = function(state)
        GlobalFav.AutoFavoriteEnabled = state
        if state then
            NotifySuccess("Auto Favorite", "Auto Favorite feature enabled")
        else
            NotifyWarning("Auto Favorite", "Auto Favorite feature disabled")
        end
    end
})

local AllFishNames = GlobalFav.FishNames

_G.FishList = AutoFav:Dropdown({
    Title = "Auto Favorite Fishes",
    Values = AllFishNames,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(selectedNames)
        GlobalFav.SelectedFishIds = {}

        for _, name in ipairs(selectedNames) do
            local id = GlobalFav.FishNameToId[name]
            if id then
                GlobalFav.SelectedFishIds[id] = true
            end
        end

        NotifyInfo("Auto Favorite", "Favoriting active for fish: " .. HttpService:JSONEncode(selectedNames))
    end
})


AutoFav:Dropdown({
    Title = "Auto Favorite Variants",
    Values = GlobalFav.Variants,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(selectedVariants)
        GlobalFav.SelectedVariants = {}
        for _, vName in ipairs(selectedVariants) do
            for vId, name in pairs(GlobalFav.Variants) do
                if name == vName then
                    GlobalFav.SelectedVariants[vId] = true
                end
            end
        end
        NotifyInfo("Auto Favorite", "Favoriting active for variants: " .. HttpService:JSONEncode(selectedVariants))
    end
})

-- Rarity dropdown
local rarityList = {}
for tier, name in pairs(TierToRarityName) do
    table.insert(rarityList, name)
end

AutoFav:Dropdown({
    Title = "Auto Favorite by Rarity",
    Values = rarityList,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(selectedRarities)
        GlobalFav.SelectedRarities = {}
        for _, rarityName in ipairs(selectedRarities) do
            for tier, name in pairs(TierToRarityName) do
                if name == rarityName then
                    GlobalFav.SelectedRarities[tier] = true
                end
            end
        end
        NotifyInfo("Auto Favorite", "Favoriting active for rarities: " .. HttpService:JSONEncode(selectedRarities))
    end
})

GlobalFav.REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, _, data)
    if not GlobalFav.AutoFavoriteEnabled then return end

    local uuid = data.InventoryItem and data.InventoryItem.UUID
    if not uuid then return end

    local fishName = GlobalFav.FishIdToName[itemId] or "Unknown"
    local variantId = data.InventoryItem.Metadata and data.InventoryItem.Metadata.VariantId
    local tier = GlobalFav.FishRarity[itemId] or 1
    local rarityName = TierToRarityName[tier] or "Unknown"

    local isFishSelected = GlobalFav.SelectedFishIds[itemId]
    local isVariantSelected = variantId and GlobalFav.SelectedVariants[variantId]
    local isRaritySelected = GlobalFav.SelectedRarities[tier]

    local shouldFavorite = false
    if (isFishSelected or not next(GlobalFav.SelectedFishIds))
       and (isVariantSelected or not next(GlobalFav.SelectedVariants))
       and (isRaritySelected or not next(GlobalFav.SelectedRarities)) then
        shouldFavorite = true
    end

    if shouldFavorite then
        GlobalFav.REFavoriteItem:FireServer(uuid)

        local msg = "Favorited " .. fishName

        if isVariantSelected then
            msg = msg .. " (" .. (GlobalFav.Variants[variantId] or variantId) .. " Variant)"
        end

        if isRaritySelected then
            msg = msg .. " (" .. rarityName .. ")"
        end

        NotifySuccess("Auto Favorite", msg .. "!")
    end
end)


-------------------------------------------
----- =======[ _G.FishSec TAB ]
-------------------------------------------


local floatPlatform = nil

local function floatingPlat(enabled)
    if enabled then
        local charFolder = workspace:WaitForChild("Characters", 5)
        local char = charFolder:FindFirstChild(LocalPlayer.Name)
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        floatPlatform = Instance.new("Part")
        floatPlatform.Anchored = true
        floatPlatform.Size = Vector3.new(10, 1, 10)
        floatPlatform.Transparency = 1
        floatPlatform.CanCollide = true
        floatPlatform.Name = "FloatPlatform"
        floatPlatform.Parent = workspace

        task.spawn(function()
            while floatPlatform and floatPlatform.Parent do
                pcall(function()
                    floatPlatform.Position = hrp.Position - Vector3.new(0, 3.5, 0)
                end)
                task.wait(0.1)
            end
        end)

        NotifySuccess("Float Enabled", "This feature has been successfully activated!")
    else
        if floatPlatform then
            floatPlatform:Destroy()
            floatPlatform = nil
        end
        NotifyWarning("Float Disabled", "Feature disabled")
    end
end



local workspace = game:GetService("Workspace")

local BlockEnabled = false

local function createLocalBlock(size, position, color)
    local part = Instance.new("Part")
    part.Size = size or Vector3.new(5, 1, 5)
    part.Position = position or
    (LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, -3, 0)) or
    Vector3.new(0, 5, 0)
    part.Anchored = true
    part.CanCollide = true
    part.Color = color or Color3.fromRGB(0, 0, 255)
    part.Material = Enum.Material.ForceField
    part.Name = "LocalBlock"
    part.Parent = workspace
    return part
end


local function createBlockUnderPlayer()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if workspace:FindFirstChild("LocalBlock") then
            workspace.LocalBlock:Destroy()
        end
        createLocalBlock(Vector3.new(6, 1, 6), hrp.Position - Vector3.new(0, 3, 0), Color3.fromRGB(0, 0, 255))
    end
end


local function ToggleBlockOnce(state)
    BlockEnabled = state
    if state then
        createBlockUnderPlayer()
    else
        if workspace:FindFirstChild("LocalBlock") then
            workspace.LocalBlock:Destroy()
        end
    end
end

local function getPartRecursive(o)
    if o:IsA("BasePart") then return o end
    for _, c in ipairs(o:GetChildren()) do
        local p = getPartRecursive(c)
        if p then return p end
    end
    return nil
end

local eventMap = {
    ["Shark Hunt"]       = { name = "Shark Hunt", part = nil },
    ["Ghost Shark Hunt"] = { name = "Ghost Shark Hunt", part = "Part" },
    ["Worm Hunt"]        = { name = "Model", part = "Part" },
    ["Black Hole"]       = { name = "BlackHole", part = nil },
    ["Meteor Rain"]      = { name = "MeteorRain", part = nil },
    ["Ghost Worm"]       = { name = "Model", part = "Part" },
    ["Shocked"]          = { name = "Shocked", part = nil },
    ["Megalodon Hunt"]   = { name = "Megalodon Hunt", part = "Color" },
}

local eventNames = {}
for _, data in pairs(eventMap) do
    if data.name ~= "Model" then
        table.insert(eventNames, data.name)
    end
end
table.insert(eventNames, "Worm Hunt")
table.insert(eventNames, "Ghost Worm")

local autoTPEvent = false
local savedCFrame = nil
local alreadyTeleported = false
local teleportTime = nil
local selectedEvent = nil
local wasAutoFishing = false

local function teleportTo(position)
    _G.isTeleporting = true
    local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp then
        local wasLocked = hrp.Anchored -- Jika fitur Lock Position aktif
        if wasLocked then hrp.Anchored = false end
        task.wait(0.1)

        -- Teleport
        hrp.CFrame = CFrame.new(position + Vector3.new(0, 15, 0))
        ToggleBlockOnce(true)

        task.wait(0.5)
        if wasLocked then hrp.Anchored = true end
    end
    _G.isTeleporting = false
end

local function saveOriginalPosition()
    local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
    if char and char:FindFirstChild("HumanoidRootPart") then
        savedCFrame = char.HumanoidRootPart.CFrame
    end
end

local function returnToOriginalPosition()
    if savedCFrame then
        local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = savedCFrame
        end
    end
end

local function findEventPart(eventName)
    local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
    if not menuRings then return nil end

    local props = menuRings:FindFirstChild("Props")
    if not props then return nil end

    local targetEventData = eventMap[eventName]
    if not targetEventData then return nil end

    local eventModel = props:FindFirstChild(targetEventData.name)
    if not eventModel or not eventModel:IsA("Model") then return nil end

    local targetPart = nil

    if eventName == "Megalodon Hunt" then
        targetPart = eventModel:FindFirstChild("Color")
    elseif eventName == "Ghost Shark Hunt" then
        targetPart = eventModel:FindFirstChild("Part")
    elseif eventName == "Worm Hunt" or eventName == "Ghost Worm" then
        targetPart = eventModel:FindFirstChild("Part")
    elseif eventModel.PrimaryPart and eventModel.PrimaryPart:IsA("BasePart") then
        targetPart = eventModel.PrimaryPart
    else

        targetPart = getPartRecursive(eventModel)
    end

    if targetPart and targetPart:IsA("BasePart") then
        return targetPart
    end

    return nil
end

local function monitorAutoTP()
    while task.wait(3) do -- Cek setiap 3 detik
        -- Periksa kondisi utama untuk menjalankan logika TP
        if autoTPEvent and selectedEvent then
            local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)

            if char then
                local eventPart = findEventPart(selectedEvent)

                if eventPart and not alreadyTeleported then
                    -- === [ EVENT TERDETEKSI & BELUM TELEPORT ] ===
                    saveOriginalPosition()
                    wasAutoFishing = FuncAutoFish.autofish5x 

                    if wasAutoFishing then
                        StopAutoFish5X() 
                        task.wait(0.5)
                    end

                    teleportTo(eventPart.Position)
                    alreadyTeleported = true
                    teleportTime = tick()

                    -- Mulai AutoFish setelah TP
                    if wasAutoFishing then
                        StartAutoFish5X()
                    end

                    NotifySuccess("Event Farm", ("Teleported to %s. Farming started."):format(selectedEvent))
                elseif alreadyTeleported then
                    -- === [ SUDAH DI LOKASI EVENT ] ===

                    -- Cek Event Hilang atau Timeout 15 menit
                    local isTimeout = teleportTime and (tick() - teleportTime >= 900)

                    if isTimeout or not eventPart then
                        -- Hentikan AutoFish
                        if wasAutoFishing then StopAutoFish5X() end

                        returnToOriginalPosition()

                        NotifyInfo("Event Ended", ("Returned to start position. Reason: %s"):format(
                            isTimeout and "Timeout 15m" or "Event Ended"
                        ))

                        -- Reset State
                        alreadyTeleported = false
                        teleportTime = nil

                        -- Lanjutkan AutoFish jika sebelumnya aktif
                        if wasAutoFishing then
                            task.wait(1)
                            StartAutoFish5X()
                        end
                    end
                end
            end
        else
            -- === [ AUTO TP OFF ] ===
            if alreadyTeleported then
                if wasAutoFishing then StopAutoFish5X() end
                returnToOriginalPosition()
                alreadyTeleported = false
                teleportTime = nil
                NotifyWarning("Auto TP Event", "Fitur dimatikan. Kembali ke posisi awal.")
            end
        end
    end
end

if _G.monitorTPThread then task.cancel(_G.monitorTPThread) end
_G.monitorTPThread = task.spawn(monitorAutoTP)

local isAutoFarmRunning = false

local islandCodes = {
    ["01"] = "Crater Islands",
    ["02"] = "Tropical Grove",
    ["03"] = "Vulcano",
    ["04"] = "Coral Reefs",
    ["05"] = "Winter",
    ["06"] = "Machine",
    ["07"] = "Treasure Room",
    ["08"] = "Sisyphus Statue",
    ["09"] = "Fisherman Island",
    ["10"] = "Esoteric Depths",
    ["11"] = "Kohana",
    ["12"] = "Underground Cellar",
    ["13"] = "Ancient Jungle",
    ["14"] = "Secret Farm Ancient",
    ["15"] = "The Temple (Unlock First)",
    ["16"] = "Ancient Ruin",
    ["17"] = "Iron Cavern",
    ["18"] = "The Iron Cafe"
}

local farmLocations = {
    ["Crater Islands"] = {
        CFrame.new(1066.1864, 57.2025681, 5045.5542, -0.682534158, 1.00865822e-08, 0.730853677, -5.8900711e-09, 1,
            -1.93017531e-08, -0.730853677, -1.74788859e-08, -0.682534158),
        CFrame.new(1057.28992, 33.0884132, 5133.79883, 0.833871782, 5.44149223e-08, 0.551958203, -6.58184218e-09, 1,
            -8.86416984e-08, -0.551958203, 7.02829084e-08, 0.833871782),
        CFrame.new(988.954712, 42.8254471, 5088.71289, -0.849417388, -9.89310394e-08, 0.527721584, -5.96115086e-08, 1,
            9.15179328e-08, -0.527721584, 4.62786431e-08, -0.849417388),
        CFrame.new(1006.70685, 17.2302666, 5092.14844, -0.989664078, 5.6538525e-09, -0.143405005, 9.14879283e-09, 1,
            -2.3711717e-08, 0.143405005, -2.47786183e-08, -0.989664078),
        CFrame.new(1025.02356, 2.77259707, 5011.47021, -0.974474192, -6.87871804e-08, 0.224499553, -4.47472104e-08, 1,
            1.12170284e-07, -0.224499553, 9.92613209e-08, -0.974474192),
        CFrame.new(1071.14551, 3.528404, 5038.00293, -0.532300115, 3.38677708e-08, 0.84655571, 6.69992914e-08, 1,
            2.12149165e-09, -0.84655571, 5.7847906e-08, -0.532300115),
        CFrame.new(1022.55457, 16.6277809, 5066.28223, 0.721996129, 0, -0.691897094, 0, 1, 0, 0.691897094, 0, 0.721996129),
    },
    ["Tropical Grove"] = {
        CFrame.new(-2165.05469, 2.77070165, 3639.87451, -0.589090407, -3.61497356e-08, -0.808067143, -3.20645626e-08, 1,
            -2.13606164e-08, 0.808067143, 1.3326984e-08, -0.589090407)
    },
    ["Vulcano"] = {
        CFrame.new(-701.447937, 48.1446075, 93.1546631, -0.0770962164, 1.34335654e-08, -0.997023642, 9.84464776e-09, 1,
            1.27124169e-08, 0.997023642, -8.83526763e-09, -0.0770962164),
        CFrame.new(-654.994934, 57.2567711, 75.098526, -0.540957272, 2.58946509e-09, -0.841050088, -7.58775585e-08, 1,
            5.18827363e-08, 0.841050088, 9.1883166e-08, -0.540957272),
    },
    ["Coral Reefs"] = {
        CFrame.new(-3118.39624, 2.42531538, 2135.26392, 0.92336154, -1.0069185e-07, -0.383931547, 8.0607947e-08, 1,
            -6.84016968e-08, 0.383931547, 3.22115596e-08, 0.92336154),
    },
    ["Winter"] = {
        CFrame.new(2036.15308, 6.54998732, 3381.88916, 0.943401575, 4.71338666e-08, -0.331652641, -3.28136842e-08, 1,
            4.87781051e-08, 0.331652641, -3.51345975e-08, 0.943401575),
    },
    ["Machine"] = {
        CFrame.new(-1459.3772, 14.7103214, 1831.5188, 0.777951121, 2.52131862e-08, -0.628324807, -5.24126378e-08, 1,
            -2.47663063e-08, 0.628324807, 5.21991339e-08, 0.777951121)
    },
    ["Treasure Room"] = {
        CFrame.new(-3625.0708, -279.074219, -1594.57605, 0.918176472, -3.97606392e-09, -0.396171629, -1.12946204e-08, 1,
            -3.62128851e-08, 0.396171629, 3.77244298e-08, 0.918176472),
        CFrame.new(-3600.72632, -276.06427, -1640.79663, -0.696130812, -6.0491181e-09, 0.717914939, -1.09490363e-08, 1,
            -2.19084972e-09, -0.717914939, -9.38559541e-09, -0.696130812),
        CFrame.new(-3548.52222, -269.309845, -1659.26685, 0.0472991578, -4.08685423e-08, 0.998880744, -7.68598838e-08, 1,
            4.45538149e-08, -0.998880744, -7.88812216e-08, 0.0472991578),
        CFrame.new(-3581.84155, -279.09021, -1696.15637, -0.999634147, -0.000535600528, -0.0270430837, -0.000448358158,
            0.999994695, -0.00323198596, 0.0270446707, -0.00321867829, -0.99962908),
        CFrame.new(-3601.34302, -282.790955, -1629.37036, -0.526346684, 0.00143659476, 0.850268841, -0.000266355521,
            0.999998271, -0.00185445137, -0.850269973, -0.00120255165, -0.526345372)
    },
    ["Sisyphus Statue"] = {
        CFrame.new(-3777.43433, -135.074417, -975.198975, -0.284491211, -1.02338751e-08, -0.958678663, 6.38407585e-08, 1,
            -2.96199456e-08, 0.958678663, -6.96293867e-08, -0.284491211),
        
        CFrame.new(-3697.77124, -135.074417, -886.946411, 0.979794085, -9.24526766e-09, 0.200008959, 1.35701708e-08, 1,
            -2.02526174e-08, -0.200008959, 2.25575487e-08, 0.979794085),
        CFrame.new(-3764.021, -135.074417, -903.742493, 0.785813689, -3.05788426e-08, -0.618463278, -4.87374336e-08, 1,
            -1.11368585e-07, 0.618463278, 1.17657272e-07, 0.785813689)
    },
    ["Fisherman Island"] = {
        CFrame.new(-75.2439423, 3.24433279, 3103.45093, -0.996514142, -3.14880424e-08, -0.0834242329, -3.84156422e-08, 1,
            8.14354024e-08, 0.0834242329, 8.43563228e-08, -0.996514142),
        CFrame.new(-162.285294, 3.26205397, 2954.47412, -0.74356699, -1.93168272e-08, -0.668661416, 1.03873425e-08, 1,
            -4.04397653e-08, 0.668661416, -3.70152904e-08, -0.74356699),
        CFrame.new(-69.8645096, 3.2620542, 2866.48096, 0.342575252, 8.79649331e-09, 0.939490378, 4.78986739e-10, 1,
            -9.53770485e-09, -0.939490378, 3.71738529e-09, 0.342575252),
        CFrame.new(247.130951, 2.47001815, 3001.72412, -0.724809051, -8.27166033e-08, -0.688949764, -8.16509669e-08, 1,
            -3.41610367e-08, 0.688949764, 3.14931867e-08, -0.724809051)
    },
    ["Esoteric Depths"] = {
        CFrame.new(3253.26099, -1293.7677, 1435.24756, 0.21652025, -3.88184027e-08, -0.976278126, 1.20091812e-08, 1,
            -3.70982107e-08, 0.976278126, -3.69178754e-09, 0.21652025),
        CFrame.new(3299.66333, -1302.85474, 1370.98621, -0.440755099, -5.91509552e-09, 0.897627413, -2.5926683e-09, 1,
            5.31664224e-09, -0.897627413, 1.60869356e-11, -0.440755099),
        CFrame.new(3250.94531, -1302.85547, 1324.77942, -0.998184919, 5.84032058e-08, 0.0602233484, 5.50187451e-08, 1,
            -5.78567096e-08, -0.0602233484, -5.44382814e-08, -0.998184919),
        CFrame.new(3219.16309, -1294.03394, 1364.41492, 0.676777482, -4.18104094e-08, -0.736187637, 8.28715798e-08, 1,
            1.93907237e-08, 0.736187637, -7.41322381e-08, 0.676777482)
    },
    ["Kohana"] = {
        CFrame.new(-921.516602, 24.5000591, 373.572754, -0.315036476, -3.65496575e-08, -0.949079573, -2.09816324e-08, 1,
            -3.15460156e-08, 0.949079573, 9.97509186e-09, -0.315036476),
        CFrame.new(-821.466125, 18.0640106, 442.570953, 0.502961993, 3.55151641e-08, 0.864308536, -2.61714685e-08, 1,
            -2.58610324e-08, -0.864308536, -9.61310764e-09, 0.502961993),
        CFrame.new(-656.069275, 17.2500572, 450.77124, 0.899714053, -3.28262595e-09, -0.436479777, -5.17725418e-09, 1,
            -1.81925373e-08, 0.436479777, 1.86278477e-08, 0.899714053),
        CFrame.new(-584.202759, 17.2500572, 459.276672, 0.0987685546, 5.48308599e-09, 0.995110452, -6.92575881e-08, 1,
            1.36405531e-09, -0.995110452, -6.90536694e-08, 0.0987685546),
    },
    ["Underground Cellar"] = {
        CFrame.new(2159.65723, -91.198143, -730.99707, -0.392579645, -1.64555736e-09, 0.919718027, 4.08579943e-08, 1,
            1.92293435e-08, -0.919718027, 4.51268818e-08, -0.392579645),
        CFrame.new(2114.22144, -91.1976471, -732.656738, -0.543168366, -3.4070105e-08, -0.839623809, 2.10003783e-08, 1,
            -5.41633582e-08, 0.839623809, -4.70522394e-08, -0.543168366),
        CFrame.new(2134.35767, -91.1985855, -698.182983, 0.989448071, -1.28799131e-08, -0.144888103, 2.66212989e-08, 1,
            9.29025887e-08, 0.144888103, -9.57793915e-08, 0.989448071),
    },
    ["Ancient Jungle"] = {
        CFrame.new(1515.67676, 25.5616989, -306.595856, 0.763029754, -8.87780942e-08, 0.646363378, 5.24343307e-08, 1,
            7.5451581e-08, -0.646363378, -2.36801707e-08, 0.763029754),
        CFrame.new(1489.29553, 6.23855162, -342.620209, -0.831362545, 6.32348289e-08, -0.555730462, 7.59748353e-09, 1,
            1.02421176e-07, 0.555730462, 8.09269736e-08, -0.831362545),
        CFrame.new(1467.59143, 7.2090292, -324.716827, -0.086521171, 2.06461745e-08, -0.996250033, -4.92800183e-08, 1,
            2.50037022e-08, 0.996250033, 5.12585707e-08, -0.086521171),
    },
    ["Secret Farm Ancient"] = {
        CFrame.new(2110.91431, -58.1463356, -732.848816, 0.0894816518, -9.7328666e-08, -0.995988488, 5.18647809e-08, 1,
            -9.30610398e-08, 0.995988488, -4.3329468e-08, 0.0894816518)
    },
    ["The Temple (Unlock First)"] = {
        CFrame.new(1479.11865, -22.1250019, -662.669373, 0.161120579, -2.03902815e-08, -0.986934721, -3.03227985e-08, 1,
            -2.56105164e-08, 0.986934721, 3.40530022e-08, 0.161120579),
        CFrame.new(1465.41211, -22.1250019, -670.940002, -0.21706377, -2.10148947e-08, 0.976157427, 3.29077707e-08, 1,
            2.88457365e-08, -0.976157427, 3.83845311e-08, -0.21706377),
        CFrame.new(1470.30334, -12.2246475, -587.052612, -0.101084575, -9.68974163e-08, 0.994877815, -1.47451953e-08, 1,
            9.5898109e-08, -0.994877815, -4.97584818e-09, -0.101084575),
        CFrame.new(1451.19983, -22.1250019, -621.852478, -0.986927867, 8.68970318e-09, -0.161162451, 9.61592317e-09, 1,
            -4.96716179e-09, 0.161162451, -6.4519563e-09, -0.986927867),
        CFrame.new(1499.44788, -22.1250019, -628.441711, -0.985374331, 7.20484294e-08, -0.170403719, 8.45688035e-08, 1,
            -6.62162876e-08, 0.170403719, -7.9658669e-08, -0.985374331)
    },
    ["Ancient Ruin"] = {
        CFrame.new(6096.86865, -585.924683, 4667.34521, -0.0791911632, 5.17708685e-08, 0.996859431, -4.35256062e-08, 1, -5.53916735e-08, -0.996859431, -4.77754405e-08, -0.0791911632),
        CFrame.new(6022.87109, -585.924194, 4631.0127, -0.669677734, -6.96009084e-10, -0.74265182, -5.20333909e-09, 1, 3.75485687e-09, 0.74265182, 6.37881348e-09, -0.669677734),
        CFrame.new(6057.14893, -557.975098, 4485.46631, -0.985172093, -3.35700534e-08, -0.171569183, -3.98707982e-08, 1, 3.32783721e-08, 0.171569183, 3.9625526e-08, -0.985172093)
    },
    ["Iron Cavern"] = {
        CFrame.new(-8797.98438, -585.000061, 81.8659973, 0.621304512, 7.69412338e-08, -0.783569217, -8.01423212e-08, 1, 3.4647158e-08, 0.783569217, 4.12706207e-08, 0.621304512),
        CFrame.new(-8788.70508, -585.000061, 96.8170547, 0.814901888, 2.71509681e-09, -0.579598963, -5.01786808e-08, 1, -6.58655495e-08, 0.579598963, 8.27574738e-08, 0.814901888),
        CFrame.new(-8754.25977, -580.000061, 267.518188, 0.866729259, -4.04597955e-08, 0.498778909, 1.90199643e-08, 1, 4.806666e-08, -0.498778909, -3.21740252e-08, 0.866729259)
    },
    ["The Iron Cafe"] = {
        CFrame.new(-8618.95898, -547.500183, 177.389847, 0.981545031, 6.44111608e-08, 0.191231206, -7.8954109e-08, 1, 6.84294932e-08, -0.191231206, -8.22651174e-08, 0.981545031),
        CFrame.new(-8608.74414, -547.500183, 159.39743, -0.0346038602, -1.00222408e-08, 0.999401093, 7.37646433e-09, 1, 1.02836539e-08, -0.999401093, 7.72790099e-09, -0.0346038602),
        CFrame.new(-8617.29395, -547.500183, 145.088608, -0.997185349, 1.96364649e-08, -0.0749754608, 1.6428654e-08, 1, 4.34015313e-08, 0.0749754608, 4.20476276e-08, -0.997185349)
    }

}

local function startAutoFarmLoop()
    NotifySuccess("Auto Farm Enabled", "Fishing started on island: " .. selectedIsland)

    while isAutoFarmRunning do
        local islandSpots = farmLocations[selectedIsland]
        if type(islandSpots) == "table" and #islandSpots > 0 then
            location = islandSpots[math.random(1, #islandSpots)]
        else
            location = islandSpots
        end

        if not location then
            NotifyError("Invalid Island", "Selected island name not found.")
            return
        end

        local char = workspace:FindFirstChild("Characters"):FindFirstChild(LocalPlayer.Name)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            NotifyError("Teleport Failed", "HumanoidRootPart not found.")
            return
        end

        hrp.CFrame = location
        task.wait(1.5)
        
        _G.ConfirmFishType = false
        _G.DialogFish = Window:Dialog({
            Icon = "flame",
            Title = "SELECT YOUR FISHING TYPE!",
            Content = "Please select Auto Fish type!",
            Buttons = {
                {
                    Title = "Auto Fishing Instant",
                    Callback = function()
                        StartAutoFish5X()
                        _G.ConfirmFishType = true
                    end,
                },
                {
                    Title = "Auto Fishing Otomatis",
                    Callback = function()
                        _G.ToggleAutoClick(true)
                        _G.ConfirmFishType = true
                    end,
                },
            },
        })
    
        repeat task.wait() until _G.ConfirmFishType

        while isAutoFarmRunning do
            if not isAutoFarmRunning then
                StopAutoFish5X()
                _G.ToggleAutoClick(false)
                StopCast()
                NotifyWarning("Auto Farm Stopped", "Auto Farm manually disabled. Auto Fish stopped.")
                break
            end
            task.wait(0.5)
        end
    end
end

local nameList = {}
local islandNamesToCode = {}

for code, name in pairs(islandCodes) do
    table.insert(nameList, name)
    islandNamesToCode[name] = code
end

table.sort(nameList)

_G.FarmSec = AutoFarmTab:Section({
    Title = "Farming Island Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

_G.ArtSec = AutoFarmTab:Section({
    Title = "Farming Artifact Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

_G.RuinSec = AutoFarmTab:Section({
    Title = "Farming Ancient Ruin Menu",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

_G.CavernSec = AutoFarmTab:Section({
    Title = "Farming The Iron Cafe",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

-- =======================================================
-- == AUTO LOCHNESS (FIXED WITH REAL-TIME .Changed EVENT)
-- =======================================================

_G.AutoLochNess = false
_G.LochStatus = "Idle"
_G.OriginalCFrame = nil
_G.EventEndTime = nil
_G.countdownPath = workspace["!!! MENU RINGS"]["Event Tracker"].Main.Gui.Content.Items.Countdown.Label

local LOCHNESS_CFRAME = CFrame.new(
    6003.8374, -585.924683, 4661.7334,
    0.0215646587, -8.31839486e-08, -0.999767482,
    -5.35441309e-08, 1, -8.43582271e-08,
    0.999767482, 5.5350835e-08, 0.0215646587
)

_G.Lochness = _G.FarmSec:Paragraph({
    Title = "Ancient Lochness Monster",
    Desc = string.format([[
Status : Idle
Countdown : %s
]], _G.countdownPath and _G.countdownPath.Text or "Loading..."),
    Locked = false,
    Buttons = {}
})

function _G.updateStatus(text, currentCountdown)
    _G.LochStatus = text
    _G.Lochness:SetDesc(string.format([[
Status : %s
Countdown : %s
]], text, currentCountdown or _G.countdownPath.Text))
end

_G.FarmSec:Toggle({
    Title = "Auto Teleport Monster",
    Value = false,
    Callback = function(state)
        _G.AutoLochNess = state
        
        if state then
            if not _G.OriginalCFrame and game.Players.LocalPlayer.Character then
                local root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    _G.OriginalCFrame = root.CFrame
                end
            end
            _G.updateStatus("Monitoring…")
        else
            _G.updateStatus("Idle")
        end
    end
})


function _G.OnCountdownChanged()
    
    local newText = _G.countdownPath.Text

    if not _G.AutoLochNess then
        return
    end


    _G.Lochness:SetDesc(string.format([[
Status : %s
Countdown : %s
]], _G.LochStatus, newText))
    
    if _G.EventEndTime then
        if tick() >= _G.EventEndTime then
            _G.updateStatus("Returning to original position…", newText)
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and _G.OriginalCFrame then
                char.HumanoidRootPart.CFrame = _G.OriginalCFrame
            end
            _G.EventEndTime = nil
            _G.updateStatus("Done — Monitoring…", newText)
        end
        return
    end

    local h = tonumber(newText:match("(%d+)H")) or 0
    local m = tonumber(newText:match("(%d+)M")) or 0
    local s = tonumber(newText:match("(%d+)S")) or 0

    local shouldTeleport = false
    
    if newText == "0H 0M 10S" then
        shouldTeleport = true
    
    elseif h == 0 and m == 0 and s <= 10 and s >= 1 then
        shouldTeleport = true
    end


    if shouldTeleport then
        _G.updateStatus("Teleporting to LochNess…", newText)
    
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = LOCHNESS_CFRAME
        end
    
        _G.EventEndTime = tick() + (12 * 60) -- Set 10 menit timer
        _G.updateStatus("Waiting for event to end…", newText)
    end
end

if _G.countdownPath then
    _G.countdownPath:GetPropertyChangedSignal("Text"):Connect(_G.OnCountdownChanged)
end


task.spawn(function()
    while task.wait(1) do
        if not _G.Lochness then continue end
        if not _G.countdownPath then continue end
        if not _G.countdownPath.Text then continue end
        _G.Lochness:SetDesc(string.format([[
Status : %s
Countdown : %s
]], _G.LochStatus, _G.countdownPath.Text))
    end
end)


_G.FarmSec:Space()

_G.CodeIsland = _G.FarmSec:Dropdown({
    Title = "Farm Island",
    Values = nameList,
    Value = nameList[9],
    SearchBarEnabled = true,
    Callback = function(selectedName)
        local code = islandNamesToCode[selectedName]
        local islandName = islandCodes[code]
        if islandName and farmLocations[islandName] then
            selectedIsland = islandName
            NotifySuccess("Island Selected", "Farming location set to " .. islandName)
        else
            NotifyError("Invalid Selection", "The island name is not recognized.")
        end
    end
})

myConfig:Register("IslCode", _G.CodeIsland)

_G.AutoFarm = _G.FarmSec:Toggle({
    Title = "Start Auto Farm",
    Callback = function(state)
        isAutoFarmRunning = state
        if state then
            startAutoFarmLoop()
        else
            StopAutoFish5X()
        end
    end
})

myConfig:Register("AutoFarmStart", _G.AutoFarm)


local eventNamesForDropdown = {}
for name in pairs(eventMap) do
    table.insert(eventNamesForDropdown, name)
end

_G.FarmSec:Dropdown({
    Title = "Auto Teleport Event",
    Values = eventNamesForDropdown,
    SearchBarEnabled = true,
    Callback = function(selected)
        selectedEvent = selected
        autoTPEvent = true
        NotifyInfo("Event Selected", "Now monitoring event: " .. selectedEvent)
    end
})


-------------------------------------------
----- =======[ ARTIFACT TAB ]
-------------------------------------------

local REPlaceLeverItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/PlaceLeverItem"]

_G.UnlockTemple = function()
    task.spawn(function()
        local Artifacts = {
            "Hourglass Diamond Artifact",
            "Crescent Artifact",
            "Arrow Artifact",
            "Diamond Artifact"
        }

        for _, artifact in ipairs(Artifacts) do
            REPlaceLeverItem:FireServer(artifact)
            NotifyInfo("Temple Unlock", "Placing: " .. artifact)
            task.wait(2.1)
        end

        NotifySuccess("Temple Unlock", "All Artifacts placed successfully!")
    end)
end


_G.ArtifactSpots = {
    ["Spot 1"] = CFrame.new(1404.16931, 6.38866091, 118.118126, -0.964853525, 8.69606822e-08, 0.262788326, 9.85441346e-08,
        1, 3.08992689e-08, -0.262788326, 5.5709517e-08, -0.964853525),
    ["Spot 2"] = CFrame.new(883.969788, 6.62499952, -338.560059, -0.325799465, 2.72482961e-08, 0.945438921,
        3.40634649e-08, 1, -1.70824759e-08, -0.945438921, 2.6639464e-08, -0.325799465),
    ["Spot 3"] = CFrame.new(1834.76819, 6.62499952, -296.731476, 0.413336992, -7.92166972e-08, -0.910578132,
        3.06007166e-08, 1, -7.31055181e-08, 0.910578132, 2.35287234e-09, 0.413336992),
    ["Spot 4"] = CFrame.new(1483.25586, 6.62499952, -848.38031, -0.986296117, 2.72397838e-08, 0.164984599, 3.60663037e-08,
        1, 5.05033348e-08, -0.164984599, 5.57616318e-08, -0.986296117)
}

local REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]

local saveFile = "ArtifactProgress.json"

if isfile(saveFile) then
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(saveFile))
    end)
    if success and type(data) == "table" then
        _G.ArtifactCollected = data.ArtifactCollected or 0
        _G.CurrentSpot = data.CurrentSpot or 1
    else
        _G.ArtifactCollected = 0
        _G.CurrentSpot = 1
    end
else
    _G.ArtifactCollected = 0
    _G.CurrentSpot = 1
end

_G.ArtifactFarmEnabled = false

local function saveProgress()
    local data = {
        ArtifactCollected = _G.ArtifactCollected,
        CurrentSpot = _G.CurrentSpot
    }
    writefile(saveFile, game:GetService("HttpService"):JSONEncode(data))
end

_G.StartArtifactFarm = function()
    if _G.ArtifactFarmEnabled then return end
    _G.ArtifactFarmEnabled = true

    updateParagraphArtifact("Auto Farm Artifact", ("Resuming from Spot %d..."):format(_G.CurrentSpot))

    local Player = game.Players.LocalPlayer
    task.wait(1)
    Player.Character:PivotTo(_G.ArtifactSpots["Spot " .. tostring(_G.CurrentSpot)])
    task.wait(1)

    _G.ConfirmFishType = false
    _G.DialogFish = Window:Dialog({
            Icon = "flame",
            Title = "SELECT YOUR FISHING TYPE!",
            Content = "Please select Auto Fish type!",
            Buttons = {
                {
                    Title = "Auto Fishing Instant",
                    Callback = function()
                        StartAutoFish5X()
                        _G.ConfirmFishType = true
                    end,
                },
                {
                    Title = "Auto Fishing Otomatis",
                    Callback = function()
                        _G.ToggleAutoClick(true)
                        _G.ConfirmFishType = true
                    end,
                },
            },
        })
    
    repeat task.wait() until _G.ConfirmFishType
    _G.AutoFishStarted = true

    _G.ArtifactConnection = _G.REFishCaught.OnClientEvent:Connect(function(fishName, data)
        if string.find(fishName) then
            _G.ArtifactCollected += 1
            saveProgress()

            updateParagraphArtifact(
                "Auto Farm Artifact",
                ("Artifact Found : %s\nTotal: %d/4"):format(fishName, _G.ArtifactCollected)
            )

            if _G.ArtifactCollected < 4 then
                _G.CurrentSpot += 1
                saveProgress()
                local spotName = "Spot " .. tostring(_G.CurrentSpot)
                if _G.ArtifactSpots[spotName] then
                    task.wait(2)
                    Player.Character:PivotTo(_G.ArtifactSpots[spotName])
                    updateParagraphArtifact("Auto Farm Artifact",
                        ("Artifact Found : %s\nTotal : %d/4\n\nTeleporting to %s..."):format(
                            fishName,
                            _G.ArtifactCollected,
                            spotName
                        )
                    )
                    task.wait(1)
                end
            else
                updateParagraphArtifact("Auto Farm Artifact", "All Artifacts collected! Unlocking Temple...")
                StopAutoFish5X()
                _G.ToggleAutoClick(false)
                StopCast()
                task.wait(1.5)
                if typeof(_G.UnlockTemple) == "function" then
                    _G.UnlockTemple()
                end
                _G.StopArtifactFarm()
                delfile(saveFile)
            end
        end
    end)
end

_G.StopArtifactFarm = function()
    StopAutoFish()
    _G.ArtifactFarmEnabled = false
    _G.AutoFishStarted = false
    if _G.ArtifactConnection then
        _G.ArtifactConnection:Disconnect()
        _G.ArtifactConnection = nil
    end
    saveProgress()
    updateParagraphArtifact("Auto Farm Artifact", "Auto Farm Artifact stopped. Progress saved.")
end

function updateParagraphArtifact(title, desc)
    if _G.ArtifactParagraph then
        _G.ArtifactParagraph:SetDesc(desc)
    end
end

_G.ArtifactParagraph = _G.ArtSec:Paragraph({
    Title = "Auto Farm Artifact",
    Desc = "Waiting for activation...",
    Color = "Green",
})

_G.ArtSec:Space()

_G.ArtSec:Toggle({
    Title = "Auto Farm Artifact",
    Desc = "Automatically collects 4 Artifacts and unlocks The Temple.",
    Default = false,
    Callback = function(state)
        if state then
            _G.StartArtifactFarm()
        else
            _G.StopArtifactFarm()
        end
    end
})

local spotNames = {}
for name in pairs(_G.ArtifactSpots) do
    table.insert(spotNames, name)
end

_G.ArtSec:Dropdown({
    Title = "Teleport to Lever Temple",
    Values = spotNames,
    Value = spotNames[1],
    Callback = function(selected)
        local spotCFrame = _G.ArtifactSpots[selected]
        if spotCFrame then
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if hrp then
                hrp.CFrame = spotCFrame
                NotifySuccess("Lever Temple", "Teleported to " .. selected)
            else
                warn("HumanoidRootPart not found!")
            end
        else
            warn("Invalid teleport spot: " .. tostring(selected))
        end
    end
})

_G.ArtSec:Button({
    Title = "Unlock The Temple",
    Desc = "Still need Artifacts!",
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.UnlockTemple()
    end
})

-------------------------------------------
----- =======[ ANCIENT RUIN FARMING ]
-------------------------------------------


_G.REPlaceItems = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/PlacePressureItem"]


_G.UnlockRuin = function()
    task.spawn(function()
        local Ruins = {
            "Crocodile",
            "Goliath Tiger",
            "Freshwater Piranha",
            "Sacred Guardian Squid",
        }

        for _, ruins in ipairs(Ruins) do
            _G.REPlaceItems:FireServer(ruins)
            NotifyInfo("Ancient Ruin", "Placing: " .. ruins)
            task.wait(2.1)
        end

        NotifySuccess("Ancient Ruin", "All Fish placed successfully!")
    end)
end

_G.TempleSpot = {
    ["Spot 1"] = CFrame.new(1466.27673, -22.1250019, -658.204651, -0.0791874304, 1.48164281e-08, 0.996859729, -8.54522781e-08, 1, -2.16511644e-08, -0.996859729, -8.68984387e-08, -0.0791874304),
    ["Spot 2"] = CFrame.new(1502.93958, -22.1250019, -627.15155, -0.994363189, 2.65133604e-08, -0.106027618, 2.21884164e-08, 1, 4.19703348e-08, 0.106027618, 3.93811703e-08, -0.994363189),
    ["Spot 3"] = CFrame.new(1466.27673, -22.1250019, -658.204651, -0.0791874304, 1.48164281e-08, 0.996859729, -8.54522781e-08, 1, -2.16511644e-08, -0.996859729, -8.68984387e-08, -0.0791874304),
    ["Spot 4"] = CFrame.new(1502.93958, -22.1250019, -627.15155, -0.994363189, 2.65133604e-08, -0.106027618, 2.21884164e-08, 1, 4.19703348e-08, 0.106027618, 3.93811703e-08, -0.994363189),
}

_G.REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]

_G.saveFile = "RuinsProgress.json"

if isfile(_G.saveFile) then
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(_G.saveFile))
    end)
    if success and type(data) == "table" then
        _G.FishCollected = data.FishCollected or 0
        _G.CurrentSpot = data.CurrentSpot or 1
    else
        _G.FishCollected = 0
        _G.CurrentSpot = 1
    end
else
    _G.FishCollected = 0
    _G.CurrentSpot = 1
end

_G.RuinFarmEnabled = false

local function saveProgress()
    local data = {
        FishCollected = _G.FishCollected,
        CurrentSpot = _G.CurrentSpot
    }
    writefile(_G.saveFile, game:GetService("HttpService"):JSONEncode(data))
end

_G.StartRuinFarm = function()
    if _G.RuinFarmEnabled then return end
    _G.RuinFarmEnabled = true

    updateParagraph("Auto Farm Ancient Ruin", ("Resuming from Spot %d..."):format(_G.CurrentSpot))

    local Player = game.Players.LocalPlayer
    task.wait(1)
    Player.Character:PivotTo(_G.TempleSpot["Spot " .. tostring(_G.CurrentSpot)])
    task.wait(1)

    _G.ConfirmFishType = false
    _G.DialogFish = Window:Dialog({
            Icon = "flame",
            Title = "SELECT YOUR FISHING TYPE!",
            Content = "Please select Auto Fish type!",
            Buttons = {
                {
                    Title = "Auto Fishing Instant",
                    Callback = function()
                        StartAutoFish5X()
                        _G.ConfirmFishType = true
                    end,
                },
                {
                    Title = "Auto Fishing Otomatis",
                    Callback = function()
                        _G.ToggleAutoClick(true)
                        _G.ConfirmFishType = true
                    end,
                },
            },
        })
    
    repeat task.wait() until _G.ConfirmFishType
    _G.AutoFishStarted = true

    _G.RuinConnection = REFishCaught.OnClientEvent:Connect(function(fishName, data)
        if string.find(fishName, "Artifact") then
            _G.FishCollected += 1
            saveProgress()

            updateParagraph(
                "Auto Farm Ancient Ruin",
                ("Fish Found : %s\nTotal: %d/4"):format(fishName, _G.FishCollected)
            )

            if _G.FishCollected < 4 then
                _G.CurrentSpot += 1
                saveProgress()
                local spotName = "Spot " .. tostring(_G.CurrentSpot)
                if _G.TempleSpot[spotName] then
                    task.wait(2)
                    Player.Character:PivotTo(_G.TempleSpot[spotName])
                    updateParagraph("Auto Farm Ancient Ruin",
                        ("Fish Found : %s\nTotal : %d/4\n\nTeleporting to %s..."):format(
                            fishName,
                            _G.FishCollected,
                            spotName
                        )
                    )
                    task.wait(1)
                end
            else
                updateParagraph("Auto Farm Ancient Ruin", "All Fish collected! Unlocking Ancient Ruin...")
                StopAutoFish5X()
                _G.ToggleAutoClick(false)
                StopCast()
                task.wait(1.5)
                if typeof(_G.UnlockRuin) == "function" then
                    _G.UnlockRuin()
                end
                _G.StopRuinFarm()
                delfile(_G.saveFile)
            end
        end
    end)
end

_G.StopRuinFarm = function()
    StopAutoFish5X()
    _G.RuinFarmEnabled = false
    _G.AutoFishStarted = false
    if _G.RuinConnection then
        _G.RuinConnection:Disconnect()
        _G.RuinConnection = nil
    end
    saveProgress()
    updateParagraph("Auto Farm Ancient Ruin", "Auto Farm stopped. Progress saved.")
end

function updateParagraph(title, desc)
    if _G.RuinParagraph then
        _G.RuinParagraph:SetDesc(desc)
    end
end

_G.RuinParagraph = _G.RuinSec:Paragraph({
    Title = "Auto Farm Ancient Ruin",
    Desc = "Waiting for activation...",
    Color = "Green",
})

_G.RuinSec:Space()

_G.RuinSec:Toggle({
    Title = "Auto Farm Ancient Ruin",
    Desc = "Automatically collects 4 Fish and unlocks Ancient Ruin.",
    Default = false,
    Callback = function(state)
        if state then
            _G.StartRuinFarm()
        else
            _G.StopRuinFarm()
        end
    end
})


_G.RuinSec:Button({
    Title = "Unlock Ancient Ruin",
    Desc = "Still need 4 Fish!",
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.UnlockRuin()
    end
})


-------------------------------------------
----- =======[ IRON CAVERN FARMING ]
-------------------------------------------

_G.REPlaceItems2 = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/PlaceCavernTotemItem"]

_G.UnlockCafe = function()
    task.spawn(function()
        local Cafes = {
            "Guest Guppy",
            "Builderman Guppy",
            "Brighteyes Guppy",
            "Shedletsky Guppy",
        }

        for _, cafe in ipairs(Cafes) do
            _G.REPlaceItems2:FireServer(cafe)
            NotifyInfo("The Iron Cafe", "Placing: " .. ruins)
            task.wait(2.1)
        end

        NotifySuccess("The Iron Cafe", "All Fish placed successfully!")
    end)
end

_G.CavernSpot = {
    ["Spot 1"] = CFrame.new(-8797.98438, -585.000061, 81.8659973, 0.621304512, 7.69412338e-08, -0.783569217, -8.01423212e-08, 1, 3.4647158e-08, 0.783569217, 4.12706207e-08, 0.621304512),
    ["Spot 2"] = CFrame.new(-8781.08594, -585.000061, 220.914062, -0.744228005, -2.82071593e-08, -0.667925656, -7.50003579e-08, 1, 4.13372483e-08, 0.667925656, 8.0859003e-08, -0.744228005),
    ["Spot 3"] = CFrame.new(-8788.70508, -585.000061, 96.8170547, 0.814901888, 2.71509681e-09, -0.579598963, -5.01786808e-08, 1, -6.58655495e-08, 0.579598963, 8.27574738e-08, 0.814901888),
    ["Spot 4"] = CFrame.new(-8754.25977, -580.000061, 267.518188, 0.866729259, -4.04597955e-08, 0.498778909, 1.90199643e-08, 1, 4.806666e-08, -0.498778909, -3.21740252e-08, 0.866729259),
}

_G.REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]

_G.username = LocalPlayer.Name
_G.saveFile = _G.username .. "_ProgressCafe.json"

if isfile(_G.saveFile) then
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(_G.saveFile))
    end)
    if success and type(data) == "table" then
        _G.FishCollected = data.FishCollected or 0
        _G.CurrentSpot = data.CurrentSpot or 1
    else
        _G.FishCollected = 0
        _G.CurrentSpot = 1
    end
else
    _G.FishCollected = 0
    _G.CurrentSpot = 1
end

_G.CavernFarmEnabled = false

local function saveProgress()
    local data = {
        FishCollected = _G.FishCollected,
        CurrentSpot = _G.CurrentSpot
    }
    writefile(_G.saveFile, game:GetService("HttpService"):JSONEncode(data))
end

_G.StartCavernFarm = function()
    if _G.CavernFarmEnabled then return end
    _G.CavernFarmEnabled = true

    updateParagraphCavern("Auto The Iron Cafe", ("Resuming from Spot %d..."):format(_G.CurrentSpot))

    local Player = game.Players.LocalPlayer
    task.wait(1)
    Player.Character:PivotTo(_G.CavernSpot["Spot " .. tostring(_G.CurrentSpot)])
    task.wait(1)

    _G.ConfirmFishType = false
    _G.DialogFish = Window:Dialog({
            Icon = "flame",
            Title = "SELECT YOUR FISHING TYPE!",
            Content = "Please select Auto Fish type!",
            Buttons = {
                {
                    Title = "Auto Fishing Instant",
                    Callback = function()
                        StartAutoFish5X()
                        _G.ConfirmFishType = true
                    end,
                },
                {
                    Title = "Auto Fishing Otomatis",
                    Callback = function()
                        _G.ToggleAutoClick(true)
                        _G.ConfirmFishType = true
                    end,
                },
            },
        })
    
    repeat task.wait() until _G.ConfirmFishType
    _G.AutoFishStarted = true

    _G.CavernConnection = REFishCaught.OnClientEvent:Connect(function(fishName, data)
        if string.find(fishName, "Guppy") then
            _G.FishCollected += 1
            saveProgress()

            updateParagraphCavern(
                "Auto The Iron Cafe",
                ("Fish Found : %s\nTotal: %d/4"):format(fishName, _G.FishCollected)
            )

            if _G.FishCollected < 4 then
                _G.CurrentSpot += 1
                saveProgress()
                local spotName = "Spot " .. tostring(_G.CurrentSpot)
                if _G.CavernSpot[spotName] then
                    task.wait(2)
                    Player.Character:PivotTo(_G.CavernSpot[spotName])
                    updateParagraphCavern("Auto The Iron Cafe",
                        ("Fish Found : %s\nTotal : %d/4\n\nTeleporting to %s..."):format(
                            fishName,
                            _G.FishCollected,
                            spotName
                        )
                    )
                    task.wait(1)
                end
            else
                updateParagraphCavern("Auto The Iron Cafe", "All Fish collected! Unlocking The Iron Cafe...")
                StopAutoFish5X()
                _G.ToggleAutoClick(false)
                StopCast()
                task.wait(1.5)
                if typeof(_G.UnlockCafe) == "function" then
                    _G.UnlockCafe()
                end
                _G.StopCavernFarm()
                delfile(_G.saveFile)
            end
        end
    end)
end

_G.StopCavernFarm = function()
    StopAutoFish5X()
    _G.CavernFarmEnabled = false
    _G.AutoFishStarted = false
    if _G.CavernConnection then
        _G.CavernConnection:Disconnect()
        _G.CavernConnection = nil
    end
    saveProgress()
    updateParagraphCavern("Auto The Iron Cafe", "Auto Farm stopped. Progress saved.")
end

function updateParagraphCavern(title, desc)
    if _G.CavernParagraph then
        _G.CavernParagraph:SetDesc(desc)
    end
end

_G.CavernParagraph = _G.CavernSec:Paragraph({
    Title = "Auto The Iron Cafe",
    Desc = "Waiting for activation...",
    Color = "Green",
})

_G.CavernSec:Space()

_G.CavernSec:Toggle({
    Title = "Auto Farm Iron Cafe",
    Desc = "Automatically collects 4 Fish and unlocks The Iron Cafe.",
    Default = false,
    Callback = function(state)
        if state then
            _G.StartCavernFarm()
        else
            _G.StopCavernFarm()
        end
    end
})


_G.CavernSec:Button({
    Title = "Unlock The Iron Cafe",
    Desc = "Still need 4 Fish!",
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.UnlockCafe()
    end
})


-- ===================================================================
-- AUTO QUEST V2 ENHANCED (GHOSTFINN, ELEMENT, & AURA BOAT)
-- With Auto Task Switching & Priority Selection
-- ===================================================================

_G.ReplicatedStorage = game:GetService("ReplicatedStorage")
_G.Players = game:GetService("Players")
_G.LocalPlayer = _G.Players.LocalPlayer
_G.Workspace = game:GetService("Workspace")

-- ===================================================================
-- QUEST TRACKER FUNCTIONS (DARI V1)
-- ===================================================================
_G.getQuestTracker = function(questName)
    local menu = _G.Workspace:FindFirstChild("!!! MENU RINGS")
    if not menu then return nil end
    
    for _, inst in ipairs(menu:GetChildren()) do
        if inst.Name:find("Tracker") and inst.Name:lower():find(questName:lower()) then
            return inst
        end
    end
    
    return nil
end

_G.getQuestProgress = function(questName)
    local tracker = _G.getQuestTracker(questName)
    if not tracker then return 0 end
    
    local label = tracker:FindFirstChild("Board") 
        and tracker.Board:FindFirstChild("Gui") 
        and tracker.Board.Gui:FindFirstChild("Content") 
        and tracker.Board.Gui.Content:FindFirstChild("Progress") 
        and tracker.Board.Gui.Content.Progress:FindFirstChild("ProgressLabel")
    
    if label and label:IsA("TextLabel") then
        local percent = string.match(label.Text, "([%d%.]+)%%")
        return tonumber(percent) or 0
    end
    
    return 0
end

_G.getAllTasks = function(questName)
    local tracker = _G.getQuestTracker(questName)
    if not tracker then return {} end
    
    local content = tracker:FindFirstChild("Board") 
        and tracker.Board:FindFirstChild("Gui") 
        and tracker.Board.Gui:FindFirstChild("Content")
    
    if not content then return {} end
    
    local tasks = {}
    for _, obj in ipairs(content:GetChildren()) do
        if obj:IsA("TextLabel") and obj.Name:match("Label") and not obj.Name:find("Progress") then
            local txt = obj.Text
            local taskName = txt
            local percent = 0
            local done = false
            
            local percentMatch = string.match(txt, "([%d%.]+)%%")
            if percentMatch then
                percent = tonumber(percentMatch) or 0
                taskName = string.gsub(txt, "%s*%d+%.?%d*%%%s*", "")
            end
            
            if txt:find("✓") or txt:find("✔") or percent >= 100 then
                done = true
            end
            
            taskName = string.gsub(taskName, "^%s*(.-)%s*$", "%1")
            
            table.insert(tasks, {
                name = taskName,
                fullText = txt,
                percent = percent,
                completed = done
            })
        end
    end
    
    return tasks
end

_G.getActiveTasks = function(questName)
    local all = _G.getAllTasks(questName)
    local active = {}
    
    for _, t in ipairs(all) do
        if not t.completed then
            table.insert(active, t)
        end
    end
    
    return active
end

-- ===================================================================
-- LOCATIONS
-- ===================================================================
_G.Locations = {
    TreasureRoom = CFrame.new(-3625.0708, -279.074219, -1594.57605),
    Sisyphus = CFrame.new(-3697.77124, -135.074417, -886.946411),
    AncientJungle = CFrame.new(1515.67676, 25.5616989, -306.595856),
    SacredTemple = CFrame.new(1470.30334, -12.2246475, -587.052612),
    CrystalCrab = CFrame.new(40.0956, 1.7772, 2757.2583),
    FarmingCoin = CFrame.new(-553.3464, 17.1376, 114.2622)
}

-- ===================================================================
-- TASK MAPPING (UNTUK MENENTUKAN LOKASI)
-- ===================================================================
_G.TaskLocationMapping = {
    -- GHOSTFINN ROD (Deep Sea)
    ["SECRET"] = function(taskName)
        if taskName:find("Sisyphus") then
            return "Sisyphus"
        end
        return nil
    end,
    ["Mythic"] = function(taskName)
        if taskName:find("Sisyphus") then
            return "Sisyphus"
        end
        return nil
    end,
    ["Rare"] = function(taskName)
        if taskName:find("Treasure") then
            return "TreasureRoom"
        end
        return nil
    end,
    
    -- ELEMENT ROD
    ["Temple"] = function(taskName)
        return "SacredTemple"
    end,
    ["Jungle"] = function(taskName)
        return "AncientJungle"
    end,
    ["Sacred"] = function(taskName)
        return "SacredTemple"
    end,
    ["Ancient"] = function(taskName)
        return "AncientJungle"
    end,
    
    -- AURA BOAT
    ["Crystal Crab"] = function(taskName)
        return "CrystalCrab"
    end,
    ["Coin"] = function(taskName)
        return "FarmingCoin"
    end,
    ["Epic Fish"] = function(taskName)
        return "CrystalCrab"
    end,
    ["Fish"] = function(taskName)
        if taskName:find("10,000") or taskName:find("10000") then
            return "CrystalCrab"
        end
        return nil
    end,
    ["Stone"] = function(taskName)
        return "Sisyphus"
    end,
    ["Transcended"] = function(taskName)
        return "Sisyphus"
    end
}

_G.findLocationForTask = function(taskName)
    for keyword, locationFunc in pairs(_G.TaskLocationMapping) do
        if taskName:find(keyword) then
            local location = locationFunc(taskName)
            if location then
                return _G.Locations[location], location
            end
        end
    end
    return nil, nil
end

-- ===================================================================
-- TELEPORT FUNCTION
-- ===================================================================
function _G.Teleport(targetCFrame, locationName)
    local char = _G.LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        NotifyInfo("Teleport", "Teleporting to: " .. (locationName or "quest location"))
        root.CFrame = targetCFrame
        task.wait(1)
    else
        NotifyError("Teleport", "Teleport failed, HumanoidRootPart not found.")
    end
end

-- ===================================================================
-- QUEST STATE
-- ===================================================================
_G.QuestState = {
    Active = false,
    CurrentQuest = nil,
    CurrentQuestDisplay = nil,
    SelectedTask = nil,
    SelectedTaskMode = "Auto", -- "Auto" or specific task name
    CurrentLocation = nil,
    Teleported = false,
    Fishing = false,
    LastProgress = 0,
    LastTaskIndex = nil
}

-- ===================================================================
-- TASK SELECTION (STORAGE PER QUEST)
-- ===================================================================
_G.SelectedTaskPriority = {
    ["Deep Sea"] = "Auto",
    ["Element"] = "Auto",
    ["Aura"] = "Auto"
}

-- ===================================================================
-- UPDATE PROGRESS PARAGRAPHS
-- ===================================================================
function _G.UpdateProgressParagraphs()
    local quests = {
        {name = "Deep Sea", paragraph = _G.DS_Paragraph, display = "Ghostfinn Rod"},
        {name = "Element", paragraph = _G.EJ_Paragraph, display = "Element Rod"},
        {name = "Aura", paragraph = _G.Aura_Paragraph, display = "Aura Boat"}
    }
    
    for _, quest in ipairs(quests) do
        local allTasks = _G.getAllTasks(quest.name)
        local progress = _G.getQuestProgress(quest.name)
        
        if #allTasks == 0 then
            quest.paragraph:SetDesc("⏳ Quest not started or not available")
        else
            local text = ""
            local allComplete = true
            
            for _, task in ipairs(allTasks) do
                local icon = task.completed and "✅" or "⏳"
                text = text .. string.format("%s %s: %.1f%%\n", icon, task.name, task.percent)
                if not task.completed then
                    allComplete = false
                end
            end
            
            if allComplete and progress >= 100 then
                text = "✅ ALL QUESTS COMPLETE ✅\n\n" .. text
            end
            
            text = text .. string.format("\n📈 TOTAL PROGRESS: %.1f%%", progress)
            quest.paragraph:SetDesc(text)
        end
    end
end

-- ===================================================================
-- CHECK PROGRESS (SEPERTI V1)
-- ===================================================================
function _G.ShowQuestProgress(questName, displayName)
    local allTasks = _G.getAllTasks(questName)
    
    if #allTasks == 0 then
        NotifyError("No Tasks Found", "Quest not available or not started")
        return
    end
    
    local progress = _G.getQuestProgress(questName)
    local msg = "📊 " .. displayName .. "\n\n"
    
    for i, t in ipairs(allTasks) do
        local icon = t.completed and "✅" or "⏳"
        local status = t.completed and " (DONE)" or ""
        msg = msg .. string.format("%s %s: %.1f%%%s", icon, t.name, t.percent, status)
        if i < #allTasks then msg = msg .. "\n\n" end
    end
    
    msg = msg .. string.format("\n\n📈 TOTAL PROGRESS: %.1f%%", progress)
    
    WindUI:Notify({
        Title = "📋 " .. displayName,
        Content = msg,
        Duration = 8,
        Icon = "info"
    })
end

-- ===================================================================
-- FISHING TYPE SELECTION DIALOG
-- ===================================================================
_G.ConfirmFishType = false
_G.SelectedFishingType = nil

function _G.ShowFishingTypeDialog()
    _G.ConfirmFishType = false
    _G.SelectedFishingType = nil
    
    _G.DialogFish = Window:Dialog({
        Icon = "flame",
        Title = "SELECT YOUR FISHING TYPE!",
        Content = "Please select Auto Fish type!",
        Buttons = {
            {
                Title = "Auto Fishing Instant",
                Callback = function()
                    _G.SelectedFishingType = "Instant"
                    _G.ConfirmFishType = true
                    NotifyInfo("Fishing Type", "Auto Fishing Instant selected")
                end,
            },
            {
                Title = "Auto Fishing Otomatis",
                Callback = function()
                    _G.SelectedFishingType = "Otomatis"
                    _G.ConfirmFishType = true
                    NotifyInfo("Fishing Type", "Auto Fishing Otomatis selected")
                end,
            },
        },
    })
end

function _G.StartSelectedFishingType()
    if _G.SelectedFishingType == "Instant" then
        if StartAutoFish5X then
            StartAutoFish5X()
            NotifySuccess("Fishing Started", "Auto Fishing Instant is running")
        end
    elseif _G.SelectedFishingType == "Otomatis" then
        if _G.ToggleAutoClick then
            _G.ToggleAutoClick(true)
            NotifySuccess("Fishing Started", "Auto Fishing Otomatis is running")
        end
    end
end

function _G.StopAllFishing()
    pcall(function()
        if StopAutoFish5X then
            StopAutoFish5X()
        end
    end)
    
    pcall(function()
        if _G.ToggleAutoClick then
            _G.ToggleAutoClick(false)
        end
    end)
    
    pcall(function()
        if StopCast then
            StopCast()
        end
    end)
    
    pcall(function()
        if Config and Config.AutoFishingNewMethod ~= nil then
            Config.AutoFishingNewMethod = false
        end
    end)
end

-- ===================================================================
-- RESPAWN CHARACTER
-- ===================================================================
function _G.RespawnCharacter()
    local char = _G.LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            NotifyInfo("Respawning", "Character respawning...")
            humanoid.Health = 0
            task.wait(2)
        end
    end
end

-- ===================================================================
-- STOP AUTO QUEST
-- ===================================================================
function _G.StopAutoQuest(shouldRespawn)
    if _G.QuestState.Active then
        NotifyWarning("Auto Quest", "Auto Quest Stopped.")
        
        _G.StopAllFishing()
        
        _G.QuestState.Active = false
        _G.QuestState.CurrentQuest = nil
        _G.QuestState.CurrentQuestDisplay = nil
        _G.QuestState.SelectedTask = nil
        _G.QuestState.SelectedTaskMode = "Auto"
        _G.QuestState.CurrentLocation = nil
        _G.QuestState.Teleported = false
        _G.QuestState.Fishing = false
        _G.ConfirmFishType = false
        _G.SelectedFishingType = nil
        
        if shouldRespawn then
            task.wait(1)
            _G.RespawnCharacter()
        end
    end
end

-- ===================================================================
-- QUEST MONITOR LOOP (AUTO SWITCH TASK + FISHING DIALOG)
-- ===================================================================
task.spawn(function()
    while task.wait(1) do
        if not _G.QuestState.Active then continue end
        
        local questProgress = _G.getQuestProgress(_G.QuestState.CurrentQuest)
        local activeTasks = _G.getActiveTasks(_G.QuestState.CurrentQuest)
        local allTasks = _G.getAllTasks(_G.QuestState.CurrentQuest)
        
        -- Check if all tasks complete
        local allTasksCompleted = true
        for _, task in ipairs(allTasks) do
            if not task.completed and task.percent < 100 then
                allTasksCompleted = false
                break
            end
        end
        
        if allTasksCompleted and questProgress >= 100 then
            WindUI:Notify({
                Title = "✅ Quest Complete",
                Content = _G.QuestState.CurrentQuestDisplay .. " finished! Character will respawn...",
                Duration = 5,
                Icon = "circle-check"
            })
            _G.StopAutoQuest(true) -- Respawn character
            continue
        end
        
        -- Progress notification (every 10%)
        if math.floor(questProgress / 10) > math.floor(_G.QuestState.LastProgress / 10) then
            NotifyInfo("Progress Update", string.format("%s: %.1f%%", _G.QuestState.CurrentQuestDisplay, questProgress))
        end
        _G.QuestState.LastProgress = questProgress
        
        if #activeTasks == 0 then
            WindUI:Notify({
                Title = "✅ All Tasks Done",
                Content = _G.QuestState.CurrentQuestDisplay .. " completed! Character will respawn...",
                Duration = 5,
                Icon = "circle-check"
            })
            _G.StopAutoQuest(true) -- Respawn character
            continue
        end
        
        -- ===================================================================
        -- TASK SELECTION LOGIC (DENGAN PRIORITY)
        -- ===================================================================
        local currentTask = nil
        local currentTaskIndex = nil
        
        -- Mode 1: User selected specific task
        if _G.QuestState.SelectedTaskMode ~= "Auto" then
            for i, t in ipairs(activeTasks) do
                if t.name == _G.QuestState.SelectedTaskMode then
                    currentTask = t
                    currentTaskIndex = i
                    break
                end
            end
            
            -- If selected task is done, switch to Auto mode
            if not currentTask then
                NotifyInfo("Task Completed", _G.QuestState.SelectedTaskMode .. " is done! Switching to next task...")
                _G.QuestState.SelectedTaskMode = "Auto"
                _G.QuestState.SelectedTask = nil
                _G.QuestState.CurrentLocation = nil
                _G.QuestState.Teleported = false
                _G.QuestState.Fishing = false
                _G.ConfirmFishType = false
                _G.SelectedFishingType = nil
                _G.StopAllFishing()
                task.wait(1)
                continue
            end
        end
        
        -- Mode 2: Auto mode - pick first available task
        if not currentTask then
            if _G.QuestState.LastTaskIndex and _G.QuestState.LastTaskIndex <= #activeTasks then
                currentTaskIndex = _G.QuestState.LastTaskIndex
                currentTask = activeTasks[currentTaskIndex]
            else
                currentTaskIndex = 1
                currentTask = activeTasks[1]
            end
            
            if currentTask then
                _G.QuestState.SelectedTask = currentTask.name
                _G.QuestState.LastTaskIndex = currentTaskIndex
                NotifyInfo("Task Selected", string.format("%s (%.1f%%)", currentTask.name, currentTask.percent))
            end
        end
        
        if not currentTask then
            _G.QuestState.SelectedTask = nil
            _G.QuestState.LastTaskIndex = nil
            _G.QuestState.CurrentLocation = nil
            _G.QuestState.Teleported = false
            _G.QuestState.Fishing = false
            continue
        end
        
        -- ===================================================================
        -- AUTO SWITCH TO NEXT TASK WHEN CURRENT TASK COMPLETE
        -- ===================================================================
        if currentTask.percent >= 100 or currentTask.completed then
            WindUI:Notify({
                Title = "✅ Task Completed",
                Content = currentTask.name .. " is done! Moving to next task...",
                Duration = 4,
                Icon = "check-circle"
            })
            
            -- Stop fishing
            _G.StopAllFishing()
            
            -- Reset state for next task
            if currentTaskIndex < #activeTasks then
                _G.QuestState.LastTaskIndex = currentTaskIndex + 1
            else
                _G.QuestState.LastTaskIndex = 1
            end
            
            _G.QuestState.SelectedTask = nil
            _G.QuestState.CurrentLocation = nil
            _G.QuestState.Teleported = false
            _G.QuestState.Fishing = false
            _G.ConfirmFishType = false
            _G.SelectedFishingType = nil
            
            task.wait(2) -- Wait before switching
            continue
        end
        
        -- Find location
        if not _G.QuestState.CurrentLocation then
            local locationCFrame, locationName = _G.findLocationForTask(currentTask.name)
            if locationCFrame then
                _G.QuestState.CurrentLocation = locationCFrame
                _G.QuestState.LocationName = locationName
            else
                NotifyWarning("Location Not Found", "Can't find location for: " .. currentTask.name)
                _G.QuestState.SelectedTask = nil
                continue
            end
        end
        
        -- Teleport
        if not _G.QuestState.Teleported then
            _G.Teleport(_G.QuestState.CurrentLocation, _G.QuestState.LocationName)
            _G.QuestState.Teleported = true
            task.wait(1)
            
            -- ===================================================================
            -- SHOW FISHING TYPE DIALOG AFTER TELEPORT
            -- ===================================================================
            if not _G.ConfirmFishType then
                _G.ShowFishingTypeDialog()
                
                -- Wait for user selection
                local timeout = 0
                repeat 
                    task.wait(0.5)
                    timeout = timeout + 0.5
                    if timeout > 30 then -- 30 second timeout
                        NotifyWarning("Selection Timeout", "No fishing type selected. Defaulting to Instant.")
                        _G.SelectedFishingType = "Instant"
                        _G.ConfirmFishType = true
                        break
                    end
                until _G.ConfirmFishType
            end
            
            task.wait(1)
            continue
        end
        
        -- Start fishing
        if not _G.QuestState.Fishing and _G.ConfirmFishType then
            _G.StartSelectedFishingType()
            _G.QuestState.Fishing = true
            NotifyInfo("Farming Started", string.format("%s (%.1f%%) - %s", currentTask.name, currentTask.percent, _G.SelectedFishingType or "Unknown"))
        end
    end
end)

-- ===================================================================
-- UI PARAGRAPHS
-- ===================================================================
_G.DS_Paragraph = _G.AutoQuestTab:Paragraph({ 
    Title = "Ghostfinn Rod Quest Progress", 
    Desc = "⏳ Waiting for data..." 
})

_G.EJ_Paragraph = _G.AutoQuestTab:Paragraph({ 
    Title = "Element Rod Quest Progress", 
    Desc = "⏳ Waiting for data..." 
})

_G.Aura_Paragraph = _G.AutoQuestTab:Paragraph({ 
    Title = "Aura Boat Quest Progress", 
    Desc = "⏳ Waiting for data..." 
})

-- ===================================================================
-- DROPDOWN REFRESH FUNCTION
-- ===================================================================
function _G.BuildDropdownOptions(questName)
    local opts = {"Auto"}
    local tasks = _G.getActiveTasks(questName)
    for _, t in ipairs(tasks) do
        table.insert(opts, t.name)
    end
    return opts
end

-- ===================================================================
-- UI CONTROLS
-- ===================================================================
_G.AutoQuestTab:Section({
    Title = "Quest Controls",
    TextSize = 20,
    TextXAlignment = "Center",
    Opened = true
})

-- ===================================================================
-- GHOSTFINN ROD
-- ===================================================================
_G.AutoQuestTab:Section({
    Title = "QUEST: Ghostfinn Rod",
    TextSize = 18,
    TextXAlignment = "Center",
    Opened = true
})

local DS_Dropdown = _G.AutoQuestTab:Dropdown({
    Title = "Select Task Priority",
    Desc = "Choose specific task or Auto mode",
    Values = _G.BuildDropdownOptions("Deep Sea"),
    Value = "Auto",
    SearchBarEnabled = true,
    Callback = function(selected)
        _G.SelectedTaskPriority["Deep Sea"] = selected
        NotifyInfo("Task Priority", selected .. " for Ghostfinn Rod")
    end
})

-- Auto refresh dropdown every 10 seconds
task.spawn(function()
    while task.wait(10) do
        pcall(function()
            if DS_Dropdown and DS_Dropdown.Refresh then
                local newOpts = _G.BuildDropdownOptions("Deep Sea")
                DS_Dropdown:Refresh(newOpts)
            end
        end)
    end
end)

_G.AutoQuestTab:Toggle({
    Title = "Auto Ghostfinn Rod Quest",
    Desc = "Automatically farm the quest",
    Value = false,
    Callback = function(state)
        if state then
            if _G.QuestState.Active then
                NotifyWarning("Auto Quest", "Another quest is already running!")
                return false
            end
            
            local tasks = _G.getAllTasks("Deep Sea")
            if #tasks == 0 then
                NotifyError("Quest Error", "Quest not found or not started!")
                return false
            end
            
            local selectedPriority = _G.SelectedTaskPriority["Deep Sea"] or "Auto"
            
            _G.QuestState.Active = true
            _G.QuestState.CurrentQuest = "Deep Sea"
            _G.QuestState.CurrentQuestDisplay = "Ghostfinn Rod Quest"
            _G.QuestState.SelectedTaskMode = selectedPriority
            _G.QuestState.LastProgress = _G.getQuestProgress("Deep Sea")
            
            NotifySuccess("🎯 Quest Started", "Ghostfinn Rod Quest - Mode: " .. selectedPriority)
        else
            _G.StopAutoQuest()
        end
    end
})

_G.AutoQuestTab:Button({
    Title = "Check Progress",
    Desc = "View detailed quest progress",
    Justify = "Center",
    Icon = "bar-chart",
    Callback = function()
        _G.ShowQuestProgress("Deep Sea", "Ghostfinn Rod Quest")
    end
})

_G.AutoQuestTab:Space()

-- ===================================================================
-- ELEMENT ROD
-- ===================================================================
_G.AutoQuestTab:Section({
    Title = "QUEST: Element Rod",
    TextSize = 18,
    TextXAlignment = "Center",
    Opened = true
})

local EJ_Dropdown = _G.AutoQuestTab:Dropdown({
    Title = "Select Task Priority",
    Desc = "Choose specific task or Auto mode",
    Values = _G.BuildDropdownOptions("Element"),
    Value = "Auto",
    SearchBarEnabled = true,
    Callback = function(selected)
        _G.SelectedTaskPriority["Element"] = selected
        NotifyInfo("Task Priority", selected .. " for Element Rod")
    end
})

task.spawn(function()
    while task.wait(10) do
        pcall(function()
            if EJ_Dropdown and EJ_Dropdown.Refresh then
                local newOpts = _G.BuildDropdownOptions("Element")
                EJ_Dropdown:Refresh(newOpts)
            end
        end)
    end
end)

_G.AutoQuestTab:Toggle({
    Title = "Auto Element Rod Quest",
    Desc = "Automatically farm the quest",
    Value = false,
    Callback = function(state)
        if state then
            if _G.QuestState.Active then
                NotifyWarning("Auto Quest", "Another quest is already running!")
                return false
            end
            
            local deepSeaProgress = _G.getQuestProgress("Deep Sea")
            if deepSeaProgress < 100 then
                NotifyWarning("Warning", "Complete Ghostfinn Rod quest first!")
                return false
            end
            
            local tasks = _G.getAllTasks("Element")
            if #tasks == 0 then
                NotifyError("Quest Error", "Quest not found or not started!")
                return false
            end
            
            local selectedPriority = _G.SelectedTaskPriority["Element"] or "Auto"
            
            _G.QuestState.Active = true
            _G.QuestState.CurrentQuest = "Element"
            _G.QuestState.CurrentQuestDisplay = "Element Rod Quest"
            _G.QuestState.SelectedTaskMode = selectedPriority
            _G.QuestState.LastProgress = _G.getQuestProgress("Element")
            
            NotifySuccess("🎯 Quest Started", "Element Rod Quest - Mode: " .. selectedPriority)
        else
            _G.StopAutoQuest()
        end
    end
})

_G.AutoQuestTab:Button({
    Title = "Check Progress",
    Desc = "View detailed quest progress",
    Justify = "Center",
    Icon = "bar-chart",
    Callback = function()
        _G.ShowQuestProgress("Element", "Element Rod Quest")
    end
})

_G.AutoQuestTab:Space()

-- ===================================================================
-- AURA BOAT
-- ===================================================================
_G.AutoQuestTab:Section({
    Title = "QUEST: Aura Boat",
    TextSize = 18,
    TextXAlignment = "Center",
    Opened = true
})

local Aura_Dropdown = _G.AutoQuestTab:Dropdown({
    Title = "Select Task Priority",
    Desc = "Choose specific task or Auto mode",
    Values = _G.BuildDropdownOptions("Aura"),
    Value = "Auto",
    SearchBarEnabled = true,
    Callback = function(selected)
        _G.SelectedTaskPriority["Aura"] = selected
        NotifyInfo("Task Priority", selected .. " for Aura Boat")
    end
})

task.spawn(function()
    while task.wait(10) do
        pcall(function()
            if Aura_Dropdown and Aura_Dropdown.Refresh then
                local newOpts = _G.BuildDropdownOptions("Aura")
                Aura_Dropdown:Refresh(newOpts)
            end
        end)
    end
end)

_G.AutoQuestTab:Toggle({
    Title = "Auto Aura Boat Quest",
    Desc = "Automatically farm the quest",
    Value = false,
    Callback = function(state)
        if state then
            if _G.QuestState.Active then
                NotifyWarning("Auto Quest", "Another quest is already running!")
                return false
            end
            
            local elementProgress = _G.getQuestProgress("Element")
            if elementProgress < 100 then
                NotifyWarning("Warning", "Complete Element Rod quest first!")
                return false
            end
            
            local tasks = _G.getAllTasks("Aura")
            if #tasks == 0 then
                NotifyError("Quest Error", "Quest not found or not started!")
                return false
            end
            
            local selectedPriority = _G.SelectedTaskPriority["Aura"] or "Auto"
            
            _G.QuestState.Active = true
            _G.QuestState.CurrentQuest = "Aura"
            _G.QuestState.CurrentQuestDisplay = "Aura Boat Quest"
            _G.QuestState.SelectedTaskMode = selectedPriority
            _G.QuestState.LastProgress = _G.getQuestProgress("Aura")
            
            NotifySuccess("🎯 Quest Started", "Aura Boat Quest - Mode: " .. selectedPriority)
        else
            _G.StopAutoQuest()
        end
    end
})

_G.AutoQuestTab:Button({
    Title = "Check Progress",
    Desc = "View detailed quest progress",
    Justify = "Center",
    Icon = "bar-chart",
    Callback = function()
        _G.ShowQuestProgress("Aura", "Aura Boat Quest")
    end
})

-- ===================================================================
-- REALTIME UPDATE LOOP
-- ===================================================================
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            _G.UpdateProgressParagraphs()
        end)
    end
end)

-------------------------------------------
----- =======[ MASS TRADE TAB ]
-------------------------------------------

-- [Trade State]
local tradeState = { 
    selectedPlayerName = nil, 
    selectedPlayerId = nil, 
    autoTradeV1 = false,
    saveTempMode = false,
    TempTradeList = {}, 
    onTrade = false 
}

-- Asumsi Modul game inti sudah tersedia
local ItemUtility = _G.ItemUtility or require(ReplicatedStorage.Shared.ItemUtility) 
local ItemStringUtility = _G.ItemStringUtility or require(ReplicatedStorage.Modules.ItemStringUtility)
local InitiateTrade = net:WaitForChild("RF/InitiateTrade") 
local RFAwaitTradeResponse = net:WaitForChild("RF/AwaitTradeResponse") 

-- Fungsi utilitas untuk mendapatkan daftar pemain
local function getPlayerList()
    local list = {}; 
    for _, p in ipairs(Players:GetPlayers()) do 
        if p ~= LocalPlayer then 
            table.insert(list, p.Name) 
        end 
    end; 
    table.sort(list); 
    return list
end

-- =======================================================
-- LOGIKA HOOKING
-- =======================================================

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
_G.REEquipItem = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipItem"]

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    -- Logika Save/Send Trade
    if method == "FireServer" and self == _G.REEquipItem then
        local uuid, categoryName = args[1], args[2]

        if tradeState.saveTempMode then
            if uuid and categoryName then
                table.insert(tradeState.TempTradeList, {
                    UUID = uuid,
                    Category = categoryName
                })
                NotifySuccess("Save Mode", "Added item: " .. uuid .. " (" .. categoryName .. ")")
            else
                NotifyError("Save Mode", "Invalid data received.")
            end
            return nil
        end

        if tradeState.onTrade then
            if uuid and tradeState.selectedPlayerId then
                InitiateTrade:InvokeServer(tradeState.selectedPlayerId, uuid)
                NotifySuccess("Trade Sent", "Trade sent to " .. tradeState.selectedPlayerName or tradeState.selectedPlayerId)
            else
                NotifyError("Trade Error", "Invalid target or item.")
            end
            return nil
        end
    end

	if _G.autoSellMythic 
		and method == "FireServer"
		and self == _G.REEquipItem 
		and typeof(args[1]) == "string"
		and args[2] == "Fishes" then

		local uuid = args[1]

		task.delay(1, function()
			pcall(function()
				local result = RFSellItem:InvokeServer(uuid)
				if result then
					NotifySuccess("AutoSellMythic", "Items Sold!!")
				else
					NotifyError("AutoSellMythic", "Failed to sell item!!")
				end
			end)
		end)
	end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Implementasi Auto Accept Trade
pcall(function()
    local PromptController = _G.PromptController or ReplicatedStorage:WaitForChild("Controllers").PromptController 
    local Promise = _G.Promise or require(ReplicatedStorage.Packages.Promise) 
    
    if PromptController and PromptController.FirePrompt then
        local oldFirePrompt = PromptController.FirePrompt
        PromptController.FirePrompt = function(self, promptText, ...)
            -- Cek apakah Auto Accept aktif dan prompt adalah Trade
            if _G.AutoAcceptTradeEnabled and type(promptText) == "string" and promptText:find("Accept") and promptText:find("from:") then
                -- Mengembalikan Promise yang otomatis me-resolve (menerima) setelah jeda.
                return Promise.new(function(resolve)
                    task.wait(2) -- Tunggu 2 detik
                    resolve(true)
                end)
            end
            return oldFirePrompt(self, promptText, ...)
        end
    end
end)

-- =======================================================
-- DEFINISI UI
-- =======================================================

Trade:Section({Title = "Trade Configuration"})

local playerDropdown = Trade:Dropdown({
    Title = "Select Trade Target",
    Values = getPlayerList(),
    Value = getPlayerList()[1] or nil,
    SearchBarEnabled = true,
    Callback = function(selected)
        tradeState.selectedPlayerName = selected
        local player = Players:FindFirstChild(selected)
        if player then
            tradeState.selectedPlayerId = player.UserId
            NotifySuccess("Target Selected", "Target set to: " .. player.Name, 3)
        else
            tradeState.selectedPlayerId = nil
            NotifyError("Target Error", "Player not found!", 3)
        end
    end
})

Trade:Section({Title = "Auto Accept Trade"})

Trade:Toggle({
    Title = "Enable Auto Accept Trade",
    Desc = "Automatically accepts incoming trade requests.",
    Value = false,
    Callback = function(value)
        _G.AutoAcceptTradeEnabled = value
        if value then
            NotifySuccess("Auto Accept", "Auto accept trade enabled.", 3)
        else
            NotifyWarning("Auto Accept", "Auto accept trade disabled.", 3)
        end
    end
})

Trade:Section({Title = "Mass Trade V1"})

-- Toggle Mode Save Items
local saveModeToggle = Trade:Toggle({
    Title = "Mode Save Items",
    Desc = "Click inventory item to add for Mass Trade",
    Value = false,
    Callback = function(state)
        tradeState.saveTempMode = state
        if state then
            tradeState.TempTradeList = {}
            NotifySuccess("Save Mode", "Enabled - Click items to save")
        else
            NotifyInfo("Save Mode", "Disabled - "..#tradeState.TempTradeList.." items saved")
        end
    end
})

-- Toggle Trade (Original Send)
local originalTradeToggle = Trade:Toggle({
    Title = "Trade (Original Send)",
    Desc = "Click inventory items to Send Trade",
    Value = false,
    Callback = function(state)
        tradeState.onTrade = state
        if state then
            NotifySuccess("Trade", "Trade Mode Enabled. Click an item to send trade.")
        else
            NotifyWarning("Trade", "Trade Mode Disabled.")
        end
    end
})

-- Fungsi Trade All
local function TradeAll()       
    if not tradeState.selectedPlayerId then    
        NotifyError("Mass Trade", "Set trade target first!")       
        return         
    end          
    if #tradeState.TempTradeList == 0 then       
        NotifyWarning("Mass Trade", "No items saved!")          
        return         
    end          
    
    NotifyInfo("Mass Trade", "Starting trade of "..#tradeState.TempTradeList.." items...")      
    
    task.spawn(function()          
        for i, item in ipairs(tradeState.TempTradeList) do          
            if not tradeState.autoTradeV1 then
                NotifyWarning("Mass Trade", "Trade stopped!")         
                break          
            end          
        
            local uuid = item.UUID          
            local category = item.Category          
        
            NotifyInfo("Mass Trade", "Trade item "..i.." of "..#tradeState.TempTradeList)          
            InitiateTrade:InvokeServer(tradeState.selectedPlayerId, uuid, category)          
        
            -- Trade response logic
            task.wait(6.5) -- Delay antar trade         
        end          
    
        NotifySuccess("Mass Trade", "Finished trading!")        
        tradeState.autoTradeV1 = false          
        tradeState.TempTradeList = {}          
    end)          
end

-- Toggle Auto Trade
local autoTradeToggle = Trade:Toggle({
    Title = "Start Mass Trade",
    Desc = "Trade all saved items automatically.",
    Value = false,
    Callback = function(state)
        tradeState.autoTradeV1 = state
        if state then
            if #tradeState.TempTradeList == 0 then
                NotifyError("Mass Trade", "No items saved to trade!")
                tradeState.autoTradeV1 = false
                return
            end
            TradeAll()
            NotifySuccess("Mass Trade", "Auto Trade Enabled")
        else
            NotifyWarning("Mass Trade", "Auto Trade Disabled")
        end
    end
})

-------------------------------------------
----- =======[ ENCHANT STONES ]
-------------------------------------------

-- =======================================================
-- AUTO ENCHANT (GLOBAL VARIABLE VERSION)
-- =======================================================

_G.DStones:Section({
    Title = "Auto Enchant Rod",
    TextSize = 22,
    TextXAlignment = "Center",
})
do
    -- Definisi State Global
    _G.autoEnchantState = { 
        enabled = false, 
        targetEnchant = nil, 
        stoneLimit = math.huge, 
        stonesUsed = 0, 
        selectedRodUUID = nil,
        selectedRodName = "",
        enchantLoopThread = nil 
    }
    
    -- Variabel UI Global (Disiapkan dulu agar tidak nil)
    _G.enchantStatusParagraph = nil
    _G.enchantStoneCountParagraph = nil
    _G.rodDropdown = nil
    _G.autoEnchantToggle = nil
    _G.targetEnchantDropdown = nil
    _G.stoneLimitInput = nil
    
    _G.altarPosition = Vector3.new(3234, -1300, 1401)
    
    -- Helper: Cari Data Rod berdasarkan UUID (Fresh Data)
    _G.getRodByUUID = function(uuid)
        if not (_G.Replion and _G.ItemUtility) then return nil end
        local DataReplion = _G.Replion.Client:GetReplion("Data")
        if not DataReplion then return nil end
    
        local rods = DataReplion:Get({ "Inventory", "Fishing Rods" })
        if rods then
            for _, rod in ipairs(rods) do
                if rod.UUID == uuid then return rod end
            end
        end
        return nil
    end
    
    -- Populate Dropdown Rod
    _G.populateRodDropdown = function()
        task.spawn(function()
            if not (_G.ItemUtility and _G.Replion) then return end
            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Loading rod list...") end
            
            local DataReplion = _G.Replion.Client:WaitReplion("Data")
            if not DataReplion then return end
    
            local rodList, uuidMap = { "Select a rod..." }, {}
            local rod_inventory = DataReplion:Get({ "Inventory", "Fishing Rods" })
            
            if rod_inventory then
                for i, rodItem in ipairs(rod_inventory) do
                    local itemData = _G.ItemUtility:GetItemData(rodItem.Id)
                    if itemData and itemData.Data then
                        local rodName = itemData.Data.Name or rodItem.Id
                        local enchantName = ""
                        
                        -- Cek metadata enchant saat ini
                        if rodItem.Metadata and rodItem.Metadata.EnchantId then
                            local enchantData = _G.ItemUtility:GetEnchantData(rodItem.Metadata.EnchantId)
                            if enchantData and enchantData.Data.Name then
                                enchantName = " [" .. enchantData.Data.Name .. "]"
                            end
                        end
    
                        local displayName = rodName .. enchantName
                        
                        -- Handle nama duplikat agar dropdown unik
                        local count = 2
                        local originalName = displayName
                        while uuidMap[displayName] do
                            displayName = originalName .. " #" .. count
                            count = count + 1
                        end
                        
                        table.insert(rodList, displayName)
                        uuidMap[displayName] = rodItem.UUID
                    end
                end
            end
            
            -- Simpan mapping di dropdown
            if _G.rodDropdown then
                _G.rodDropdown.UUIDMap = uuidMap
                pcall(_G.rodDropdown.Refresh, _G.rodDropdown, rodList)
            end
            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Rods loaded.") end
        end)
    end
    
    -- Get List Enchantment dari ReplicatedStorage
    _G.getEnchantmentList = function()
        local enchants = {}
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local success, enchantsModule = pcall(require, ReplicatedStorage:WaitForChild("Enchants"))
        if success then
            for name, data in pairs(enchantsModule) do
                if type(data) == "table" and data.Data and data.Data.Name then
                    table.insert(enchants, data.Data.Name)
                end
            end
        end
        table.sort(enchants)
        return enchants
    end
    
    -- === UI ELEMENTS ===
    
    _G.targetEnchantDropdown = _G.DStones:Dropdown({
        Title = "Select Target Enchantment",
        Values = _G.getEnchantmentList(),
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(v) _G.autoEnchantState.targetEnchant = v end
    })
    -- myConfig:Register("TargetEnchantQuite", _G.targetEnchantDropdown)
    
    _G.rodDropdown = _G.DStones:Dropdown({
        Title = "Select Rod to Enchant",
        Values = { "Click Refresh or wait..." },
        AllowNone = true,
        Callback = function(v)
            if _G.rodDropdown.UUIDMap and _G.rodDropdown.UUIDMap[v] then
                _G.autoEnchantState.selectedRodUUID = _G.rodDropdown.UUIDMap[v]
                _G.autoEnchantState.selectedRodName = v
                if _G.enchantStatusParagraph then
                    _G.enchantStatusParagraph:SetDesc("Selected: " .. v)
                end
            end
        end
    })
    -- myConfig:Register("SelectedRodToEnchantQuite", _G.rodDropdown)
    
    _G.DStones:Button({ Title = "Refresh Rod List", Icon = "refresh-cw", Callback = _G.populateRodDropdown })
    
    _G.stoneLimitInput = _G.DStones:Input({
        Title = "Max Enchant Stones to Use",
        Placeholder = "Empty for no limit",
        Type = "Input",
        Callback = function(v) _G.autoEnchantState.stoneLimit = tonumber(v) or math.huge end
    })
    -- myConfig:Register("StoneLimitQuite", _G.stoneLimitInput)
    
    _G.enchantStoneCountParagraph = _G.DStones:Paragraph({ Title = "Stones Owned", Desc = "Loading..." })
    _G.enchantStatusParagraph = _G.DStones:Paragraph({ Title = "Status", Desc = "Idle." })
    
    -- Thread Update Stone Count
    task.spawn(function()
        while task.wait(2) do
            -- Pastikan Window aktif (jika variabel Window ada di _G atau scope lain)
            pcall(function()
                if not _G.Replion then return end
                local DataReplion = _G.Replion.Client:GetReplion("Data")
                if not DataReplion then return end
                local items = DataReplion:Get({ "Inventory", "Items" })
                local count = 0
                if items then
                    for _, item in ipairs(items) do
                        local base = _G.ItemUtility:GetItemData(item.Id)
                        if base and base.Data and base.Data.Type == "Enchant Stones" then
                            count = count + (item.Quantity or 1)
                        end
                    end
                end
                if _G.enchantStoneCountParagraph then
                    _G.enchantStoneCountParagraph:SetDesc("You have: " .. count .. " stones")
                end
            end)
        end
    end)
    
    _G.autoEnchantToggle = _G.DStones:Toggle({
        Title = "Enable Auto Enchant",
        Value = false,
        Callback = function(value)
            _G.autoEnchantState.enabled = value
            
            -- Matikan thread lama jika ada
            if _G.autoEnchantState.enchantLoopThread then
                task.cancel(_G.autoEnchantState.enchantLoopThread)
                _G.autoEnchantState.enchantLoopThread = nil
            end
    
            if value then
                _G.autoEnchantState.enchantLoopThread = task.spawn(function()
                    if not _G.autoEnchantState.targetEnchant or not _G.autoEnchantState.selectedRodUUID then
                        if _G.enchantStatusParagraph then 
                            _G.enchantStatusParagraph:SetDesc("Error: Select Rod AND Target Enchant!") 
                        end
                        pcall(function() _G.autoEnchantToggle:SetValue(false) end)
                        return
                    end
    
                    -- 1. Teleport ke Altar
                    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - _G.altarPosition).Magnitude > 10 then
                        if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Teleporting to Altar...") end
                        hrp.CFrame = CFrame.new(_G.altarPosition) * CFrame.new(0, 5, 0)
                        task.wait(1.5)
                    end
    
                    _G.autoEnchantState.stonesUsed = 0
                    local DataReplion = _G.Replion.Client:WaitReplion("Data")
                    local EquipItemEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipItem"]
                    local EquipToolEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]
                    local UnequipItemEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/UnequipItem"]
                    local ActivateAltarEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/ActivateEnchantingAltar"]
                    local RollEnchantEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/RollEnchant"]
    
                    while _G.autoEnchantState.enabled do
                        -- 2. Ambil Data Terbaru Rod
                        local currentRod = _G.getRodByUUID(_G.autoEnchantState.selectedRodUUID)
                        if not currentRod then
                            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Error: Rod not found in inventory!") end
                            break
                        end
    
                        -- 3. Cari Stone
                        local stoneItem = nil
                        local items = DataReplion:Get({ "Inventory", "Items" })
                        for _, item in ipairs(items or {}) do
                            local base = _G.ItemUtility:GetItemData(item.Id)
                            if base and base.Data and base.Data.Type == "Enchant Stones" then
                                stoneItem = item
                                break
                            end
                        end
    
                        if not stoneItem then
                            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Stopped: Out of Enchant Stones.") end
                            break
                        end
    
                        if _G.autoEnchantState.stonesUsed >= _G.autoEnchantState.stoneLimit then
                            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Stopped: Limit reached.") end
                            break
                        end
    
                        _G.autoEnchantState.stonesUsed = _G.autoEnchantState.stonesUsed + 1
                        if _G.enchantStatusParagraph then 
                            _G.enchantStatusParagraph:SetDesc(string.format("Rolling... (Stone #%d)", _G.autoEnchantState.stonesUsed)) 
                        end
    
                        -- 4. Proses Equip & Roll
                        local success, resultEnchantName = pcall(function()
                            -- Equip Rod
                            EquipItemEvent:FireServer(currentRod.UUID, "Fishing Rods")
                            task.wait(0.6)
    
                            -- Equip Stone
                            EquipItemEvent:FireServer(stoneItem.UUID, "Enchant Stones")
                            task.wait(0.6)
    
                            -- Equip Tool
                            EquipToolEvent:FireServer(6) 
                            task.wait(0.8)
    
                            -- Snapshot ID Enchant Lama
                            local oldEnchantId = currentRod.Metadata and currentRod.Metadata.EnchantId or nil
                            local gotResult = false
                            local resultName = "None"
    
                            -- Setup Listener Replion untuk deteksi perubahan
                            local connection
                            connection = DataReplion:OnChange({"Inventory", "Fishing Rods"}, function(newRods)
                                for _, rod in ipairs(newRods) do
                                    if rod.UUID == currentRod.UUID then
                                        local newEnchantId = rod.Metadata and rod.Metadata.EnchantId
                                        -- Jika ID berubah, berarti roll sukses
                                        if newEnchantId ~= oldEnchantId then
                                            if newEnchantId then
                                                local eData = _G.ItemUtility:GetEnchantData(newEnchantId)
                                                resultName = eData and eData.Data.Name or "Unknown"
                                            else
                                                resultName = "None"
                                            end
                                            gotResult = true
                                        end
                                        break
                                    end
                                end
                            end)
    
                            -- Trigger Roll
                            ActivateAltarEvent:FireServer(currentRod.UUID) -- Init
                            task.wait(0.5)
                            RollEnchantEvent:FireServer(currentRod.UUID) -- Confirm Roll
    
                            -- Tunggu hasil (Max 6 detik)
                            local timer = 0
                            while not gotResult and timer < 7 do
                                task.wait(0.7)
                                timer = timer + 0.7
                                if not _G.autoEnchantState.enabled then break end
                            end
    
                            if connection then connection:Disconnect() end
    
                            if not gotResult then
                                error("Timeout waiting for enchant result")
                            end
    
                            return resultName
                        end)
    
                        -- Unequip Tool Safety
                        pcall(function() UnequipItemEvent:FireServer(6) end)
    
                        if success then
                            if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("Rolled: " .. resultEnchantName) end
                            
                            -- Cek apakah sesuai target
                            if string.lower(resultEnchantName) == string.lower(_G.autoEnchantState.targetEnchant) then
                                if _G.enchantStatusParagraph then _G.enchantStatusParagraph:SetDesc("SUCCESS! Got " .. resultEnchantName) end
                                NotifySuccess("Auto Enchant", "Successfully got " .. resultEnchantName, 5)
                                _G.autoEnchantState.enabled = false
                                pcall(function() _G.autoEnchantToggle:SetValue(false) end)
                                _G.populateRodDropdown() -- Refresh nama rod
                                break
                            end
                        else
                            warn("Enchant fail/retry: " .. tostring(resultEnchantName))
                            _G.autoEnchantState.stonesUsed = _G.autoEnchantState.stonesUsed - 1 
                            task.wait(0.5)
                        end
    
                        task.wait(0.5) -- Delay aman antar roll agar tidak crash
                    end
    
                    pcall(function() _G.autoEnchantToggle:SetValue(false) end)
                    _G.autoEnchantState.enchantLoopThread = nil
                end)
            end
        end
    })
    task.delay(1, _G.populateRodDropdown)
end

_G.DStones:Space()

_G.DStones:Section({
    Title = "Double Enchant Rod",
    TextSize = 22,
    TextXAlignment = "Center",
})

_G.DStones:Paragraph({
    Title = "Guide",
    Color = "Green",
    Desc = [[
TUTORIAL FOR DOUBLE ENCHANT

1. "Enabled Double Enchant" first
2. Hold your "SECRET" fish, then click "Get Enchant Stone"
3. Click "Double Enchant Rod" to do Double Enchant, and don't forget to place the stone in slot 5

Good Luck!
]]
})

_G.ReplicatedStorage = game:GetService("ReplicatedStorage")

_G.DStones:Space()

_G.DStones:Button({
    Title = "Enable Double Enchant",
    Locked = false,
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.ActivateDoubleEnchant = _G.ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
        ["RE/ActivateSecondEnchantingAltar"]
        if _G.ActivateDoubleEnchant then
            _G.ActivateDoubleEnchant:FireServer()
            NotifySuccess("Double Enchant", "Double Enchant Enabled for Rods")
        else
            warn("Cant find Double Enchant functions")
        end
    end
})

_G.DStones:Space()

_G.DStones:Button({
    Title = "Get Enchant Stones",
    Locked = false,
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.CreateTranscendedStone = _G.ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
        ["RF/CreateTranscendedStone"]
        if _G.CreateTranscendedStone then
            local result = _G.CreateTranscendedStone:InvokeServer()
            NotifySuccess("Double Enchant", "Got Enchant Stone!")
        else
            warn("[] Tidak dapat menemukan RemoteFunction CreateTranscendedStone.")
        end
    end
})

_G.DStones:Space()

_G.DStones:Button({
    Title = "Double Enchant Rod",
    Desc = "Hold the stone in slot 5",
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.ActiveStone = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
        ["RE/ActivateSecondEnchantingAltar"]
        if _G.ActiveStone then
            local result = _G.ActiveStone:FireServer()
            NotifySuccess("Double Enchant", "Enchanting....")
        else
            warn("Error something")
        end
    end
})


-------------------------------------------
----- =======[ PLAYER TAB ]
-------------------------------------------
-- =========================================================
-- =============== VARIABLES ================================
-- =========================================================

_G.CopyAvatarEnabled = false
_G.OriginalDescription = nil
_G.LastCopiedUserId = nil

-- =========================================================
-- =============== HELPER FUNCTIONS =========================
-- =========================================================

local function SaveOriginal()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        _G.OriginalDescription = hum:GetAppliedDescription()
    end
end

local function ApplyUserIdAvatar(userId)
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local desc = Players:GetHumanoidDescriptionFromUserId(userId)
    hum:ApplyDescriptionClientServer(desc)
end

local function CopyAvatar(username)
    if not _G.CopyAvatarEnabled then return end

    local userId = Players:GetUserIdFromNameAsync(username)
    _G.LastCopiedUserId = userId

    ApplyUserIdAvatar(userId)

    -- 🔥 BROADCAST ke semua user script
    SyncEvent:Fire(LocalPlayer.UserId, userId)
end

local function ResetAvatar()
    if not _G.OriginalDescription then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum:ApplyDescriptionClientServer(_G.OriginalDescription)

    -- Broadcast reset
    SyncEvent:Fire(LocalPlayer.UserId, "RESET")
end

-- =========================================================
-- ============= REAL-TIME RECEIVE SYNC =====================
-- =========================================================

SyncEvent.Event:Connect(function(fromUserId, data)
    if fromUserId == LocalPlayer.UserId then
        return -- jangan apply ke diri sendiri
    end

    if data == "RESET" then
        if _G.CopyAvatarEnabled then
            ResetAvatar()
        end
        return
    end

    -- data = userId avatar target
    if _G.CopyAvatarEnabled then
        ApplyUserIdAvatar(data)
        _G.LastCopiedUserId = data
    end
end)

-- =========================================================
-- ===================== UI SYSTEM ==========================
-- =========================================================

local function ListPlayers()
    local out = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(out, p.DisplayName)
        end
    end
    return out
end

_G.CopyAvatarToggle = Player:Toggle({
    Title = "Avatar Copy Real-Time",
    Desc = "Enable/Disable real-time syncing",
    Value = false,
    Callback = function(state)
        _G.CopyAvatarEnabled = state
        if state then
            if not _G.OriginalDescription then SaveOriginal() end

            -- Jika user lain sudah copy avatar sebelumnya,
            -- langsung sync avatar saat enable
            if _G.LastCopiedUserId then
                ApplyUserIdAvatar(_G.LastCopiedUserId)
            end
        else
            ResetAvatar()
        end
    end
})

_G.CopyAvatarDropdown = Player:Dropdown({
    Title = "Select Player Avatar",
    Desc = "Copy avatar (real-time)",
    Values = ListPlayers(),
    SearchBarEnabled = true,
    Callback = function(displayName)
        if not _G.CopyAvatarEnabled then return end

        for _,plr in ipairs(Players:GetPlayers()) do
            if plr.DisplayName == displayName then
                CopyAvatar(plr.Name)
            end
        end
    end
})

Player:Button({
    Title = "Reset Avatar",
    Desc = "Kembali ke avatar asli",
    Callback = function()
        ResetAvatar()
    end
})

-- =========================================================
-- ==================== EVENT HANDLERS =====================
-- =========================================================

-- Auto refresh dropdown
Players.PlayerAdded:Connect(function()
    task.wait(1)
    refreshDropdown()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(1)
    refreshDropdown()
end)

-- Auto reapply on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    
    if _G.CopyAvatarEnabled and _G.CopyAvatarTarget then
        task.spawn(function()
            task.wait(0.5)
            safeCopyAvatar(_G.CopyAvatarTarget.Name)
        end)
    end
end)

-- Initial setup
task.spawn(function()
    task.wait(3)
    refreshDropdown()
    saveOriginalAppearance()
end)

Player:Space()

local currentDropdown = nil

local function getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.DisplayName)
        end
    end
    return list
end


local function teleportToPlayerExact(target)
    local characters = workspace:FindFirstChild("Characters")
    if not characters then return end

    local targetChar = characters:FindFirstChild(target)
    local myChar = characters:FindFirstChild(LocalPlayer.Name)

    if targetChar and myChar then
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if targetHRP and myHRP then
            myHRP.CFrame = targetHRP.CFrame + Vector3.new(2, 0, 0)
        end
    end
end

local function refreshDropdown()
    if currentDropdown then
        currentDropdown:Refresh(getPlayerList())
    end
end

currentDropdown = Player:Dropdown({
    Title = "Teleport to Player",
    Desc = "Select player to teleport",
    Values = getPlayerList(),
    SearchBarEnabled = true,
    Callback = function(selectedDisplayName)
        for _, p in pairs(Players:GetPlayers()) do
            if p.DisplayName == selectedDisplayName then
                teleportToPlayerExact(p.Name)
                NotifySuccess("Teleport Successfully", "Successfully Teleported to " .. p.DisplayName .. "!", 3)
                break
            end
        end
    end
})

Players.PlayerAdded:Connect(function()
    task.delay(0.1, refreshDropdown)
end)

Players.PlayerRemoving:Connect(function()
    task.delay(0.1, refreshDropdown)
end)

refreshDropdown()


local defaultMinZoom = LocalPlayer.CameraMinZoomDistance
local defaultMaxZoom = LocalPlayer.CameraMaxZoomDistance

Player:Toggle({
    Title = "Unlimited Zoom",
    Desc = "Unlimited Camera Zoom for take a Picture",
    Value = false,
    Callback = function(state)
        if state then
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 9999
        else
            LocalPlayer.CameraMinZoomDistance = defaultMinZoom
            LocalPlayer.CameraMaxZoomDistance = defaultMaxZoom
        end
    end
})

-- ============================================
-- ============= LOCK POSITION API ============
-- ============================================

_G.LockPosition = _G.LockPosition or {}
local API = _G.LockPosition

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

API.Enabled = false
API.LockCFrame = nil
API.LockConn = nil
API.RespawnConn = nil


-- Paksa posisi HRP ke LockCFrame
local function ForceLock(humrp)
    if humrp and API.LockCFrame then
        humrp.CFrame = API.LockCFrame
    end
end


-- Loop heartbeat untuk menjaga posisi
local function StartLoop(humrp)
    if API.LockConn then API.LockConn:Disconnect() end

    API.LockConn = RunService.Heartbeat:Connect(function()
        if not API.Enabled then return end
        if not humrp or not humrp.Parent then return end

        local curr = humrp.CFrame
        local target = API.LockCFrame

        if (curr.Position - target.Position).Magnitude > 0.1 then
            humrp.CFrame = target
        end
    end)
end


-- Saat respawn, ambil HRP baru & paksa lock ulang
local function OnCharacterAdded(char)
    if not API.Enabled then return end

    task.defer(function()
        local humrp = char:WaitForChild("HumanoidRootPart", 10)
        if not humrp then return end

        ForceLock(humrp)
        StartLoop(humrp)
    end)
end


-- PUBLIC: Toggle lock
API.Toggle = function(state)
    API.Enabled = state

    if state then
        -- Ambil karakter & HRP awal
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humrp = char:WaitForChild("HumanoidRootPart", 10)
        if not humrp then return end

        -- Simpan posisi awal
        API.LockCFrame = humrp.CFrame

        -- Start loop utama
        StartLoop(humrp)

        -- Listen respawn
        if API.RespawnConn then API.RespawnConn:Disconnect() end
        API.RespawnConn = LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

    else
        -- Disable semua
        if API.LockConn then API.LockConn:Disconnect() API.LockConn = nil end
        if API.RespawnConn then API.RespawnConn:Disconnect() API.RespawnConn = nil end

        API.LockCFrame = nil
    end
end

local ToggleLockPositionUI = Player:Toggle({
    Title = "Enable Lock Position",
    Desc = "Lock Position Your Char",
    Value = false,
    Callback = function(enabled)
        _G.LockPosition.Toggle(enabled)
    end,
})

Player:Space()

local function accessAllBoats()
    local vehicles = workspace:FindFirstChild("Vehicles")
    if not vehicles then
        NotifyError("Not Found", "Vehicles container not found.")
        return
    end

    local count = 0

    for _, boat in ipairs(vehicles:GetChildren()) do
        if boat:IsA("Model") and boat:GetAttribute("OwnerId") then
            local currentOwner = boat:GetAttribute("OwnerId")
            if currentOwner ~= LocalPlayer.UserId then
                boat:SetAttribute("OwnerId", LocalPlayer.UserId)
                count += 1
            end
        end
    end

    NotifySuccess("Access Granted", "You now own " .. count .. " boat(s).", 3)
end

Player:Space()

Player:Button({
    Title = "Access All Boats",
    Justify = "Center",
    Icon = "",
    Callback = accessAllBoats
})

Player:Space()

Player:Toggle({
    Title = "Infinity Jump",
    Callback = function(val)
        ijump = val
    end,
})

-- ============================================
-- GLOBAL RAINBOW LOCK
-- ============================================
local rainbowRunning = false
local rainbowThread = nil
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- APPLY WARNA KE SEMUA PART
local function ApplyRainbowColor(character, hsv)
    if not character then return end

    for _, v in pairs(character:GetDescendants()) do
        -- Semua part fisik
        if v:IsA("BasePart") then
            v.Color = hsv
            v.Material = Enum.Material.Neon

        -- Accessories (topi, rambut, baju 3D)
        elseif v:IsA("Accessory") then
            local handle = v:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                handle.Color = hsv
                handle.Material = Enum.Material.Neon
            end

        -- Clothing lama (Shirt, Pants, Graphic)
        elseif v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
            v:Destroy() -- hapus supaya warna lock ke body

        -- MeshPart / SpecialMesh
        elseif v:IsA("MeshPart") then
            v.Color = hsv
            v.Material = Enum.Material.Neon

        elseif v:IsA("SpecialMesh") then
            local parent = v.Parent
            if parent and parent:IsA("BasePart") then
                parent.Color = hsv
                parent.Material = Enum.Material.Neon
            end
        end
    end
end

-- LOOP RAINBOW
local function StartRainbowLoop()
    rainbowRunning = true

    rainbowThread = task.spawn(function()
        while rainbowRunning do
            local character = LocalPlayer.Character
            if character then
                for i = 1, 100 do
                    if not rainbowRunning then return end
                    local hsv = Color3.fromHSV(i / 100, 1, 1)
                    ApplyRainbowColor(character, hsv)
                    task.wait(0.12)
                end
            end
            task.wait()
        end
    end)
end

-- STOP
local function StopRainbow()
    rainbowRunning = false
    if rainbowThread then
        task.cancel(rainbowThread)
        rainbowThread = nil
    end
end

-- RESPWAN HANDLER
LocalPlayer.CharacterAdded:Connect(function(char)
    if rainbowRunning then
        task.wait(0.3)
        StartRainbowLoop()
    end
end)

-- ============================================
-- TOGGLE UI (FORMAT SESUAI PERMINTAAN)
-- ============================================
function ToggleRainbowCharacter(enabled)
    if enabled then
        StartRainbowLoop()
    else
        StopRainbow()
    end
end

local ToggleRainbow = Player:Toggle({
    Title = "Rainbow Character",
    Value = false,
    Callback = function(enabled)
        ToggleRainbowCharacter(enabled)
    end,
})

myConfig:Register("RainbowConfig", ToggleRainbow)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if ijump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

local EnableFloat = Player:Toggle({
    Title = "Enable Float",
    Value = false,
    Callback = function(enabled)
        floatingPlat(enabled)
    end,
})

myConfig:Register("ActiveFloat", EnableFloat)

local universalNoclip = false
local originalCollisionState = {}

local NoClip = Player:Toggle({
    Title = "Universal No Clip",
    Value = false,
    Callback = function(val)
        universalNoclip = val

        if val then
            NotifySuccess("Universal Noclip Active", "You & your vehicle can penetrate all objects.", 3)
        else
            for part, state in pairs(originalCollisionState) do
                if part and part:IsA("BasePart") then
                    part.CanCollide = state
                end
            end
            originalCollisionState = {}
            NotifyWarning("Universal Noclip Disabled", "All collisions are returned to their original state.", 3)
        end
    end,
})

game:GetService("RunService").Stepped:Connect(function()
    if not universalNoclip then return end

    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                originalCollisionState[part] = true
                part.CanCollide = false
            end
        end
    end

    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChildWhichIsA("VehicleSeat", true) then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    originalCollisionState[part] = true
                    part.CanCollide = false
                end
            end
        end
    end
end)

myConfig:Register("NoClip", NoClip)

local AntiDrown_Enabled = false
local rawmt = getrawmetatable(game)
setreadonly(rawmt, false)
local oldNamecall = rawmt.__namecall

rawmt.__namecall = newcclosure(function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()

    if tostring(self) == "URE/UpdateOxygen" and method == "FireServer" and AntiDrown_Enabled then
        return nil
    end

    return oldNamecall(self, ...)
end)

local DrownBN = true

-- ===== ENABLE RADAR =====
local function ToggleRadar(state)
    pcall(function()
        Radar:InvokeServer(state)
    end)
end

-- ===== ENABLE DIVING GEAR =====
local function ToggleDivingGear(state)
    pcall(function()
        if state then
            EquipOxy:InvokeServer(105)
        else
            UnequipOxy:InvokeServer()
        end
    end)
end

local ToggleRadar = Player:Toggle({
    Title = "Enable Fishing Radar",
    Value = false,
    Callback = function(enabled)
        ToggleRadar(enabled)
    end,
})

myConfig:Register("RadarConfig", ToggleRadarUI)

local ToggleDivingGear = Player:Toggle({
    Title = "Enable Diving Gear",
    Value = false,
    Callback = function(enabled)
        ToggleDivingGear(enabled)
    end,
})

myConfig:Register("AntiDrown", ToggleDivingGearUI)

local Speed = Player:Slider({
    Title = "WalkSpeed",
    Value = {
        Min = 16,
        Max = 200,
        Default = 20
    },
    Step = 1,
    Callback = function(val)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end,
})

myConfig:Register("PlayerSpeed", Speed)

local Jp = Player:Slider({
    Title = "Jump Power",
    Value = {
        Min = 50,
        Max = 500,
        Default = 35
    },
    Step = 10,
    Callback = function(val)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = val
            end
        end
    end,
})

myConfig:Register("JumpPower", Jp)

-------------------------------------------
----- =======[ UTILITY TAB ]
-------------------------------------------


_G.RFRedeemCode = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RedeemCode"]

_G.RedeemCodes = {
    "BLAMETALON",
    "FISHMAS2025",
    "GOLDENSHARK",
    "THANKYOU",
    "PURPLEMOON"
}

_G.RedeemAllCodes = function()
    for _, code in ipairs(_G.RedeemCodes) do
        local success, result = pcall(function()
            return _G.RFRedeemCode:InvokeServer(code)
        end)
        task.wait(1)
    end
end

Utils:Button({
    Title = "Redeem All Codes",
    Locked = false,
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.RedeemAllCodes()
    end
})

Utils:Space()

_G.ItemUtilityModule = require(ReplicatedStorage.Shared.ItemUtility)
_G.ClientReplionModule = require(ReplicatedStorage.Packages._Index["ytrev_replion@2.0.0-rc.3"].replion.Client.ClientReplion)

-- Menyimpan Remote Event
_G.RESpawnTotem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/SpawnTotem"]

-- Variabel Global untuk data & status
 -- Akan diisi saat inisialisasi
_G.TotemInventoryCache = {} -- Cache untuk menyimpan UUID {["Luck Totem"] = {UUIDs = {"uuid1", ...}}}
_G.TotemsList = {}
_G.AutoTotemState = {
    IsRunning = false,
    DelayMinutes = 10,
    SelectedTotemName = {},
    LoopThread = nil,
}


function _G.RefreshTotemInventory()
    if not _G.DataReplion then return end

    -- Reset Cache dengan benar
    _G.TotemInventoryCache = {}
    _G.TotemsList = {}

    -- Ambil item dari Replion
    local items = _G.DataReplion:Get({ "Inventory", "Totems" })

    if not items then
        if _G.TotemDropdown then _G.TotemDropdown:Refresh({}) end
        if _G.TotemStatusParagraph then
            _G.TotemStatusParagraph:SetDesc("Inventory refreshed. Found 0 types of totems.")
        end
        return
    end

    -- Loop isi cache
    for _, item in ipairs(items) do
        local totemData = _G.ItemUtilityModule:GetTotemsData(item.Id)

        if totemData and totemData.Data then
            local name = totemData.Data.Name

            -- Jika belum ada, buat array
            if not _G.TotemInventoryCache[name] then
                _G.TotemInventoryCache[name] = {}
            end

            -- Masukkan UUID
            table.insert(_G.TotemInventoryCache[name], item.UUID)
        end
    end

    -- Bangun dropdown list
    for name, list in pairs(_G.TotemInventoryCache) do
        local count = #list  -- FIX: tidak lagi memakai list.UUIDs
        table.insert(_G.TotemsList, string.format("%s (x%d)", name, count))
    end

    table.sort(_G.TotemsList)

    -- Update dropdown
    if _G.TotemDropdown then
        _G.TotemDropdown:Refresh(_G.TotemsList)
    end

    -- Update status
    if _G.TotemStatusParagraph then
        _G.TotemStatusParagraph:SetDesc(
            string.format("Inventory refreshed. Found %d types of totems.", #_G.TotemsList)
        )
    end
end



-- Fungsi untuk menghentikan loop
function _G.StopAutoTotem()
    _G.AutoTotemState.IsRunning = false
    if _G.AutoTotemState.LoopThread then
        task.cancel(_G.AutoTotemState.LoopThread)
        _G.AutoTotemState.LoopThread = nil
    end
    if _G.TotemStatusParagraph then
        _G.TotemStatusParagraph:SetDesc("Auto Totem Stopped.")
    end
    NotifyWarning("Auto Totem", "Stopped.")
end

function _G.StartAutoTotem()
    _G.AutoTotemState.IsRunning = true

    _G.AutoTotemState.LoopThread = task.spawn(function()
        while _G.AutoTotemState.IsRunning do

            -- ============================
            -- 1. Validasi pilihan totem
            -- ============================
            local rawName = _G.AutoTotemState.SelectedTotemName
            if not rawName or rawName == "" then
                NotifyError("Auto Totem", "No totem selected from dropdown.")
                return _G.StopAutoTotem()
            end

            -- Clean name dari "(x5)" → "Luck Totem"
            local cleanName = rawName:match("^(.-) %(")
            cleanName = cleanName or rawName -- fallback seluruh name

            -- ============================
            -- 2. Ambil data totem
            -- ============================
            local totemList = _G.TotemInventoryCache[cleanName]

            if not totemList or #totemList == 0 then
                NotifyError("Auto Totem", "No more '" .. cleanName .. "' left in inventory.")
                _G.RefreshTotemInventory()
                return _G.StopAutoTotem()
            end

            -- ============================
            -- 3. Ambil UUID & FireServer
            -- ============================
            local uuid = table.remove(totemList, 1)
            if uuid then
                _G.RESpawnTotem:FireServer(uuid)
                NotifySuccess("Auto Totem", "Spawned 1x " .. cleanName)
            end

            -- ============================
            -- 4. Refresh UI
            -- ============================
            _G.RefreshTotemInventory()

            -- ============================
            -- 5. Delay (with countdown)
            -- ============================
            local delaySeconds = _G.AutoTotemState.DelayMinutes * 60
            local waited = 0
            
            while waited < delaySeconds and _G.AutoTotemState.IsRunning do
                local remaining = delaySeconds - waited
                
                local minutes = math.floor(remaining / 60)
                local seconds = remaining % 60
            
                _G.TotemStatusParagraph:SetDesc(
                    string.format("Spawned %s. Waiting %02d:%02d...", cleanName, minutes, seconds)
                )
                
                local step = math.min(5, remaining)
                task.wait(step)
                waited += step
            end
        end
    end)
end

-- =======================================================
-- 3. UI (DROPDOWN, INPUT, TOGGLE)
-- =======================================================

_G.TotemStatusParagraph = Utils:Paragraph({
    Title = "Auto Totem Status",
    Desc = "Waiting for data..."
})

_G.TotemDropdown = Utils:Dropdown({
    Title = "Select Totem",
    Values = {"Loading inventory..."},
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(val)
        if not val then
            _G.AutoTotemState.SelectedTotemName = nil
            return
        end

        local clean = val:match("^(.-) %(") or val
        _G.AutoTotemState.SelectedTotemName = clean
    end
})

_G.TotemDelayInput = Utils:Input({
    Title = "Delay (Minutes)",
    Placeholder = "Enter minutes...",
    Default = 10,
    Type = "Input",
    Callback = function(val)
        _G.AutoTotemState.DelayMinutes = tonumber(val) or 10
    end
})

Utils:Button({ Title = "Refresh Totems", Icon = "refresh-cw", Callback = _G.RefreshTotemInventory })

Utils:Toggle({
    Title = "Enable Auto Totem",
    Value = false,
    Callback = function(state)
        if state then
            _G.StartAutoTotem()
        else
            _G.StopAutoTotem()
        end
    end
})

task.spawn(function()
    while not _G.Replion do 
        _G.TotemStatusParagraph:SetDesc("Waiting for _G.Replion...")
        task.wait(2) 
    end
    
    _G.DataReplion = _G.Replion.Client:WaitReplion("Data")
    if not _G.DataReplion then
        _G.TotemStatusParagraph:SetDesc("Error: Failed to connect to Server Data.")
        return
    end

    -- Panggil fungsi (yang sudah diperbaiki) untuk pertama kali
    _G.RefreshTotemInventory()
    
end)

Utils:Space()


local weatherActive = {}
local weatherData = {
    ["Storm"] = { duration = 900 },
    ["Cloudy"] = { duration = 900 },
    ["Snow"] = { duration = 900 },
    ["Wind"] = { duration = 900 },
    ["Radiant"] = { duration = 900 }
}

local function randomDelay(min, max)
    return math.random(min * 100, max * 100) / 100
end

local function autoBuyWeather(weatherType)
    local purchaseRemote = ReplicatedStorage:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")
        :WaitForChild("RF/PurchaseWeatherEvent")

    task.spawn(function()
        while weatherActive[weatherType] do
            pcall(function()
                purchaseRemote:InvokeServer(weatherType)
                NotifySuccess("Weather Purchased", "Successfully activated " .. weatherType)

                task.wait(weatherData[weatherType].duration)

                local randomWait = randomDelay(1, 5)
                NotifyInfo("Waiting...", "Delay before next purchase: " .. tostring(randomWait) .. "s")
                task.wait(randomWait)
            end)
        end
    end)
end

local WeatherDropdown = Utils:Dropdown({
    Title = "Auto Buy Weather",
    Values = { "Storm", "Cloudy", "Snow", "Wind", "Radiant" },
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
        for weatherType, active in pairs(weatherActive) do
            if active and not table.find(selected, weatherType) then
                weatherActive[weatherType] = false
                NotifyWarning("Auto Weather", "Auto buying " .. weatherType .. " has been stopped.")
            end
        end
        for _, weatherType in pairs(selected) do
            if not weatherActive[weatherType] then
                weatherActive[weatherType] = true
                NotifyInfo("Auto Weather", "Auto buying " .. weatherType .. " has started!")
                autoBuyWeather(weatherType)
            end
        end
    end
})

myConfig:Register("WeatherDropdown", WeatherDropdown)

Utils:Space()

local islandCoords = {
    ["01"] = { name = "Weather Machine", position = Vector3.new(-1471, -3, 1929) },
    ["02"] = { name = "Esoteric Depths", position = Vector3.new(3157, -1303, 1439) },
    ["03"] = { name = "Tropical Grove", position = Vector3.new(-2038, 3, 3650) },
    ["04"] = { name = "Stingray Shores", position = Vector3.new(-32, 4, 2773) },
    ["05"] = { name = "Kohana Volcano", position = Vector3.new(-519, 24, 189) },
    ["06"] = { name = "Coral Reefs", position = Vector3.new(-3095, 1, 2177) },
    ["07"] = { name = "Crater Island", position = Vector3.new(968, 1, 4854) },
    ["08"] = { name = "Kohana", position = Vector3.new(-658, 3, 719) },
    ["09"] = { name = "Winter Fest", position = Vector3.new(1611, 4, 3280) },
    ["10"] = { name = "Isoteric Island", position = Vector3.new(1987, 4, 1400) },
    ["11"] = { name = "Treasure Hall", position = Vector3.new(-3600, -267, -1558) },
    ["12"] = { name = "Lost Shore", position = Vector3.new(-3663, 38, -989) },
    ["13"] = { name = "Sishypus Statue", position = Vector3.new(-3792, -135, -986) },
    ["14"] = { name = "Ancient Jungle", position = Vector3.new(1478, 131, -613) },
    ["15"] = { name = "The Temple", position = Vector3.new(1477, -22, -631) },
    ["16"] = { name = "Underground Cellar", position = Vector3.new(2133, -91, -674) },
    ["17"] = {name = "Ancient Ruin", position = Vector3.new(6052, -546, 4427) },
    ["18"] = {name = "Iron Cavern", position = Vector3.new(-8873, -582, 157) },
    ["19"] = {name = "Iron Cafe", position = Vector3.new(-8668, -549, 161) },
    ["20"] = {name = "Classic Island", position = Vector3.new(1259, 10, 2824) }
}

local islandNames = {}
for _, data in pairs(islandCoords) do
    table.insert(islandNames, data.name)
end

Utils:Dropdown({
    Title = "Island Selector",
    Desc = "Select island to teleport",
    Values = islandNames,
    Value = islandNames[1],
    SearchBarEnabled = true,
    Callback = function(selectedName)
        for code, data in pairs(islandCoords) do
            if data.name == selectedName then
                local success, err = pcall(function()
                    local charFolder = workspace:WaitForChild("Characters", 5)
                    local char = charFolder:FindFirstChild(LocalPlayer.Name)
                    if not char then error("Character not found") end
                    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
                    if not hrp then error("HumanoidRootPart not found") end
                    hrp.CFrame = CFrame.new(data.position + Vector3.new(0, 5, 0))
                end)

                if success then
                    NotifySuccess("Teleported!", "You are now at " .. selectedName)
                else
                    NotifyError("Teleport Failed", tostring(err))
                end
                break
            end
        end
    end
})

local eventsList = {
    "Shark Hunt",
    "Ghost Shark Hunt",
    "Worm Hunt",
    "Black Hole",
    "Shocked",
    "Ghost Worm",
    "Meteor Rain",
    "Megalodon Hunt"
}

Utils:Dropdown({
    Title = "Teleport Event",
    Values = eventsList,
    Value = "Shark Hunt",
    Callback = function(option)
        local props = workspace:FindFirstChild("Props")
        if props and props:FindFirstChild(option) then
            local targetModel
            if option == "Worm Hunt" or option == "Ghost Worm" then
                targetModel = props:FindFirstChild("Model")
            else
                targetModel = props[option]
            end

            if targetModel then
                local pivot = targetModel:GetPivot()
                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = pivot + Vector3.new(0, 15, 0)
                    WindUI:Notify({
                        Title = "Event Available!",
                        Content = "Teleported To " .. option,
                        Icon = "circle-check",
                        Duration = 3
                    })
                end
            else
                WindUI:Notify({
                    Title = "Event Not Found",
                    Content = option .. " Not Found!",
                    Icon = "ban",
                    Duration = 3
                })
            end
        else
            WindUI:Notify({
                Title = "Event Not Found",
                Content = option .. " Not Found!",
                Icon = "ban",
                Duration = 3
            })
        end
    end
})

local TweenService = game:GetService("TweenService")

local HRP = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local Items = ReplicatedStorage:WaitForChild("Items")
local Baits = ReplicatedStorage:WaitForChild("Baits")
local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")


local npcCFrame = CFrame.new(
    66.866745, 4.62500143, 2858.98535,
    -0.981261611, 5.77215005e-08, -0.192680314,
    6.94250204e-08, 1, -5.39889484e-08,
    0.192680314, -6.63541186e-08, -0.981261611
)


local function FadeScreen(duration)
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.1

    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.2), { BackgroundTransparency = 0.1 })
    tweenIn:Play()
    tweenIn.Completed:Wait()

    wait(duration)

    local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 0.1 })
    tweenOut:Play()
    tweenOut.Completed:Wait()
    gui:Destroy()
end

local function SafePurchase(callback)
    local originalCFrame = HRP.CFrame
    HRP.CFrame = npcCFrame
    FadeScreen(0.2)
    pcall(callback)
    wait(0.1)
    HRP.CFrame = originalCFrame
end

local rodOptions = {}
local rodData = {}

for _, rod in ipairs(Items:GetChildren()) do
    if rod:IsA("ModuleScript") and rod.Name:find("!!!") then
        local success, module = pcall(require, rod)
        if success and module and module.Data then
            local id = module.Data.Id
            local name = module.Data.Name or rod.Name
            local price = module.Price or module.Data.Price

            if price then
                table.insert(rodOptions, name .. " | Price: " .. tostring(price))
                rodData[name] = id
            end
        end
    end
end

Utils:Dropdown({
    Title = "Rod Shop",
    Desc = "Select Rod to Buy",
    Values = rodOptions,
    Value = nil,
    SearchBarEnabled = true,
    Callback = function(option)
        local selectedName = option:split(" |")[1]
        local id = rodData[selectedName]

        SafePurchase(function()
            net:WaitForChild("RF/PurchaseFishingRod"):InvokeServer(id)
            NotifySuccess("Rod Purchased", selectedName .. " has been successfully purchased!")
        end)
    end,
})


local baitOptions = {}
local baitData = {}

for _, bait in ipairs(Baits:GetChildren()) do
    if bait:IsA("ModuleScript") then
        local success, module = pcall(require, bait)
        if success and module and module.Data then
            local id = module.Data.Id
            local name = module.Data.Name or bait.Name
            local price = module.Price or module.Data.Price

            if price then
                table.insert(baitOptions, name .. " | Price: " .. tostring(price))
                baitData[name] = id
            end
        end
    end
end

Utils:Dropdown({
    Title = "Baits Shop",
    Desc = "Select Baits to Buy",
    Values = baitOptions,
    Value = nil,
    SearchBarEnabled = true,
    Callback = function(option)
        local selectedName = option:split(" |")[1]
        local id = baitData[selectedName]

        SafePurchase(function()
            net:WaitForChild("RF/PurchaseBait"):InvokeServer(id)
            NotifySuccess("Bait Purchased", selectedName .. " has been successfully purchased!")
        end)
    end,
})

local npcFolder = game:GetService("ReplicatedStorage"):WaitForChild("NPC")

local npcList = {}
for _, npc in pairs(npcFolder:GetChildren()) do
    if npc:IsA("Model") then
        local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
        if hrp then
            table.insert(npcList, npc.Name)
        end
    end
end


Utils:Dropdown({
    Title = "NPC",
    Desc = "Select NPC to Teleport",
    Values = npcList,
    Value = nil,
    SearchBarEnabled = true,
    Callback = function(selectedName)
        local npc = npcFolder:FindFirstChild(selectedName)
        if npc and npc:IsA("Model") then
            local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
            if hrp then
                local charFolder = workspace:FindFirstChild("Characters", 5)
                local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
                if not char then return end
                local myHRP = char:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    myHRP.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                    NotifySuccess("Teleported!", "You are now near: " .. selectedName)
                end
            end
        end
    end
})

-------------------------------------------
----- =======[ SETTINGS TAB ]
-------------------------------------------
-- ============================================================
-- ==  OVERHEAD HANDLER (FINAL VERSION)
-- ============================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.Header = nil
_G.LevelLabel = nil
_G.XPLevel = nil

_G.LastSetName = nil
_G.LastSetLevel = nil

_G.EnableRandomColor = false
_G.EnableRandomNKZName = false


-- ============================================================
-- ==  SAFE GETTER (PASTI DAPAT HEADER + LEVEL)
-- ============================================================

function _G.getHeader()
    local CharacterFolder = workspace:WaitForChild("Characters")
    local Character = CharacterFolder:FindFirstChild(LocalPlayer.Name)
    if not Character then return nil end

    local HRP = Character:FindFirstChild("HumanoidRootPart")
        or Character:WaitForChild("HumanoidRootPart")
    if not HRP then return nil end

    local Overhead = HRP:FindFirstChild("Overhead")
        or HRP:WaitForChild("Overhead")
    if not Overhead then return nil end

    -- NAME ADA DI Content
    local Content = Overhead:FindFirstChild("Content")
    if Content then
        _G.Header = Content:FindFirstChild("Header")
    end

    -- LEVEL ADA DI DALAM LevelContainer (FRAME)
    local LevelContainer = Overhead:FindFirstChild("LevelContainer")
    if LevelContainer then
        _G.LevelLabel = LevelContainer:FindFirstChildWhichIsA("TextLabel")
    end

    -- XP / TITLE ADA DI DALAM TitleContainer
    local TitleContainer = Overhead:FindFirstChild("TitleContainer")
    if TitleContainer then
        _G.XPLevel = TitleContainer:FindFirstChildWhichIsA("TextLabel")
    end

    return _G.Header
end



-- ============================================================
-- ==  FIX RESPAWN (REATTACH LEVEL + NAMA)
-- ============================================================

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.4)

    -- scan cepat sampai ketemu
    for i = 1, 50 do
        _G.getHeader()
        if _G.Header and (_G.LevelLabel or _G.XPLevel) then
            break
        end
        task.wait(0.02)
    end

    -- reapply nama
    if _G.LastSetName and _G.Header then
        _G.Header.Text = _G.LastSetName
    end

    -- reapply level
    if _G.LastSetLevel then
        if _G.LevelLabel then
            _G.LevelLabel.Text = "Lvl: " .. _G.LastSetLevel
        end
        if _G.XPLevel then
            _G.XPLevel.Text = "Lvl " .. _G.LastSetLevel
        end
    end
end)

-- =====================================================================
-- ==  SMOOTH FAST TRANSITION "NKZ SCRIPT"
-- == PATTERN: BACK → FRONT → BACK (LOOP)
-- =====================================================================

local chars = {"N","K","Z","X","V","Q","Y","A","R","T","P","S","L","C","I"}
local TARGET = "NKZ SCRIPT"
local resetDelay = 0.6

local direction = "back"  -- start dari belakang

local function randChar()
    return chars[math.random(#chars)]
end

local function makeResetBase()
    local out = ""
    for i = 1, #TARGET do
        local g = string.sub(TARGET, i, i)
        if g == " " then
            out = out .. " "
        else
            out = out .. randChar()
        end
    end
    return out
end

spawn(function()
    while task.wait(0.04) do  -- speed glitch cepat
        if not _G.EnableRandomNKZName then continue end
        
        _G.getHeader()
        if not _G.Header then continue end

        local current = _G.Header.Text or ""

        -- reset awal jika kosong
        if current == "" or #current ~= #TARGET then
            _G.Header.Text = makeResetBase()
            continue
        end

        -- jika sudah selesai → tunggu → ganti arah → reset
        if current == TARGET then
            task.wait(resetDelay)
            direction = (direction == "back") and "front" or "back"
            _G.Header.Text = makeResetBase()
            continue
        end

        local newText = ""

        if direction == "back" then
            -----------------------------------------------------
            -- === FIX HURUF DARI BELAKANG → DEPAN
            -----------------------------------------------------
            local fixStarted = false
            
            for i = #TARGET, 1, -1 do
                local cur = string.sub(current, i, i)
                local goal = string.sub(TARGET, i, i)

                if goal == " " then
                    newText = goal .. newText
                elseif cur == goal or fixStarted then
                    newText = cur .. newText
                else
                    newText = randChar() .. newText
                    fixStarted = true
                end
            end

        else
            -----------------------------------------------------
            -- === FIX HURUF DARI DEPAN → BELAKANG
            -----------------------------------------------------
            local fixStarted = false

            for i = 1, #TARGET do
                local cur = string.sub(current, i, i)
                local goal = string.sub(TARGET, i, i)

                if goal == " " then
                    newText = newText .. " "
                elseif cur == goal or fixStarted then
                    newText = newText .. cur
                else
                    newText = newText .. randChar()
                    fixStarted = true
                end
            end
        end

        _G.Header.Text = newText
        _G.LastSetName = newText
    end
end)

-- ============================================================
-- ==  RANDOM COLOR (SUPER SMOOTH)
-- ============================================================

spawn(function()
    while task.wait() do
        if _G.EnableRandomColor then
            _G.getHeader()
            if _G.Header then
                local h = (tick() * 0.4) % 1
                _G.Header.TextColor3 = Color3.fromHSV(h, 1, 1)
            end
        end
    end
end)



-- ============================================================
-- ==  UI SETTINGS
-- ============================================================

_G.AccConfig = SettingsTab:Section({
    Title = "Account Configuration",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

_G.AccConfig:Colorpicker({
    Title = "Color Name",
    Default = Color3.fromRGB(255,255,255),
    Callback = function(color)
        _G.getHeader()
        if _G.Header then
            _G.Header.TextColor3 = color
            _G.EnableRandomColor = false
        end
    end
})

_G.AccConfig:Input({
    Title = "Display Name",
    Placeholder = "Display Name...",
    Callback = function(input)
        if typeof(input) == "string" and input ~= "" then
            _G.getHeader()
            if _G.Header then
                _G.Header.Text = input
                _G.LastSetName = input
                _G.EnableRandomNKZName = false
            end
        end
    end
})


-- ============================================================
-- == INPUT LEVEL (SEKARANG BISA SELALU)
-- ============================================================

_G.AccConfig:Input({
    Title = "Level",
    Placeholder = "Level...",
    Callback = function(input)
        local num = tonumber(input)
        if not num then return end

        _G.LastSetLevel = num

        _G.getHeader()

        if _G.LevelLabel then
            _G.LevelLabel.Text = "Lvl: " .. num
        end

        if _G.XPLevel then
            _G.XPLevel.Text = "Lvl " .. num
        end
    end
})

_G.AccConfig:Toggle({
    Title = "Hide Identity",
    Value = false,
    Callback = function(state)
        _G.getHeader()
        if _G.Header then _G.Header.Visible = not state end
        if _G.LevelLabel then _G.LevelLabel.Visible = not state end
        if _G.XPLevel then _G.XPLevel.Visible = not state end
    end
})

_G.AccConfig:Toggle({
    Title = "Random NKZ Name",
    Value = false,
    Callback = function(v)
        _G.EnableRandomNKZName = v
    end
})

_G.AccConfig:Toggle({
    Title = "Random Color",
    Value = false,
    Callback = function(v)
        _G.EnableRandomColor = v
    end
})

_G.AccConfig:Space()

function _G.Disable3DRendering(enabled)
	if enabled then
		RunService:Set3dRenderingEnabled(false)
	else
		RunService:Set3dRenderingEnabled(true)
	end
end

SettingsTab:Toggle({
    Title = "Disable 3D Rendering",
    Value = false,
    Callback = function(state)
        _G.Disable3DRendering(state)
    end
})

SettingsTab:Button({
    Title = "Boost FPS (Ultra Low Graphics)",
    Callback = function()

        ------------------------------------------------
        -- =============== CORE FUNCTION ===============
        ------------------------------------------------
        local function ApplyUltraLow(obj)
            -- BasePart
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
                obj.Transparency = obj.Transparency > 0.5 and 1 or obj.Transparency
            end

            -- Remove decals & textures
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end

            -- Kill particles
            if obj:IsA("ParticleEmitter") then
                obj.Lifetime = NumberRange.new(0)
            end

            if obj:IsA("Trail") then
                obj.Lifetime = NumberRange.new(0)
            end

            if obj:IsA("Smoke")
            or obj:IsA("Fire")
            or obj:IsA("Explosion")
            or obj:IsA("ForceField")
            or obj:IsA("Sparkles")
            or obj:IsA("Beam") then
                obj.Enabled = false
            end

            -- Lights
            if obj:IsA("SpotLight")
            or obj:IsA("PointLight")
            or obj:IsA("SurfaceLight") then
                obj.Enabled = false
            end

            -- Clothing
            if obj:IsA("ShirtGraphic")
            or obj:IsA("Shirt")
            or obj:IsA("Pants") then
                obj:Destroy()
            end

            -- Sounds
            if obj:IsA("Sound") and obj.Playing and obj.Volume > 0.5 then
                obj.Volume = 0.1
            end
        end

        ------------------------------------------------
        -- APPLY TO CURRENT GAME
        ------------------------------------------------
        for _, v in pairs(game:GetDescendants()) do
            ApplyUltraLow(v)
        end


        ------------------------------------------------
        -- ============ PERMANENT LISTENER ============
        ------------------------------------------------
        game.DescendantAdded:Connect(function(obj)
            task.defer(function()
                ApplyUltraLow(obj)
            end)
        end)

        -- Respawn protection
        game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
            for _, v in pairs(char:GetDescendants()) do
                ApplyUltraLow(v)
            end
            char.DescendantAdded:Connect(ApplyUltraLow)
        end)


        ------------------------------------------------
        -- ============== LOCK LIGHTING ===============
        ------------------------------------------------
        local Lighting = game:GetService("Lighting")
        local function LockLighting()
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") then
                    effect.Enabled = false
                end
            end

            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 1
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.ClockTime = 12
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        end

        -- initial
        LockLighting()

        -- permanent lock
        Lighting.ChildAdded:Connect(function()
            task.defer(LockLighting)
        end)


        ------------------------------------------------
        -- ============== LOCK TERRAIN ================
        ------------------------------------------------
        local function LockTerrain()
            local Terrain = workspace:FindFirstChildOfClass("Terrain")
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
                Terrain.Decoration = false
            end
        end

        LockTerrain()
        workspace.ChildAdded:Connect(function(child)
            if child:IsA("Terrain") then
                task.defer(LockTerrain)
            end
        end)


        ------------------------------------------------
        -- ============== LOCK RENDERING ==============
        ------------------------------------------------
        local function LockRendering()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            settings().Rendering.TextureQuality = Enum.TextureQuality.Low

            local GS = game:GetService("UserSettings").GameSettings
            GS.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
            GS.Fullscreen = true
        end

        LockRendering()


        ------------------------------------------------
        -- LOOP PERMANENT (ANTI RESET)
        ------------------------------------------------
        task.spawn(function()
            while task.wait(2) do
                LockLighting()
                LockTerrain()
                LockRendering()
            end
        end)


        ------------------------------------------------
        -- DISABLE FISHING EFFECT MODULES PERMANENT
        ------------------------------------------------
        local function KillModuleFunctions(moduleScript)
            pcall(function()
                local module = require(moduleScript)
                for k, v in pairs(module) do
                    if typeof(v) == "function" then
                        module[k] = function() end
                    end
                end
            end)
        end

        -- animateBobber
        pcall(function()
            local m =
                game.ReplicatedStorage
                .Controllers
                .FishingController
                .Effects:FindFirstChild("animateBobber")
            if m then KillModuleFunctions(m) end
        end)

        -- Shared.Effects
        pcall(function()
            local folder =
                game.ReplicatedStorage
                .Shared:FindFirstChild("Effects")
            if folder then
                for _, m in pairs(folder:GetChildren()) do
                    if m:IsA("ModuleScript") then
                        KillModuleFunctions(m)
                    end
                end
            end
        end)

        -- RemoteEffect
        pcall(function()
            local remote =
                game.ReplicatedStorage
                .Packages
                ._Index["sleitnick_net@0.2.0"]
                .net.RE:FindFirstChild("PlayFishingEffect")

            if remote then
                remote.OnClientEvent:Connect(function() end)
            end
        end)


        ------------------------------------------------
        -- WHITE SCREEN OPTIONAL
        ------------------------------------------------
        local fullWhite = Instance.new("ScreenGui")
        fullWhite.Name = "FullWhiteScreen"
        fullWhite.ResetOnSpawn = false
        fullWhite.IgnoreGuiInset = true
        fullWhite.Parent = game.CoreGui

        local whiteFrame = Instance.new("Frame")
        whiteFrame.Size = UDim2.new(1, 0, 1, 0)
        whiteFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        whiteFrame.Parent = fullWhite


        ------------------------------------------------
        -- FINISH
        ------------------------------------------------
        NotifySuccess("Boost FPS", "Boost FPS + Ultra Permanent Lock Applied!")

    end
})

SettingsTab:Space()

local TeleportService = game:GetService("TeleportService")

function _G.Rejoin()
    local player = Players.LocalPlayer
    if player then
        TeleportService:Teleport(game.PlaceId, player)
    end
end

function _G.ServerHop()
    local placeId = game.PlaceId
    local servers = {}
    local cursor = ""
    local found = false

    repeat
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end

        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and result and result.data then
            for _, server in pairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            cursor = result.nextPageCursor or ""
        else
            break
        end
    until not cursor or #servers > 0

    if #servers > 0 then
        local targetServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(placeId, targetServer, LocalPlayer)
    else
        NotifyError("Server Hop Failed", "No servers available or all are full!")
    end
end

_G.Keybind = SettingsTab:Keybind({
    Title = "Keybind",
    Desc = "Keybind to open UI",
    Value = "G",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end
})

myConfig:Register("Keybind", _G.Keybind)

SettingsTab:Space()

SettingsTab:Button({
    Title = "Rejoin Server",
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.Rejoin()
    end,
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "Server Hop (New Server)",
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.ServerHop()
    end,
})

SettingsTab:Space()

SettingsTab:Section({
    Title = "Configuration",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

SettingsTab:Button({
    Title = "Save",
    Justify = "Center",
    Icon = "",
    Callback = function()
        myConfig:Save()
        NotifySuccess("Config Saved", "Config has been saved!")
    end
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "Load",
    Justify = "Center",
    Icon = "",
    Callback = function()
        myConfig:Load()
        NotifySuccess("Config Loaded", "Config has beed loaded!")
    end
})

SettingsTab:Space()

-- ============================================================================
-- TELEGRAM SYSTEM - FIXED VERSION (NO DUPLICATES)
-- ============================================================================

-- ========== CORE CONFIG ==========
_G.TELEGRAM_BOT_TOKEN = "8397717015:AAGpYPg2X_rBDumP30MSSXWtDnR_Bi5e_30"

_G.TelegramConfig = {
    Enabled = false,
    BotToken = _G.TELEGRAM_BOT_TOKEN,
    ChatID = "",
    SelectedRarities = {},
    MaxSelection = 3,
    QuestNotifications = true,
    DisconnectNotifications = true
}

-- ========== DATABASE INITIALIZATION ==========
_G.FishDataById = {}
_G.VariantDatabase = {}
_G.FishCategories = {
    ["Secret"] = {
        "Ancient Lochness Monster", "Ancient Whale", "Blob Shark", "Bloodmoon Whale", "Bone Whale",
        "Cryoshade Glider", "Crystal Crab", "Dead Zombie Shark", "Eerie Shark", "Elshark Gran Maja",
        "Frostborn Shark", "Ghost Shark", "Ghost Worm Fish", "Giant Squid", "Gladiator Shark",
        "Great Christmas Whale", "Great Whale", "King Jelly", "Lochness Monster", "Megalodon",
        "Monster Shark", "Mosasaur Shark", "Orca", "Queen Crab", "Robot Kraken", "Scare",
        "Skeleton Narwhal", "Talon Serpent", "Thin Armor Shark", "Wild Serpent", "Worm Fish",
        "Zombie Megalodon", "Zombie Shark"
    },
    ["Mythic"] = {
        "Ancient Relic Crocodile", "Ancient Squid", "Armor Catfish", "Blob Fish", "Cavern Dweller",
        "Crocodile", "Dark Pumpkin Appafish", "Flatheaded Whale Shark", "Fossilized Shark",
        "Frankenstein Longsnapper", "Gingerbread Shark", "Hammerhead Mummy",
        "Hybodus Shark", "King Crab", "Loving Shark", "Luminous Fish", "Magma Shark",
        "Mammoth Appafish", "Panther Eel", "Plasma Serpent", "Primordial Octopus",
        "Pumpkin Ray", "Runic Sea Crustacean", "Runic Squid", "Sea Crustacean",
        "Sharp One", "Starlight Manta Ray"
    },
    ["Legendary"] = {
        "Abyss Seahorse", "Ancient Pufferfish", "Blueflame Ray", "Crystal Salamander",
        "Deep Sea Crab", "Diamond Ring", "Dotted Stingray", "Fish Fossil", "Flying Manta",
        "Ghastly Crab", "Ghastly Hermit Crab", "Gingerbread Turtle", "Hammerhead Shark",
        "Hawks Turtle", "Lake Sturgeon", "Lined Cardinal Fish", "Loggerhead Turtle",
        "Manoai Statue Fish", "Manta Ray", "Plasma Shark", "Primal Axolotl",
        "Primal Lobster", "Prismy Seahorse", "Pumpkin Carved Shark", "Pumpkin Jellyfish",
        "Pumpkin StoneTurtle", "Ruby", "Runic Axolotl", "Runic Lobster",
        "Sacred Guardian Squid", "Saw Fish", "Strippled Seahorse", "Synodontis",
        "Temple Spokes Tuna", "Thresher Shark", "Wizard Stingray"
    }
}

_G.tierToRarity = {
    [1] = "COMMON",
    [2] = "UNCOMMON",
    [3] = "RARE",
    [4] = "EPIC",
    [5] = "LEGENDARY",
    [6] = "MYTHIC",
    [7] = "SECRET"
}

-- Load fish data from ReplicatedStorage
print("[Telegram] Loading fish database...")
for _, item in pairs(ReplicatedStorage.Items:GetChildren()) do
    local ok, data = pcall(require, item)
    if ok and data.Data and data.Data.Type == "Fish" then
        _G.FishDataById[data.Data.Id] = {
            Name = data.Data.Name,
            SellPrice = data.SellPrice or 0,
            Tier = data.Data.Tier or 1,
            Source = data.Data.Source or nil,
            Icon = data.Data.Icon or nil,
            Weight = data.Data.Weight or nil,
            RawModule = data
        }
    end
end

-- Load variant data from ReplicatedStorage
print("[Telegram] Loading variant database...")
for _, variant in pairs(ReplicatedStorage.Variants:GetChildren()) do
    local ok, data = pcall(require, variant)
    if ok and data.Data then
        local variantId = data.Data.Id or variant.Name
        local variantName = data.Data.Name or variant.Name
        _G.VariantDatabase[variantId] = variantName
    end
end

print("[Telegram] Loaded", #ReplicatedStorage.Items:GetChildren(), "fish items")
print("[Telegram] Loaded", #ReplicatedStorage.Variants:GetChildren(), "variants")

-- ========== CORE FUNCTIONS (TETAP SINGLE, TIDAK DUPLIKAT) ==========
_G.GetItemInfo = function(itemId)
    local fishData = _G.FishDataById[itemId]
    if fishData then
        local tierNum = fishData.Tier or 1
        return {
            Name = fishData.Name,
            Type = "Fish",
            Tier = tierNum,
            SellPrice = fishData.SellPrice or 0,
            Weight = fishData.Weight or { Default = nil, Big = nil },
            Icon = fishData.Icon or nil,
            Source = fishData.Source or nil,
            Rarity = _G.tierToRarity[tierNum] or "UNKNOWN",
            RawModule = fishData.RawModule
        }
    end
    return {
        Name = "Unknown Item " .. tostring(itemId),
        Type = "Unknown",
        Tier = 0,
        SellPrice = 0,
        Weight = { Default = nil, Big = nil },
        Icon = nil,
        Rarity = "UNKNOWN"
    }
end

_G.GetVariantName = function(variantId)
    if _G.VariantDatabase[variantId] then
        return _G.VariantDatabase[variantId]
    end
    
    pcall(function()
        for _, variant in pairs(ReplicatedStorage.Variants:GetChildren()) do
            if variant.Name == tostring(variantId) then
                local ok, data = pcall(require, variant)
                if ok and data.Data and data.Data.Name then
                    _G.VariantDatabase[variantId] = data.Data.Name
                    return data.Data.Name
                end
            end
        end
    end)
    
    return ""
end

_G.GetFishRarityFromName = function(fishName)
    for rarity, list in pairs(_G.FishCategories) do
        for _, name in ipairs(list) do
            if name == fishName then
                return string.upper(rarity)
            end
        end
    end
    return "UNKNOWN"
end

-- ========== HTTP & UTILITY FUNCTIONS ==========
_G.safeJSONEncode = function(tbl)
    local ok, res = pcall(function() return HttpService:JSONEncode(tbl) end)
    if ok then return res end
    return "{}"
end

_G.pickHTTPRequest = function(requestTable)
    local ok, result
    if type(syn) == "table" and type(syn.request) == "function" then
        ok, result = pcall(function() return syn.request(requestTable) end)
    elseif type(http_request) == "function" then
        ok, result = pcall(function() return http_request(requestTable) end)
    elseif type(request) == "function" then
        ok, result = pcall(function() return request(requestTable) end)
    elseif type(http) == "table" and type(http.request) == "function" then
        ok, result = pcall(function() return http.request(requestTable) end)
    else
        return false, "No supported HTTP request function found"
    end
    return ok, result
end

_G.CountSelected = function()
    local c = 0
    for k, v in pairs(_G.TelegramConfig.SelectedRarities) do
        if v then c = c + 1 end
    end
    return c
end

_G.GetPlayerStats = function()
    local caught, rarest = "Unknown", "Unknown"
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        pcall(function()
            local c = ls:FindFirstChild("Caught") or ls:FindFirstChild("caught")
            if c and c.Value then caught = tostring(c.Value) end
            local r = ls:FindFirstChild("Rarest Fish") or ls:FindFirstChild("RarestFish") or ls:FindFirstChild("Rarest")
            if r and r.Value then rarest = tostring(r.Value) end
        end)
    end
    return caught, rarest
end

_G.RefreshInventoryCount = function()
    local count = 0
    pcall(function()
        if LocalPlayer.PlayerGui then
            local backpack = LocalPlayer.PlayerGui:FindFirstChild("Backpack")
            if backpack then
                for _, element in pairs(backpack:GetDescendants()) do
                    if element:IsA("TextLabel") and string.find(element.Text or "", "/") then
                        local current = string.match(element.Text, "(%d+)/")
                        if current then
                            count = tonumber(current) or 0
                            break
                        end
                    end
                end
            end
        end
    end)
    return count
end

-- ========== ROD DETECTION ==========
local RodDelays = {
    ["Ares Rod"] = true, ["Angler Rod"] = true, ["Ghostfinn Rod"] = true,
    ["Bamboo Rod"] = true, ["Element Rod"] = true, ["Fluorescent Rod"] = true,
    ["Astral Rod"] = true, ["Hazmat Rod"] = true, ["Chrome Rod"] = true,
    ["Steampunk Rod"] = true, ["Lucky Rod"] = true, ["Midnight Rod"] = true,
    ["Demascus Rod"] = true, ["Grass Rod"] = true, ["Luck Rod"] = true,
    ["Carbon Rod"] = true, ["Lava Rod"] = true, ["Starter Rod"] = true,
}

_G.GetValidRodName = function()
    local player = Players.LocalPlayer
    if not player then return "N/A (No Player)" end
    local backpack = nil
    pcall(function() backpack = player.PlayerGui and player.PlayerGui:FindFirstChild("Backpack") end)
    if not backpack then return "N/A (Backpack Missing)" end
    local display = backpack:FindFirstChild("Display")
    if not display then return "N/A (Display Missing)" end
    for _, tile in ipairs(display:GetChildren()) do
        local inner = tile:FindFirstChild("Inner")
        local tags = inner and inner:FindFirstChild("Tags")
        local itemNameLabel = tags and tags:FindFirstChild("ItemName")
        if itemNameLabel and itemNameLabel:IsA("TextLabel") then
            local nm = itemNameLabel.Text
            if RodDelays[nm] then return nm end
        end
    end
    return "Rod Not Equipped/Found"
end

-- ========== IMAGE HELPERS ==========
_G.GetRobloxImage = function(assetId)
    if not assetId then return nil end
    local ok, response = pcall(function()
        local url = "https://thumbnails.roblox.com/v1/assets?assetIds=" ..
            tostring(assetId) .. "&size=420x420&format=Png&isCircular=false"
        return game:HttpGet(url)
    end)
    if not ok or not response then return nil end
    local success, data = pcall(function() return HttpService:JSONDecode(response) end)
    if success and data and data.data and data.data[1] and data.data[1].imageUrl then
        return data.data[1].imageUrl:gsub("%.png", ".png")
    end
    return nil
end

_G.GetPlayerAvatarUrl = function(userId)
    if not userId then return nil end
    local ok, response = pcall(function()
        return game:HttpGet(("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%s&size=420x420&format=png"):format(tostring(userId)))
    end)
    if not ok or not response then return nil end
    local success, data = pcall(function() return HttpService:JSONDecode(response) end)
    if success and data and data.data and data.data[1] and data.data[1].imageUrl then
        return data.data[1].imageUrl:gsub("%.png", ".png")
    end
    return nil
end

-- ========== SIZE DETECTION ==========
_G.GetFishSizeLabel = function(itemInfo, weightValue, notificationData)
    if notificationData and notificationData.InventoryItem and notificationData.InventoryItem.Metadata then
        local meta = notificationData.InventoryItem.Metadata
        if meta.Size and type(meta.Size) == "string" then
            if meta.Size:lower():find("big") then return "Big" end
            return meta.Size
        end
        if meta.IsBig ~= nil then
            return meta.IsBig == true and "Big" or "Default"
        end
    end
    
    if itemInfo and itemInfo.Weight and (type(itemInfo.Weight) == "table") then
        local w = itemInfo.Weight
        if w.Big and w.Default and type(weightValue) == "number" then
            local tol = math.max(0.001, w.Default * 0.01)
            if math.abs(weightValue - (w.Big or 0)) <= tol then
                return "Big"
            else
                return "Default"
            end
        end
    end
    
    if type(weightValue) == "number" and weightValue >= 100 then
        return "Big"
    end
    
    return "Default"
end

-- ========== SERVER INFO ==========
_G.GetServerInfo = function()
    local serverInfo = {
        JobId = "Unknown",
        PlaceId = "Unknown",
        Players = "0/0",
        Ping = "Unknown",
        FPS = "Unknown",
        ServerRegion = "Unknown",
        ServerAge = "Unknown"
    }
    
    pcall(function() serverInfo.JobId = game.JobId or "Unknown" end)
    pcall(function() serverInfo.PlaceId = tostring(game.PlaceId or "Unknown") end)
    pcall(function()
        local currentPlayers = #game.Players:GetPlayers()
        local maxPlayers = game.Players.MaxPlayers or 0
        serverInfo.Players = currentPlayers .. "/" .. maxPlayers
    end)
    
    local pingValue = nil
    pcall(function()
        if LocalPlayer and LocalPlayer.GetNetworkPing then
            pingValue = LocalPlayer:GetNetworkPing() * 2000
        end
    end)
    
    if pingValue and pingValue > 0 then
        serverInfo.Ping = string.format("%.0f ms", pingValue)
        if pingValue < 50 then serverInfo.ServerRegion = "Local/Asia"
        elseif pingValue < 100 then serverInfo.ServerRegion = "Asia/Europe"
        elseif pingValue < 200 then serverInfo.ServerRegion = "Americas"
        else serverInfo.ServerRegion = "Far/High Ping" end
    end
    
    local fpsValue = nil
    pcall(function() fpsValue = workspace:GetRealPhysicsFPS() end)
    if fpsValue and fpsValue > 0 then
        serverInfo.FPS = string.format("%.0f", fpsValue)
    else
        serverInfo.FPS = "60 (Est.)"
    end
    
    pcall(function()
        local uptime = workspace.DistributedGameTime
        if uptime and uptime > 0 then
            local hours = math.floor(uptime / 3600)
            local minutes = math.floor((uptime % 3600) / 60)
            local seconds = math.floor(uptime % 60)
            serverInfo.ServerAge = string.format("%dh %dm %ds", hours, minutes, seconds)
        end
    end)
    
    return serverInfo
end

-- ========== MESSAGE BUILDERS ==========
_G.BuildTelegramMessage = function(fishInfo, fishId, fishRarity, weight, variantName)
    local playerName = LocalPlayer.Name or "Unknown"
    local displayName = LocalPlayer.DisplayName or playerName
    local userId = tostring(LocalPlayer.UserId or "Unknown")
    local caught, rarest = _G.GetPlayerStats()
    local serverTime = os.date("%H:%M:%S")
    local serverDate = os.date("%Y-%m-%d")
    local inventoryCount = _G.RefreshInventoryCount()
    
    local fishName = (fishInfo and fishInfo.Name) or "Unknown"
    local fishTier = tostring((fishInfo and fishInfo.Tier) or "?")
    local sellPrice = tostring((fishInfo and fishInfo.SellPrice) or "?")
    
    local weightDisplay = "?"
    if weight then
        if type(weight) == "number" then
            weightDisplay = string.format("%.2fkg", weight)
        else
            weightDisplay = tostring(weight) .. "kg"
        end
    end
    
    local fishRarityStr = string.upper(tostring(fishRarity or (fishInfo and fishInfo.Rarity) or "UNKNOWN"))
    local invDisplay = inventoryCount and tostring(inventoryCount) .. "/4500" or "Unknown"
    
    local mutationText = "No Mutation"
    if variantName and variantName ~= "" and variantName ~= "0" then
        mutationText = variantName
    end
    
    local message = "```\n"
    message = message .. "🎉 HOREE ANDA BERHASIL MENDAPATKAN " .. fishRarityStr .. "! 🎉\n\n"
    message = message .. "========================================\n"
    message = message .. "NIKZZ SCRIPT FISH IT\n"
    message = message .. "DEVELOPER: NIKZZ\n"
    message = message .. "========================================\n\n"
    message = message .. "PLAYER INFORMATION\n"
    message = message .. "     NAME: " .. playerName .. "\n"
    if displayName ~= playerName then
        message = message .. "     DISPLAY: " .. displayName .. "\n"
    end
    message = message .. "     ID: " .. userId .. "\n"
    message = message .. "     CAUGHT: " .. caught .. "\n"
    message = message .. "     RAREST: " .. rarest .. "\n\n"
    message = message .. "FISH DETAILS\n"
    message = message .. "     NAME: " .. fishName .. "\n"
    message = message .. "     ID: " .. tostring(fishId or "?") .. "\n"
    message = message .. "     TIER: " .. fishTier .. "\n"
    message = message .. "     RARITY: " .. fishRarityStr .. "\n"
    message = message .. "     WEIGHT: " .. weightDisplay .. "\n"
    message = message .. "     PRICE: " .. sellPrice .. " COINS\n\n"
    message = message .. "INVENTORY STATUS\n"
    message = message .. "     COUNT: " .. invDisplay .. "\n\n"
    message = message .. "SYSTEM STATS\n"
    message = message .. "     TIME: " .. serverTime .. "\n"
    message = message .. "     DATE: " .. serverDate .. "\n\n"
    message = message .. "DEVELOPER SOCIALS\n"
    message = message .. "     TIKTOK: @nikzzxit\n"
    message = message .. "     INSTAGRAM: @n1kzx.z\n"
    message = message .. "     ROBLOX: @Nikzz7z\n\n"
    message = message .. "STATUS: ACTIVE\n"
    message = message .. "========================================\n```"
    
    return message
end

_G.BuildTelegramImageCaption = function(fishInfo, fishId, fishRarity, weight, variantName, notificationData)
    local original = _G.BuildTelegramMessage(fishInfo, fishId, fishRarity, weight, variantName) or ""
    local rodName = "Unknown Rod"
    pcall(function() rodName = _G.GetValidRodName() or rodName end)
    local sizeLabel = _G.GetFishSizeLabel(itemInfo, weight, notificationData) or "Default"
    local modified = tostring(original)
    
    local sizeInsert = "     SIZE: " .. tostring(sizeLabel) .. "\n"
    local replaced, count = modified:gsub("(WEIGHT:%s*.-\n)", "%1" .. sizeInsert, 1)
    if count > 0 then
        modified = replaced
    else
        modified = modified:gsub("(FISH DETAILS\n)", "%1" .. sizeInsert, 1)
    end
    
    local rodInsert = "     ROD: " .. tostring(rodName) .. "\n"
    local invStart = modified:find("INVENTORY STATUS\n")
    if invStart then
        local replaced2, c2 = modified:gsub("(%s*COUNT:%s*.-\n)", "%1" .. rodInsert, 1)
        if c2 > 0 then
            modified = replaced2
        else
            modified = modified:gsub("(INVENTORY STATUS\n)", "%1" .. "     COUNT: Unknown\n" .. rodInsert, 1)
        end
    end
    
    return modified
end

_G.BuildDisconnectMessage = function(reason)
    local playerName = LocalPlayer.Name or "Unknown"
    local displayName = LocalPlayer.DisplayName or playerName
    local userId = tostring(LocalPlayer.UserId or "Unknown")
    local serverTime = os.date("%H:%M:%S")
    local serverDate = os.date("%Y-%m-%d")
    local caught, rarest = _G.GetPlayerStats()
    local serverInfo = _G.GetServerInfo()
    local reasonText = tostring(reason or "Unknown Reason")
    
    local message = "```\n"
    message = message .. "⚠️ DISCONNECTED FROM SERVER ⚠️\n\n"
    message = message .. "========================================\n"
    message = message .. "NIKZZ SCRIPT FISH IT\n"
    message = message .. "DISCONNECT NOTIFICATION\n"
    message = message .. "========================================\n\n"
    message = message .. "PLAYER INFORMATION\n"
    message = message .. "     NAME: " .. playerName .. "\n"
    if displayName ~= playerName then message = message .. "     DISPLAY: " .. displayName .. "\n" end
    message = message .. "     USER ID: " .. userId .. "\n"
    message = message .. "     CAUGHT: " .. caught .. "\n"
    message = message .. "     RAREST: " .. rarest .. "\n\n"
    message = message .. "SERVER INFORMATION\n"
    message = message .. "     JOB ID: " .. serverInfo.JobId .. "\n"
    message = message .. "     PLACE ID: " .. serverInfo.PlaceId .. "\n"
    message = message .. "     PLAYERS: " .. serverInfo.Players .. "\n"
    message = message .. "     PING: " .. serverInfo.Ping .. "\n"
    message = message .. "     FPS: " .. serverInfo.FPS .. "\n"
    message = message .. "     REGION: " .. serverInfo.ServerRegion .. "\n"
    message = message .. "     UPTIME: " .. serverInfo.ServerAge .. "\n\n"
    message = message .. "DISCONNECT DETAILS\n"
    message = message .. "     REASON: " .. reasonText .. "\n"
    message = message .. "     TIME: " .. serverTime .. "\n"
    message = message .. "     DATE: " .. serverDate .. "\n\n"
    message = message .. "STATUS: DISCONNECTED\n"
    message = message .. "========================================\n```"
    
    return message
end

-- ========== TELEGRAM SENDERS ==========
_G.SendTelegram = function(message)
    if not _G.TelegramConfig.Enabled then return false, "telegram disabled" end
    if not _G.TelegramConfig.BotToken or _G.TelegramConfig.BotToken == "" then return false, "no token" end
    if not _G.TelegramConfig.ChatID or _G.TelegramConfig.ChatID == "" then return false, "no chat id" end
    
    local url = ("https://api.telegram.org/bot%s/sendMessage"):format(_G.TelegramConfig.BotToken)
    local payload = {
        chat_id = _G.TelegramConfig.ChatID,
        text = message,
        parse_mode = "Markdown"
    }
    
    local req = {
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = _G.safeJSONEncode(payload)
    }
    
    local ok, res = _G.pickHTTPRequest(req)
    if not ok then
        warn("[Telegram] HTTP request failed:", res)
        return false, res
    end
    
    if type(res) == "table" and (res.Success or (res.StatusCode and res.StatusCode == 200)) then
        print("[Telegram] Message sent successfully")
        return true, res
    else
        warn("[Telegram] Failed to send message")
        return false, res
    end
end

_G.SendTelegramPhoto = function(photoUrl, caption)
    if not _G.TelegramConfig.Enabled then return false, "telegram disabled" end
    if not _G.TelegramConfig.BotToken or _G.TelegramConfig.BotToken == "" then return false, "no token" end
    if not _G.TelegramConfig.ChatID or _G.TelegramConfig.ChatID == "" then return false, "no chat id" end
    if not photoUrl or photoUrl == "" then return false, "no photo url" end
    
    local url = ("https://api.telegram.org/bot%s/sendPhoto"):format(_G.TelegramConfig.BotToken)
    local safeCaption = tostring(caption or "")
    
    if #safeCaption > 1000 then
        local payload = { chat_id = _G.TelegramConfig.ChatID, photo = photoUrl }
        local req = { Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(payload) }
        local ok, res = _G.pickHTTPRequest(req)
        if not ok then return false, res end
        _G.SendTelegram(safeCaption)
        return true, res
    else
        local payload = {
            chat_id = _G.TelegramConfig.ChatID,
            photo = photoUrl,
            caption = safeCaption,
            parse_mode = "Markdown"
        }
        local req = { Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(payload) }
        local ok, res = _G.pickHTTPRequest(req)
        if not ok then return false, res end
        return true, res
    end
end

_G.ShouldSendByRarity = function(rarity)
    if not _G.TelegramConfig.Enabled then return false end
    if _G.CountSelected() == 0 then return false end
    local key = string.upper(tostring(rarity or "UNKNOWN"))
    return _G.TelegramConfig.SelectedRarities[key] == true
end

-- ========== DISCONNECT DETECTION ==========
_G.Tele_LastDisconnect = 0
_G.Tele_DisconnectCooldown = 6

_G.Tele_SendDisconnect = function(reason)
    if not _G.TelegramConfig.Enabled or not _G.TelegramConfig.DisconnectNotifications then return end
    if tick() - _G.Tele_LastDisconnect < _G.Tele_DisconnectCooldown then return end
    _G.Tele_LastDisconnect = tick()
    
    local caption = _G.BuildDisconnectMessage(reason)
    local avatar = nil
    pcall(function() avatar = _G.GetPlayerAvatarUrl(LocalPlayer.UserId) or "" end)
    
    if avatar and avatar ~= "" then
        _G.SendTelegramPhoto(avatar, caption)
    else
        _G.SendTelegram(caption)
    end
end

_G.SetupDisconnectDetection = function()
    if not _G.TelegramConfig.Enabled then return end
    
    print("[Telegram] Setting up enhanced disconnect detection...")
    
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        if _G.TelegramConfig.Enabled and _G.TelegramConfig.DisconnectNotifications then
            local errorMsg = game:GetService("GuiService"):GetErrorMessage()
            if errorMsg and errorMsg ~= "" then _G.Tele_SendDisconnect("Error: " .. errorMsg) end
        end
    end)
    
    LocalPlayer.Kicked:Connect(function(reason)
        if _G.TelegramConfig.Enabled and _G.TelegramConfig.DisconnectNotifications then
            _G.Tele_SendDisconnect("Kicked: " .. tostring(reason))
        end
    end)
    
    local NetClient = game:GetService("NetworkClient")
    if NetClient then
        NetClient.ChildRemoved:Connect(function()
            if _G.TelegramConfig.Enabled and _G.TelegramConfig.DisconnectNotifications then
                task.wait(0.5)
                _G.Tele_SendDisconnect("Connection Lost")
            end
        end)
    end
    
    game:GetService("CoreGui").DescendantRemoving:Connect(function(obj)
        if obj.Name == "RobloxPromptGui" then
            if _G.TelegramConfig.Enabled and _G.TelegramConfig.DisconnectNotifications then
                _G.Tele_SendDisconnect("Game Closed / Force Close")
            end
        end
    end)
    
    game.DescendantAdded:Connect(function(obj)
        if tostring(obj):lower():find("update") then
            if _G.TelegramConfig.Enabled and _G.TelegramConfig.DisconnectNotifications then
                _G.Tele_SendDisconnect("Game Update Triggered")
            end
        end
    end)
    
    -- Freeze detection
    task.spawn(function()
        local lastPos = nil
        local lastMove = tick()
        while task.wait(1) do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if lastPos then
                    local dist = (hrp.Position - lastPos).Magnitude
                    if dist < 0.5 then
                        if tick() - lastMove >= 12 then
                            _G.Tele_SendDisconnect("Player Frozen / Game Hang (no movement detected)")
                            lastMove = tick()
                        end
                    else
                        lastMove = tick()
                    end
                else
                    lastMove = tick()
                end
                lastPos = hrp.Position
            end
        end
    end)
    
    print("[Telegram] Enhanced disconnect detection enabled!")
end

-- Auto-enable disconnect detection when Telegram is enabled
task.spawn(function()
    while task.wait(1) do
        if _G.TelegramConfig.Enabled and _G.TelegramConfig.DisconnectNotifications then
            _G.SetupDisconnectDetection()
            break
        end
    end
end)

-- ========== FISH NOTIFICATION HOOK ==========
_G.SetupFishHook = function()
    if _G.FishHookConnected then
        print("[Telegram] Hook already connected, skipping")
        return
    end
    _G.FishHookConnected = true
    
    local REObtainedNewFishNotification = ReplicatedStorage
        .Packages._Index["sleitnick_net@0.2.0"]
        .net["RE/ObtainedNewFishNotification"]
    
    if REObtainedNewFishNotification then
        REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, _, data)
            if not _G.TelegramConfig.Enabled then return end
            if not itemId or not data then return end
            
            local fishId = itemId
            local weight = data.InventoryItem and data.InventoryItem.Metadata and data.InventoryItem.Metadata.Weight
            local variantId = data.InventoryItem and data.InventoryItem.Metadata and (data.InventoryItem.Metadata.VariantId or data.InventoryItem.Metadata.Variant)
            local variantName = variantId and _G.GetVariantName(variantId) or ""
            
            local itemInfo = _G.GetItemInfo(fishId)
            
            -- Rarity
            local actualRarity = _G.GetFishRarityFromName(itemInfo.Name)
            if actualRarity == "UNKNOWN" then actualRarity = itemInfo.Rarity end
            
            if _G.ShouldSendByRarity(actualRarity) then
                -- Build caption with notification data for size detection
                local caption = _G.BuildTelegramImageCaption(itemInfo, fishId, actualRarity, weight, variantName, data)
                
                -- Determine fish image URL
                local fishImageUrl = nil
                
                -- 1) Prefer itemInfo.Icon if present and it's a rbxassetid
                if itemInfo and itemInfo.Icon and type(itemInfo.Icon) == "string" then
                    local id = tostring(itemInfo.Icon):match("(%d+)")
                    if id then
                        fishImageUrl = _G.GetRobloxImage(id)
                    else
                        fishImageUrl = itemInfo.Icon
                    end
                end
                
                -- 2) If not available, check metadata AssetId
                if not fishImageUrl and data.InventoryItem and data.InventoryItem.Metadata then
                    local meta = data.InventoryItem.Metadata
                    if meta.AssetId then
                        fishImageUrl = _G.GetRobloxImage(meta.AssetId)
                    end
                end
                
                -- 3) Fallback: try to find thumbnail in ReplicatedStorage module
                if not fishImageUrl then
                    pcall(function()
                        for _, mod in pairs(ReplicatedStorage.Items:GetChildren()) do
                            local ok, dat = pcall(require, mod)
                            if ok and dat and dat.Data and dat.Data.Id == fishId then
                                if dat.Data.Icon then
                                    local id = tostring(dat.Data.Icon):match("(%d+)")
                                    if id then 
                                        fishImageUrl = _G.GetRobloxImage(id)
                                        break
                                    end
                                end
                                if dat.Data.ThumbnailId then
                                    fishImageUrl = _G.GetRobloxImage(dat.Data.ThumbnailId)
                                    break
                                end
                            end
                        end
                    end)
                end
                
                -- 4) Final fallback: player's avatar
                if not fishImageUrl then
                    fishImageUrl = _G.GetPlayerAvatarUrl(LocalPlayer.UserId) or ""
                end
                
                spawn(function()
                    local ok, res
                    if fishImageUrl and fishImageUrl ~= "" then
                        ok, res = _G.SendTelegramPhoto(fishImageUrl, caption)
                    else
                        ok, res = _G.SendTelegram(caption)
                    end
                    
                    if ok then
                        print("[Telegram] Fish photo notification sent:", itemInfo.Name, "(" .. actualRarity .. ")")
                    else
                        warn("[Telegram] Failed to send fish notification:", res)
                    end
                end)
            end
        end)
        
        print("[Telegram] Fish hook setup successfully (ONE TIME ONLY)")
    else
        warn("[Telegram] ObtainedNewFishNotification remote not found")
    end
end

-- ========== FINAL INITIALIZATION ==========
print("[TELEGRAM SYSTEM] ✅ Loaded Successfully!")
print("[TELEGRAM SYSTEM] Fish Database:", #ReplicatedStorage.Items:GetChildren(), "items")
print("[TELEGRAM SYSTEM] Variant Database:", #ReplicatedStorage.Variants:GetChildren(), "variants")
print("[TELEGRAM SYSTEM] Ready to use!")

-------------------------------------------
----- =======[ HOOK TAB ]
-------------------------------------------

HookTab:Section({
    Title = "Telegram Settings",
    TextSize = 20,
    TextXAlignment = "Center",
    Opened = true
})

local telegramToggle = HookTab:Toggle({
    Title = "Enable Telegram Hook",
    Desc = "Send fish notifications to Telegram",
    Value = _G.TelegramConfig.Enabled,
    Callback = function(v)
        _G.TelegramConfig.Enabled = v
        if v then
            NotifySuccess("Telegram", "Notifications enabled!")
            -- Auto setup hook
            task.wait(1)
            _G.SetupFishHook()
        else
            NotifyWarning("Telegram", "Notifications disabled")
        end
    end
})

myConfig:Register("TelegramEnabled", telegramToggle)

HookTab:Space()

local chatIDInput = HookTab:Input({
    Title = "Telegram Chat ID",
    Desc = "Enter your Telegram Chat ID",
    Placeholder = "e.g., -1001234567890",
    Value = _G.TelegramConfig.ChatID or "",
    Callback = function(Text)
        _G.TelegramConfig.ChatID = Text
        NotifySuccess("💾 Chat ID Saved", "Telegram configured successfully!")
    end
})

myConfig:Register("TelegramChatID", chatIDInput)

HookTab:Space()

HookTab:Paragraph({
    Title = "ℹ️ Token Info",
    Desc = "Bot token is pre-configured. Just enter your Chat ID above to start receiving notifications.\n\nTo get your Chat ID:\n1. Message @userinfobot on Telegram\n2. Copy your ID\n3. Paste it above"
})

HookTab:Space()

HookTab:Section({
    Title = "Select Rarities (Max 3)",
    TextSize = 20,
    TextXAlignment = "Center",
    Opened = true
})

-- List rarities
local rarities = {"SECRET", "MYTHIC", "LEGENDARY", "EPIC", "RARE", "UNCOMMON", "COMMON"}

-- Pastikan table sudah ada
if not _G.TelegramConfig.SelectedRarities then
    _G.TelegramConfig.SelectedRarities = {}
end

-- Convert SelectedRarities table → array untuk dropdown default values
local function GetDefaultSelections()
    local list = {}
    for rarity, selected in pairs(_G.TelegramConfig.SelectedRarities) do
        if selected then
            table.insert(list, rarity)
        end
    end
    return list
end

_G.RarityDropdown = HookTab:Dropdown({
    Title = "Choose Rarities",
    Desc = "Select up to 3 rarities to notify",
    Values = rarities,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Default = GetDefaultSelections(),
    Callback = function(selectedList)
        
        -- Batasi max 3
        if #selectedList > _G.TelegramConfig.MaxSelection then
            NotifyWarning("⚠️ Max 3 Rarities", "You can only select up to 3 rarities!")
            -- Revert to previous saved selection
            task.spawn(function()
                task.wait(0.05)
                _G.RarityDropdown:SetValue(GetDefaultSelections())
            end)
            return
        end

        -- Clear & apply new values
        for _, r in ipairs(rarities) do
            _G.TelegramConfig.SelectedRarities[r] = false
        end
        
        for _, r in ipairs(selectedList) do
            _G.TelegramConfig.SelectedRarities[r] = true
        end

        NotifySuccess("Rarity Updated", "Selected rarities: " .. table.concat(selectedList, ", "))
        print("[Telegram] Updated SelectedRarities:", selectedList)
    end
})

-- Register config
myConfig:Register("RaritySelections", _G.RarityDropdown)

HookTab:Section({
    Title = "Test Notifications",
    TextSize = 20,
    TextXAlignment = "Center",
    Opened = true
})

HookTab:Button({
    Title = "Test Random SECRET",
    Desc = "Send test SECRET fish notification",
    Justify = "Center",
    Icon = "send",
    Callback = function()
        if _G.TelegramConfig.ChatID == "" then
            NotifyError("❌ Error", "Enter Chat ID first!")
            return
        end
        
        local secretItems = {}
        for id, fishData in pairs(_G.FishDataById) do
            local tierNum = fishData.Tier or 1
            if tierNum == 7 then
                table.insert(secretItems, {Id = id, Data = fishData})
            end
        end
        
        if #secretItems == 0 then
            NotifyError("❌ No Data", "No SECRET items in database")
            return
        end
        
        local chosen = secretItems[math.random(1, #secretItems)]
        local weight = math.random(2, 6) + math.random()
        local itemInfo = _G.GetItemInfo(chosen.Id)
        
        -- FIX: Parameter ke-5 adalah variant, bukan inventoryCount
        local msg = _G.BuildTelegramMessage(itemInfo, chosen.Id, "SECRET", weight, "")
        local success, result = _G.SendTelegram(msg)
        
        if success then
            NotifySuccess("✅ Test Sent", "SECRET fish notification sent!")
        else
            NotifyError("❌ Failed", "Failed to send: " .. tostring(result))
        end
    end
})

HookTab:Space()

HookTab:Button({
    Title = "Test Random LEGENDARY",
    Desc = "Send test LEGENDARY fish notification",
    Justify = "Center",
    Icon = "send",
    Callback = function()
        if _G.TelegramConfig.ChatID == "" then
            NotifyError("❌ Error", "Enter Chat ID first!")
            return
        end
        
        if not _G.TelegramConfig.SelectedRarities["LEGENDARY"] then
            NotifyError("❌ Error", "Select LEGENDARY rarity first!")
            return
        end
        
        local legendaryItems = {}
        for id, fishData in pairs(_G.FishDataById) do
            local tierNum = fishData.Tier or 1
            if tierNum == 5 then
                table.insert(legendaryItems, {Id = id, Data = fishData})
            end
        end
        
        if #legendaryItems == 0 then
            NotifyError("❌ No Data", "No LEGENDARY items in database")
            return
        end
        
        local chosen = legendaryItems[math.random(1, #legendaryItems)]
        local weight = math.random(1, 5) + math.random()
        local itemInfo = _G.GetItemInfo(chosen.Id)
        
        -- FIX: Parameter ke-5 adalah variant, bukan inventoryCount
        local msg = _G.BuildTelegramMessage(itemInfo, chosen.Id, "LEGENDARY", weight, "")
        local success, result = _G.SendTelegram(msg)
        
        if success then
            NotifySuccess("✅ Test Sent", "LEGENDARY fish notification sent!")
            print("[Telegram] Test LEGENDARY sent:", chosen.Data.Name)
        else
            NotifyError("❌ Failed", "Failed to send: " .. tostring(result))
        end
    end
})

HookTab:Space()

HookTab:Button({
    Title = "Test Random MYTHIC",
    Desc = "Send test MYTHIC fish notification",
    Justify = "Center",
    Icon = "send",
    Callback = function()
        if _G.TelegramConfig.ChatID == "" then
            NotifyError("❌ Error", "Enter Chat ID first!")
            return
        end
        
        local mythicItems = {}
        for id, fishData in pairs(_G.FishDataById) do
            local tierNum = fishData.Tier or 1
            if tierNum == 6 then
                table.insert(mythicItems, {Id = id, Data = fishData})
            end
        end
        
        if #mythicItems == 0 then
            NotifyError("❌ No Data", "No MYTHIC items in database")
            return
        end
        
        local chosen = mythicItems[math.random(1, #mythicItems)]
        local weight = math.random(2, 5) + math.random()
        local itemInfo = _G.GetItemInfo(chosen.Id)
        
        -- FIX: Parameter ke-5 adalah variant, bukan inventoryCount
        local msg = _G.BuildTelegramMessage(itemInfo, chosen.Id, "MYTHIC", weight, "")
        local success, result = _G.SendTelegram(msg)
        
        if success then
            NotifySuccess("✅ Test Sent", "MYTHIC fish notification sent!")
        else
            NotifyError("❌ Failed", "Failed to send: " .. tostring(result))
        end
    end
})

HookTab:Space()

HookTab:Button({
    Title = "Debug Selection",
    Desc = "Check current Telegram settings",
    Justify = "Center",
    Icon = "bug",
    Callback = function()
        local selected = {}
        for rarity, isSelected in pairs(_G.TelegramConfig.SelectedRarities) do
            if isSelected then
                table.insert(selected, rarity)
            end
        end
        
        local status = string.format(
            "Enabled: %s\nChat ID: %s\nSelected: %s\nFish DB: %d items",
            tostring(_G.TelegramConfig.Enabled),
            _G.TelegramConfig.ChatID or "Not set",
            #selected > 0 and table.concat(selected, ", ") or "None",
            #ReplicatedStorage.Items:GetChildren()
        )
        
        NotifyInfo("📋 Telegram Status", status)
        print("[Telegram DEBUG]", status)
    end
})
