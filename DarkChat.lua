--[[ KHANH BEO DARK CHAT - V5 ]]
-- Tự động nhận diện Admin (Bạn) và Người dùng (Bạn bè)

local P = game:GetService("Players")
local U = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local L = P.LocalPlayer

-- ==========================================
-- CẤU HÌNH ADMIN (QUAN TRỌNG)
-- Đã cập nhật theo yêu cầu: HiBro800000
-- ==========================================
local ADMIN_USERNAME = "HiBro800000"
local IS_ADMIN = (L.Name == ADMIN_USERNAME)

-- CẤU HÌNH CHUNG
local Settings = {
    BGColor = Color3.fromRGB(15, 15, 20),
}
local CHAT_REMOTE = RS:FindFirstChild("KB_DarkChat_System") or Instance.new("RemoteEvent", RS)
CHAT_REMOTE.Name = "KB_DarkChat_System"
local BannedPlayers = {}

-- ============ HÀM TẠO BONG BÓNG CHAT (GIỐNG ROBLOX) ============
local function createPublicChatBubble(character, playerName, message)
    local head = character:FindFirstChild("Head")
    if not head then return end
    local old = head:FindFirstChild("KB_RobloxBubble")
    if old then old:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "KB_RobloxBubble"
    billboard.Size = UDim2.new(0, 250, 0, 36)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 100
    billboard.Parent = head

    local bubbleFrame = Instance.new("Frame", billboard)
    bubbleFrame.Size = UDim2.new(1, 0, 1, 0)
    bubbleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bubbleFrame.BackgroundTransparency = 0.4
    bubbleFrame.BorderSizePixel = 0
    Instance.new("UICorner", bubbleFrame).CornerRadius = UDim.new(0, 4)
    
    local stroke = Instance.new("UIStroke", bubbleFrame)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.7

    local textLabel = Instance.new("TextLabel", bubbleFrame)
    textLabel.Size = UDim2.new(1, -12, 1, -8)
    textLabel.Position = UDim2.new(0, 6, 0, 4)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 16
    textLabel.TextWrapped = true
    textLabel.RichText = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Center
    -- Tên màu cam, chữ trắng
    textLabel.Text = string.format('<font color="rgb(255, 170, 0)">%s:</font> <font color="rgb(255,255,255)">%s</font>', playerName, message)
    
    task.delay(7, function()
        if bubbleFrame and bubbleFrame.Parent then
            TweenService:Create(bubbleFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
            task.wait(0.5)
            billboard:Destroy()
        end
    end)
end

-- ============ GIAO DIỆN CHAT CHUNG ============
local SG = Instance.new("ScreenGui")
SG.Name = "DarkChatUI_V5"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.DisplayOrder = 2^31-1
SG.Parent = L:WaitForChild("PlayerGui")

local ChatFrame = Instance.new("Frame", SG)
ChatFrame.Size = UDim2.new(0, 300, 0, 260)
ChatFrame.Position = UDim2.new(0, 20, 1, -290)
ChatFrame.BackgroundColor3 = Settings.BGColor
ChatFrame.BorderSizePixel = 0
ChatFrame.Active = true
ChatFrame.Draggable = true
Instance.new("UICorner", ChatFrame).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("Frame", ChatFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = IS_ADMIN and "🌑 Dark Chat (Admin)" or "🌑 Dark Chat"
Title.TextColor3 = Color3.fromRGB(200, 200, 210)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0.5, -10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

local MsgScroll = Instance.new("ScrollingFrame", ChatFrame)
MsgScroll.Size = UDim2.new(1, -20, 1, -70)
MsgScroll.Position = UDim2.new(0, 10, 0, 35)
MsgScroll.BackgroundTransparency = 1
MsgScroll.ScrollBarThickness = 2
MsgScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
MsgScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local MsgList = Instance.new("UIListLayout", MsgScroll)
MsgList.Padding = UDim.new(0, 2)

local InputBox = Instance.new("TextBox", ChatFrame)
InputBox.Size = UDim2.new(1, -20, 0, 28)
InputBox.Position = UDim2.new(0, 10, 1, -34)
InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
InputBox.BorderSizePixel = 0
InputBox.Text = ""
InputBox.PlaceholderText = "Nhập tin nhắn..."
InputBox.TextColor3 = Color3.new(1,1,1)
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 12
InputBox.ClearTextOnFocus = false
Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)

local function AddMessage(playerName, text, isMuted)
    local Msg = Instance.new("TextLabel", MsgScroll)
    Msg.Size = UDim2.new(1, 0, 0, 16)
    Msg.BackgroundTransparency = 1
    Msg.RichText = true
    
    local color = isMuted and "rgb(150,150,150)" or "rgb(80,220,120)"
    Msg.Text = string.format('<font color="%s">%s</font>: <font color="rgb(255,255,255)">%s</font>', color, playerName, text)
    Msg.Font = Enum.Font.Gotham
    Msg.TextSize = 11
    Msg.TextXAlignment = Enum.TextXAlignment.Left
    task.defer(function() MsgScroll.CanvasPosition = Vector2.new(0, MsgList.AbsoluteContentSize.Y) end)
end

-- ============ SỰ KIỆN CHAT ============
CHAT_REMOTE.OnClientEvent:Connect(function(action, senderName, message)
    if action == "MSG" then
        AddMessage(senderName, message, false)
    elseif action == "BAN" then
        if senderName == L.Name then
            BannedPlayers[L.Name] = true
            ChatFrame.Visible = false
            local banUI = Instance.new("Frame", SG)
            banUI.Size = UDim2.new(0, 250, 0, 60)
            banUI.Position = UDim2.new(0.5, -125, 0.5, -30)
            banUI.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
            Instance.new("UICorner", banUI).CornerRadius = UDim.new(0, 8)
            local txt = Instance.new("TextLabel", banUI)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Text = "🚫 Bạn đã bị Ban Chat!\nLý do: " .. message
            txt.TextColor3 = Color3.new(1,1,1)
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 12
            txt.TextWrapped = true
        end
    elseif action == "UNBAN" then
        if senderName == L.Name then
            BannedPlayers[L.Name] = nil
            ChatFrame.Visible = true
        end
    end
end)

InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and InputBox.Text ~= "" then
        if BannedPlayers[L.Name] then return end
        local text = InputBox.Text
        AddMessage(L.Name, text, false)
        if L.Character then createPublicChatBubble(L.Character, L.Name, text) end
        pcall(function() CHAT_REMOTE:FireServer("MSG", L.Name, text) end)
        InputBox.Text = ""
    end
end)

