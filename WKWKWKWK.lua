-- 🔗 Daftar link raw berisi username (satu username per baris)
local rawLinks = {
    "https://pastebin.com/raw/rF5yKB6B"
}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local myName = string.lower(localPlayer.DisplayName)

-- 🔁 Ambil semua username dari raw links
local function fetchAllowedUsers()
    local allowed = {}

    for _, link in ipairs(rawLinks) do
        local success, result = pcall(function()
            return game:HttpGet(link)
        end)

        if success and result and #result > 0 then
            for line in string.gmatch(result, "[^\r\n]+") do
                allowed[string.lower(line)] = true
            end
        end
    end

    return allowed
end

-- 🚨 Cek username pertama kali
local allowedUsers = fetchAllowedUsers()

if not allowedUsers[myName] then
    localPlayer:Kick("⚠️ Akun Anda Tidak Memiliki Akses Untuk Menjalankan NKZ SCRIPT")
    return
end

-- 🔥 Fungsi aman untuk load script
local function safeLoad(url)
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet(url))()
        end)
    end)
end

-- ⏬ Jika lolos → langsung load script
safeLoad("https://paste.monster/KAThKHPYzcmE/raw/")
safeLoad("https://paste.monster/Bc43d7EeHiyt/raw/")
task.wait(8)
safeLoad("https://pastebin.com/raw/3nxCf55f")

-- 🔄 Re-check setiap 5 detik (auto blacklist)
task.spawn(function()
    while task.wait(5) do
        local updatedList = fetchAllowedUsers()

        if not updatedList[myName] then
            localPlayer:Kick("⚠️ Anda telah di-blacklist dari script ini.")
            break
        end
    end
end)
