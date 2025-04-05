-- Fixed Remote Spy Script (inspired by SimpleSpy)
-- Features:
-- 1. Intercepts RemoteEvent/RemoteFunction calls
-- 2. Logs calls and displays arguments in a simple UI
-- 3. Allows you to re‑execute the remote with custom arguments
-- 4. UI toggle via RightShift

local RemoteSpy = {}
RemoteSpy.Enabled = true
RemoteSpy.Logs = {}
RemoteSpy.Selected = nil
RemoteSpy.UIVisible = true

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RemoteSpyGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Remote Spy"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 16
CloseButton.Parent = TitleBar

-- Log List (left panel)
local LogList = Instance.new("ScrollingFrame")
LogList.Name = "LogList"
LogList.Size = UDim2.new(0.5, -10, 1, -40)
LogList.Position = UDim2.new(0, 5, 0, 35)
LogList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LogList.BorderSizePixel = 1
LogList.BorderColor3 = Color3.fromRGB(50, 50, 50)
LogList.ScrollBarThickness = 5
LogList.CanvasSize = UDim2.new(0, 0, 0, 0)
LogList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Name = "UIListLayout"
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = LogList

-- Details Panel (right panel)
local DetailsPanel = Instance.new("Frame")
DetailsPanel.Name = "DetailsPanel"
DetailsPanel.Size = UDim2.new(0.5, -10, 1, -40)
DetailsPanel.Position = UDim2.new(0.5, 5, 0, 35)
DetailsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DetailsPanel.BorderSizePixel = 1
DetailsPanel.BorderColor3 = Color3.fromRGB(50, 50, 50)
DetailsPanel.Parent = MainFrame

local RemoteInfo = Instance.new("TextLabel")
RemoteInfo.Name = "RemoteInfo"
RemoteInfo.Size = UDim2.new(1, -10, 0, 30)
RemoteInfo.Position = UDim2.new(0, 5, 0, 5)
RemoteInfo.BackgroundTransparency = 1
RemoteInfo.TextColor3 = Color3.new(1, 1, 1)
RemoteInfo.TextSize = 14
RemoteInfo.Font = Enum.Font.SourceSans
RemoteInfo.Text = "Select a remote to view details"
RemoteInfo.TextXAlignment = Enum.TextXAlignment.Left
RemoteInfo.TextWrapped = true
RemoteInfo.Parent = DetailsPanel

local ArgsBox = Instance.new("TextBox")
ArgsBox.Name = "ArgsBox"
ArgsBox.Size = UDim2.new(1, -10, 0, 100)
ArgsBox.Position = UDim2.new(0, 5, 0, 40)
ArgsBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ArgsBox.BorderSizePixel = 1
ArgsBox.BorderColor3 = Color3.fromRGB(60, 60, 60)
ArgsBox.TextColor3 = Color3.new(1, 1, 1)
ArgsBox.TextSize = 14
ArgsBox.Font = Enum.Font.Code
ArgsBox.Text = "-- Enter arguments as Lua table:\n-- {1, 2, \"string\", ...}"
ArgsBox.TextXAlignment = Enum.TextXAlignment.Left
ArgsBox.TextYAlignment = Enum.TextYAlignment.Top
ArgsBox.ClearTextOnFocus = false
ArgsBox.MultiLine = true
ArgsBox.Parent = DetailsPanel

local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Name = "ExecuteButton"
ExecuteButton.Size = UDim2.new(1, -10, 0, 30)
ExecuteButton.Position = UDim2.new(0, 5, 0, 145)
ExecuteButton.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
ExecuteButton.BorderSizePixel = 1
ExecuteButton.BorderColor3 = Color3.fromRGB(70, 120, 70)
ExecuteButton.Text = "Execute Remote"
ExecuteButton.TextColor3 = Color3.new(1, 1, 1)
ExecuteButton.Font = Enum.Font.SourceSansBold
ExecuteButton.TextSize = 16
ExecuteButton.Parent = DetailsPanel

local ArgumentsInfo = Instance.new("TextLabel")
ArgumentsInfo.Name = "ArgumentsInfo"
ArgumentsInfo.Size = UDim2.new(1, -10, 0, 25)
ArgumentsInfo.Position = UDim2.new(0, 5, 0, 180)
ArgumentsInfo.BackgroundTransparency = 1
ArgumentsInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
ArgumentsInfo.TextSize = 14
ArgumentsInfo.Font = Enum.Font.SourceSans
ArgumentsInfo.Text = "Original Arguments:"
ArgumentsInfo.TextXAlignment = Enum.TextXAlignment.Left
ArgumentsInfo.Parent = DetailsPanel