CloseBtn.MouseButton1Click:Connect(function() ChatFrame.Visible = false end)
U.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.T then ChatFrame.Visible = not ChatFrame.Visible end
end)

-- ==========================================
-- ADMIN PANEL (Chỉ hiện nếu bạn là Admin)
-- ==========================================
if IS_ADMIN then
    print("[Dark Chat] Bạn là Admin. Đã bật Admin Panel.")
    
    local AdminBtn = Instance.new("TextButton", SG)
    AdminBtn.Size = UDim2.new(0, 45, 0, 45)
    AdminBtn.Position = UDim2.new(0, 20, 0.3, 0)
    AdminBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    AdminBtn.Text = "👑"
    AdminBtn.TextSize = 22
    AdminBtn.AutoButtonColor = false
    Instance.new("UICorner", AdminBtn).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", AdminBtn).Color = Color3.fromRGB(255, 50, 50)

    local AdminFrame = Instance.new("Frame", SG)
    AdminFrame.Size = UDim2.new(0, 340, 0, 300)
    AdminFrame.Position = UDim2.new(0, 80, 0.5, -150)
    AdminFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    AdminFrame.BorderSizePixel = 0
    AdminFrame.Active = true
    AdminFrame.Draggable = true
    AdminFrame.Visible = false
    Instance.new("UICorner", AdminFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", AdminFrame).Color = Color3.fromRGB(255, 50, 50)

    local AdminHeader = Instance.new("Frame", AdminFrame)
    AdminHeader.Size = UDim2.new(1, 0, 0, 40)
    AdminHeader.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
    AdminHeader.BorderSizePixel = 0
    Instance.new("UICorner", AdminHeader).CornerRadius = UDim.new(0, 12)

    local AdminTitle = Instance.new("TextLabel", AdminHeader)
    AdminTitle.Size = UDim2.new(1, -40, 1, 0)
    AdminTitle.Position = UDim2.new(0, 10, 0, 0)
    AdminTitle.BackgroundTransparency = 1
    AdminTitle.Text = "👑 Admin Panel"
    AdminTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
    AdminTitle.Font = Enum.Font.GothamBold
    AdminTitle.TextSize = 14
    AdminTitle.TextXAlignment = Enum.TextXAlignment.Left

    local AdminCloseBtn = Instance.new("TextButton", AdminHeader)
    AdminCloseBtn.Size = UDim2.new(0, 24, 0, 24)
    AdminCloseBtn.Position = UDim2.new(1, -32, 0.5, -12)
    AdminCloseBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
    AdminCloseBtn.BorderSizePixel = 0
    AdminCloseBtn.Text = "×"
    AdminCloseBtn.TextColor3 = Color3.new(1,1,1)
    AdminCloseBtn.Font = Enum.Font.GothamBold
    AdminCloseBtn.TextSize = 15
    Instance.new("UICorner", AdminCloseBtn).CornerRadius = UDim.new(1, 0)

    local Note = Instance.new("TextLabel", AdminFrame)
    Note.Size = UDim2.new(1, -20, 0, 20)
    Note.Position = UDim2.new(0, 10, 0, 45)
    Note.BackgroundTransparency = 1
    Note.Text = "Chỉ hiện người dùng script:"
    Note.TextColor3 = Color3.fromRGB(200, 150, 150)
    Note.Font = Enum.Font.Gotham
    Note.TextSize = 10
    Note.TextXAlignment = Enum.TextXAlignment.Left

    local PlayerListScroll = Instance.new("ScrollingFrame", AdminFrame)
    PlayerListScroll.Size = UDim2.new(1, -20, 1, -100)
    PlayerListScroll.Position = UDim2.new(0, 10, 0, 65)
    PlayerListScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    PlayerListScroll.BorderSizePixel = 0
    PlayerListScroll.ScrollBarThickness = 4
    Instance.new("UICorner", PlayerListScroll).CornerRadius = UDim.new(0, 8)
    Instance.new("UIListLayout", PlayerListScroll).Padding = UDim.new(0, 4)

    local ActiveChatters = {}
    local SelectedPlayer = nil

    -- Lắng nghe tin nhắn để đưa tên vào danh sách
    CHAT_REMOTE.OnClientEvent:Connect(function(action, senderName)
        if action == "MSG" and senderName ~= L.Name then
            if not ActiveChatters[senderName] then
                ActiveChatters[senderName] = true
                
                local Btn = Instance.new("TextButton", PlayerListScroll)
                Btn.Size = UDim2.new(1, -10, 0, 30)
                Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                Btn.Text = "  " .. senderName
                Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                Btn.Font = Enum.Font.GothamBold
                Btn.TextSize = 12
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                
                Btn.MouseButton1Click:Connect(function()
                    SelectedPlayer = senderName
                    for _, b in pairs(PlayerListScroll:GetChildren()) do
                        if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end
                    end
                    Btn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
                end)
            end
        end
    end)

    -- Nút chức năng
    local function CreateAdminBtn(text, pos, color, actionType)
        local Btn = Instance.new("TextButton", AdminFrame)
        Btn.Size = UDim2.new(0.3, -6, 0, 30)
        Btn.Position = pos
        Btn.BackgroundColor3 = color
        Btn.Text = text
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 11
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        Btn.MouseButton1Click:Connect(function()
            if not SelectedPlayer then return end
            if actionType == "BAN" then
                CHAT_REMOTE:FireServer("BAN", SelectedPlayer, "Vi phạm quy định")
            elseif actionType == "UNBAN" then
                CHAT_REMOTE:FireServer("UNBAN", SelectedPlayer)
            end
        end)
    end

    CreateAdminBtn("Ban Chat", UDim2.new(0, 10, 1, -40), Color3.fromRGB(200, 40, 40), "BAN")
    CreateAdminBtn("Unban Chat", UDim2.new(0.35, 0, 1, -40), Color3.fromRGB(40, 200, 80), "UNBAN")

    AdminBtn.MouseButton1Click:Connect(function() AdminFrame.Visible = not AdminFrame.Visible end)
    AdminCloseBtn.MouseButton1Click:Connect(function() AdminFrame.Visible = false end)
else
    print("[Dark Chat] Bạn là người dùng thường. Ẩn Admin Panel.")
end

print("[Khanh Beo] Dark Chat V5 Loaded!")