local ArgsDisplay = Instance.new("TextBox")
ArgsDisplay.Name = "ArgsDisplay"
ArgsDisplay.Size = UDim2.new(1, -10, 1, -210)
ArgsDisplay.Position = UDim2.new(0, 5, 0, 205)
ArgsDisplay.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ArgsDisplay.BorderSizePixel = 1
ArgsDisplay.BorderColor3 = Color3.fromRGB(60, 60, 60)
ArgsDisplay.TextColor3 = Color3.fromRGB(200, 200, 200)
ArgsDisplay.TextSize = 14
ArgsDisplay.Font = Enum.Font.Code
ArgsDisplay.Text = ""
ArgsDisplay.TextXAlignment = Enum.TextXAlignment.Left
ArgsDisplay.TextYAlignment = Enum.TextYAlignment.Top
ArgsDisplay.TextEditable = false
ArgsDisplay.MultiLine = true
ArgsDisplay.Parent = DetailsPanel

-- Function: Create a log entry for a remote call
local function CreateLogItem(remote, remoteType, args)
    local item = Instance.new("TextButton")
    item.Name = "LogItem_" .. tostring(#RemoteSpy.Logs + 1)
    item.Size = UDim2.new(1, -5, 0, 25)
    item.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    item.BorderSizePixel = 1
    item.BorderColor3 = Color3.fromRGB(60, 60, 60)
    
    local remoteColor = (remoteType == "RemoteEvent") and Color3.fromRGB(120, 160, 255) or Color3.fromRGB(255, 160, 120)
    item.TextColor3 = remoteColor
    item.Font = Enum.Font.SourceSans
    item.TextSize = 14
    item.Text = remote.Name .. " (" .. remoteType .. ")"
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.TextTruncate = Enum.TextTruncate.AtEnd
    item.Parent = LogList
    
    local logData = { Remote = remote, RemoteType = remoteType, Args = args }
    table.insert(RemoteSpy.Logs, logData)
    local logIndex = #RemoteSpy.Logs
    
    item.MouseButton1Click:Connect(function()
        RemoteSpy.Selected = logIndex
        RemoteInfo.Text = remote.Name .. " (" .. remoteType .. ")"
        local argsString = ""
        for i, arg in pairs(args) do
            if type(arg) == "function" then
                argsString = argsString .. "function() ... end, "
            elseif type(arg) == "table" then
                local tstr = "{"
                for k, v in pairs(arg) do
                    if type(k) == "string" then
                        tstr = tstr .. k .. " = "
                    end
                    if type(v) == "string" then
                        tstr = tstr .. "\"" .. v .. "\", "
                    else
                        tstr = tstr .. tostring(v) .. ", "
                    end
                end
                argsString = argsString .. tstr .. "}, "
            elseif type(arg) == "string" then
                argsString = argsString .. "\"" .. arg .. "\", "
            else
                argsString = argsString .. tostring(arg) .. ", "
            end
        end
        ArgsDisplay.Text = argsString
        
        -- Prepare default execution arguments
        local defaultArgs = "{"
        for i, arg in pairs(args) do
            if type(arg) == "string" then
                defaultArgs = defaultArgs .. "\"" .. arg .. "\", "
            elseif type(arg) == "table" then
                defaultArgs = defaultArgs .. "{}, "
            elseif type(arg) ~= "function" then
                defaultArgs = defaultArgs .. tostring(arg) .. ", "
            end
        end
        defaultArgs = defaultArgs .. "}"
        ArgsBox.Text = defaultArgs
    end)
    
    -- Update canvas size
    LogList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    return logData
end

-- Hook __namecall (inspired by SimpleSpy)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if RemoteSpy.Enabled and (method == "FireServer" or method == "InvokeServer") then
        local remoteType = (method == "FireServer") and "RemoteEvent" or "RemoteFunction"
        if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
            CreateLogItem(self, remoteType, args)
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- UI Functionality
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
    RemoteSpy.UIVisible = false
end)

ExecuteButton.MouseButton1Click:Connect(function()
    if RemoteSpy.Selected then
        local logData = RemoteSpy.Logs[RemoteSpy.Selected]
        local remote = logData.Remote
        local remoteType = logData.RemoteType
        local argString = ArgsBox.Text
        local args = {}
        local success, parsedArgs = pcall(function() return loadstring("return " .. argString)() end)
        if success and type(parsedArgs) == "table" then
            args = parsedArgs
        else
            ArgsDisplay.Text = "Error parsing arguments. Check your syntax."
            return
        end
        
        if remoteType == "RemoteEvent" then
            remote:FireServer(table.unpack(args))
        elseif remoteType == "RemoteFunction" then
            spawn(function()
                local result = remote:InvokeServer(table.unpack(args))
                ArgsDisplay.Text = "Result: " .. tostring(result)
            end)
        end
    end
end)

-- Toggle UI with RightShift key
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        RemoteSpy.UIVisible = not RemoteSpy.UIVisible
        ScreenGui.Enabled = RemoteSpy.UIVisible
    end
end)

print(".gg/getvxlo for more sigma fixes")
