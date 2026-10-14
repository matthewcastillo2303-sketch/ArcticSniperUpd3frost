--[[
ARCTIC SNIPER V2 — FROST UI
UI-only demo. Scanner, code preview, sample feed, and Discord message preview
are local demonstrations only; no live-game detection, code redemption, or webhook calls.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
if not player then return end
local pg = player:WaitForChild("PlayerGui")
local old = pg:FindFirstChild("ArcticSniperV2")
if old then old:Destroy() end

local C = {
    BG = Color3.fromRGB(5, 12, 22),
    PANEL = Color3.fromRGB(10, 23, 39),
    ROW = Color3.fromRGB(15, 34, 54),
    HOVER = Color3.fromRGB(22, 49, 73),
    BLUE = Color3.fromRGB(66, 190, 255),
    ICE = Color3.fromRGB(159, 229, 255),
    WHITE = Color3.fromRGB(239, 249, 255),
    MUTED = Color3.fromRGB(119, 157, 181),
    GREEN = Color3.fromRGB(104, 232, 180),
    BORDER = Color3.fromRGB(39, 108, 151),
    DEEP = Color3.fromRGB(9, 48, 76),
}
local logs, pages, nav = {}, {}, {}
local prefs = {scan=false, spam=false, feed=false, notifications=true, auto=3}

local function make(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end
local function corner(o, r) make("UICorner", {CornerRadius=UDim.new(0,r or 9)}, o) end
local function stroke(o, c, t)
    make("UIStroke", {Color=c or C.BORDER, Thickness=t or 1, Transparency=0.12}, o)
end
local function label(parent, txt, size, pos, fs, color, center)
    return make("TextLabel", {
        BackgroundTransparency=1, Text=txt or "", Size=size, Position=pos,
        Font=Enum.Font.Gotham, TextSize=fs or 11, TextColor3=color or C.WHITE,
        TextXAlignment=center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center, TextWrapped=true,
    }, parent)
end
local function button(parent, txt, size, pos, fn, bg)
    local b = make("TextButton", {
        Size=size, Position=pos, BackgroundColor3=bg or C.ROW,
        BorderSizePixel=0, Text=txt, TextColor3=C.WHITE, TextSize=11,
        Font=Enum.Font.GothamSemibold, AutoButtonColor=false,
    }, parent)
    corner(b, 8); stroke(b)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3=C.HOVER}):Play()
    end)
    b.MouseLeave:Connect(function()
        if b.Parent then TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3=bg or C.ROW}):Play() end
    end)
    b.Activated:Connect(function() if fn then fn() end end)
    return b
end
local function textbox(parent, placeholder, size, pos)
    local b = make("TextBox", {
        Size=size, Position=pos, BackgroundColor3=C.BG, BorderSizePixel=0,
        Text="", PlaceholderText=placeholder, PlaceholderColor3=C.MUTED,
        TextColor3=C.WHITE, TextSize=12, Font=Enum.Font.Gotham,
        ClearTextOnFocus=false, TextXAlignment=Enum.TextXAlignment.Left,
    }, parent)
    corner(b,8); stroke(b)
    make("UIPadding", {PaddingLeft=UDim.new(0,9), PaddingRight=UDim.new(0,7)}, b)
    return b
end

local gui = make("ScreenGui", {
    Name="ArcticSniperV2", ResetOnSpawn=false, IgnoreGuiInset=true,
    DisplayOrder=999, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
}, pg)

local main = make("Frame", {
    Name="Main", AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(570,450), BackgroundColor3=C.BG,
    BorderSizePixel=0, Active=true, ClipsDescendants=false,
}, gui)
corner(main,15); stroke(main,C.BORDER,1.5)
local scale = make("UIScale", {Scale=1}, main)
local function resize()
    local cam = workspace.CurrentCamera
    if cam then
        local v = cam.ViewportSize
        scale.Scale = math.clamp(math.min((v.X-18)/570, (v.Y-24)/450, 1), .42, 1)
    end
end
resize()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
end

local header = make("Frame", {
    Name="Header", Size=UDim2.new(1,0,0,58), BackgroundColor3=C.PANEL,
    BorderSizePixel=0, Active=true,
}, main)
corner(header,15)
make("Frame", {Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-14),
    BackgroundColor3=C.PANEL, BorderSizePixel=0}, header)
local logo = make("Frame", {Size=UDim2.fromOffset(34,34), Position=UDim2.fromOffset(12,11),
    BackgroundColor3=C.DEEP, BorderSizePixel=0}, header)
corner(logo,10); stroke(logo,C.BLUE,1.4)
label(logo,"❄",UDim2.fromScale(1,1),UDim2.new(),18,C.ICE,true)
label(header,"ARCTIC SNIPER",UDim2.new(0,190,0,21),UDim2.fromOffset(55,7),14,C.WHITE)
label(header,"V2  /  FROST EDITION",UDim2.new(0,190,0,15),UDim2.fromOffset(56,29),8,C.MUTED)
local dot = make("Frame", {Size=UDim2.fromOffset(7,7), Position=UDim2.new(1,-169,0,25),
    BackgroundColor3=C.GREEN, BorderSizePixel=0}, header)
corner(dot,9)
label(header,"UI DEMO",UDim2.fromOffset(58,18),UDim2.new(1,-157,0,19),8,C.MUTED)
local mini
button(header,"—",UDim2.fromOffset(27,27),UDim2.new(1,-62,0,15),function()
    main.Visible=false
    if mini then mini.Visible=true end
end,C.ROW)
local close = button(header,"×",UDim2.fromOffset(27,27),UDim2.new(1,-31,0,15),function() gui:Destroy() end,C.DEEP)
close.TextSize=17; close.TextColor3=C.ICE

-- Finger-friendly header dragging, with mouse support for Studio testing.
do
    local dragging, startPoint, startPos, inputKind = false, nil, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging=true; inputKind="touch"; startPoint=input.Position; startPos=main.Position
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging=true; inputKind="mouse"; startPoint=input.Position; startPos=main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local moved = (inputKind=="touch" and input.UserInputType==Enum.UserInputType.Touch)
            or (inputKind=="mouse" and input.UserInputType==Enum.UserInputType.MouseMovement)
        if moved then
            local d=input.Position-startPoint
            main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if (inputKind=="touch" and input.UserInputType==Enum.UserInputType.Touch)
            or (inputKind=="mouse" and input.UserInputType==Enum.UserInputType.MouseButton1) then
            dragging=false; inputKind=nil
        end
    end)
end

-- Floating AS button is itself draggable on touch devices.
mini = button(gui,"❄  AS",UDim2.fromOffset(72,36),UDim2.new(0,14,.5,-18),
    function() main.Visible=true; mini.Visible=false end,C.PANEL)
mini.Visible=false; stroke(mini,C.BLUE,1.4)
do
    local dragging, startPoint, startPos, inputKind = false, nil, nil, nil
    mini.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; inputKind="touch"; startPoint=input.Position; startPos=mini.Position
        elseif input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; inputKind="mouse"; startPoint=input.Position; startPos=mini.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local moved=(inputKind=="touch" and input.UserInputType==Enum.UserInputType.Touch)
            or (inputKind=="mouse" and input.UserInputType==Enum.UserInputType.MouseMovement)
        if moved then
            local d=input.Position-startPoint
            mini.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if (inputKind=="touch" and input.UserInputType==Enum.UserInputType.Touch)
            or (inputKind=="mouse" and input.UserInputType==Enum.UserInputType.MouseButton1) then
            dragging=false; inputKind=nil
        end
    end)
end

local sidebar = make("Frame", {
    Name="Sidebar", Size=UDim2.new(0,118,1,-70), Position=UDim2.fromOffset(8,63),
    BackgroundColor3=C.PANEL, BorderSizePixel=0,
}, main)
corner(sidebar,11)
label(sidebar,"NAVIGATION",UDim2.new(1,-16,0,20),UDim2.fromOffset(9,5),8,C.MUTED)
local content = make("Frame", {
    Name="Content", Size=UDim2.new(1,-139,1,-70), Position=UDim2.fromOffset(129,63),
    BackgroundTransparency=1,
}, main)
local names={"Home","Scanner","Redeemer","Brainrots","Discord","Settings","Activity Log"}

local function log(msg)
    table.insert(logs,1,os.date("%H:%M:%S").."  •  "..msg)
    if #logs>60 then table.remove(logs) end
    local p=pages["Activity Log"]
    local list=p and p:FindFirstChild("LogList")
    if list then
        for _,ch in ipairs(list:GetChildren()) do
            if ch:IsA("TextLabel") then ch:Destroy() end
        end
        for i=1,math.min(#logs,10) do
            label(list,logs[i],UDim2.new(1,-12,0,22),UDim2.fromOffset(6,(i-1)*24),9,C.MUTED)
        end
        list.CanvasSize=UDim2.new(0,0,0,math.min(#logs,10)*24)
    end
end
local function page(name)
    local p=make("ScrollingFrame",{
        Name=name.."Page",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BLUE,
        CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,
    },content)
    make("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},p)
    make("UIPadding",{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,8),
        PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,5)},p)
    pages[name]=p
    return p
end
local function card(parent,title,desc,h)
    h=h or 76
    local f=make("Frame",{Size=UDim2.new(1,-3,0,h),BackgroundColor3=C.PANEL,BorderSizePixel=0},parent)
    corner(f,10); stroke(f)
    label(f,title,UDim2.new(1,-18,0,20),UDim2.fromOffset(9,5),10,C.WHITE)
    if desc then label(f,desc,UDim2.new(1,-18,0,h-31),UDim2.fromOffset(9,27),8,C.MUTED) end
    return f
end
local function toggle(parent,title,sub,initial,fn)
    local r=make("Frame",{Size=UDim2.new(1,-3,0,46),BackgroundColor3=C.ROW,BorderSizePixel=0},parent)
    corner(r,9); stroke(r)
    label(r,title,UDim2.new(1,-76,0,18),UDim2.fromOffset(9,4),9,C.WHITE)
    if sub then label(r,sub,UDim2.new(1,-76,0,13),UDim2.fromOffset(9,23),7,C.MUTED) end
    local on=initial==true
    local track=make("TextButton",{Size=UDim2.fromOffset(40,22),Position=UDim2.new(1,-49,.5,-11),
        BackgroundColor3=on and C.BLUE or C.DEEP,BorderSizePixel=0,Text="",AutoButtonColor=false},r)
    corner(track,20)
    local knob=make("Frame",{Size=UDim2.fromOffset(14,14),
        Position=on and UDim2.new(1,-18,.5,-7) or UDim2.fromOffset(4,4),
        BackgroundColor3=C.WHITE,BorderSizePixel=0},track)
    corner(knob,10)
    track.Activated:Connect(function()
        on=not on
        track.BackgroundColor3=on and C.BLUE or C.DEEP
        TweenService:Create(knob,TweenInfo.new(.12),{
            Position=on and UDim2.new(1,-18,.5,-7) or UDim2.fromOffset(4,4)
        }):Play()
        if fn then fn(on) end
    end)
    return r
end
local function stepper(parent,title,sub,values,index,fn)
    local r=make("Frame",{Size=UDim2.new(1,-3,0,47),BackgroundColor3=C.ROW,BorderSizePixel=0},parent)
    corner(r,9); stroke(r)
    label(r,title,UDim2.new(.44,0,0,17),UDim2.fromOffset(9,4),9,C.WHITE)
    if sub then label(r,sub,UDim2.new(.44,0,0,12),UDim2.fromOffset(9,24),7,C.MUTED) end
    index=math.clamp(index or 1,1,#values)
    local controls=make("Frame",{Size=UDim2.new(.52,-4,0,27),Position=UDim2.new(.47,0,.5,-13),
        BackgroundColor3=C.PANEL,BorderSizePixel=0},r)
    corner(controls,7)
    local value=label(controls,tostring(values[index]),UDim2.new(1,-48,1,0),UDim2.fromOffset(24,0),9,C.WHITE,true)
    local function set(i)
        index=math.clamp(i,1,#values); value.Text=tostring(values[index])
        if fn then fn(values[index]) end
    end
    button(controls,"−",UDim2.fromOffset(20,21),UDim2.fromOffset(3,3),function() set(index-1) end,C.DEEP)
    button(controls,"+",UDim2.fromOffset(20,21),UDim2.new(1,-23,0,3),function() set(index+1) end,C.BLUE)
end
local function show(name)
    for n,p in pairs(pages) do p.Visible=n==name end
    for n,b in pairs(nav) do
        b.BackgroundColor3=n==name and C.DEEP or C.PANEL
        b.TextColor3=n==name and C.ICE or C.MUTED
    end
end
local icons={Home="⌂",Scanner="⌕",Redeemer="◇",Brainrots="✦",Discord="◉",Settings="⚙",["Activity Log"]="≡"}
for i,n in ipairs(names) do
    local b=button(sidebar,icons[n].."   "..n,UDim2.new(1,-10,0,31),
        UDim2.fromOffset(5,30+(i-1)*35),function() show(n) end,C.PANEL)
    b.TextXAlignment=Enum.TextXAlignment.Left
    b.TextSize=9; b.TextColor3=C.MUTED
    nav[n]=b
end
label(sidebar,"FROST • V2",UDim2.new(1,-14,0,16),UDim2.new(0,7,1,-22),7,C.MUTED)

do
    local p=page("Home")
    local w=card(p,"WELCOME TO ARCTIC","Compact frost interface • ice-blue edition.",78)
    label(w,"●  SYSTEM READY",UDim2.new(1,-18,0,15),UDim2.new(0,9,1,-19),8,C.GREEN)
    local s=card(p,"QUICK STATUS",nil,62)
    label(s,"Scanner: DEMO",UDim2.new(.5,-8,0,18),UDim2.fromOffset(9,29),8,C.ICE)
    label(s,"Feed: TEST MODE",UDim2.new(.5,-8,0,18),UDim2.new(.5,0,0,29),8,C.ICE)
    local q=card(p,"QUICK OPEN",nil,60)
    button(q,"SCANNER",UDim2.new(.48,-3,0,24),UDim2.fromOffset(8,29),function() show("Scanner") end,C.DEEP)
    button(q,"SPAWN FEED",UDim2.new(.48,-3,0,24),UDim2.new(.52,0,0,29),function() show("Brainrots") end,C.DEEP)
    card(p,"ABOUT","UI demo only; sample controls do not connect to live game events.",57)
end
do
    local p=page("Scanner")
    card(p,"SCAN ANNOUNCEMENT TEXT","Paste text to check for phrases like “use code” or “the code is”.",63)
    local box=textbox(p,"Paste announcement text...",UDim2.new(1,-3,0,36),UDim2.new()); box.LayoutOrder=2
    local r=card(p,"SCAN RESULT",nil,70); r.LayoutOrder=3
    local status=label(r,"Waiting for a test scan.",UDim2.new(1,-16,0,18),UDim2.fromOffset(8,25),8,C.MUTED)
    button(r,"TEST SCAN",UDim2.fromOffset(88,23),UDim2.new(1,-97,1,-28),function()
        local v=string.lower(box.Text)
        if v=="" then status.Text="Enter text first."; status.TextColor3=C.ICE; log("Scanner input empty"); return end
        local found=string.find(v,"use code",1,true) or string.find(v,"the code is",1,true) or string.find(v,"code:",1,true)
        status.Text=found and "Potential code phrase detected." or "No phrase detected."
        status.TextColor3=found and C.GREEN or C.MUTED
        log(found and "Demo scanner found a phrase" or "Demo scan completed")
    end,C.DEEP)
    toggle(p,"Scan announcements","UI preference only",prefs.scan,function(v)
        prefs.scan=v; log("Scan preference "..(v and "enabled" or "disabled"))
    end)
end
do
    local p=page("Redeemer")
    card(p,"CODE PREVIEW","Checks text format only; does not redeem anything.",63)
    local box=textbox(p,"Enter a code...",UDim2.new(1,-3,0,36),UDim2.new()); box.LayoutOrder=2
    local r=card(p,"RESULT",nil,70); r.LayoutOrder=3
    local status=label(r,"No code checked yet.",UDim2.new(1,-16,0,18),UDim2.fromOffset(8,25),8,C.MUTED)
    button(r,"CHECK",UDim2.fromOffset(68,23),UDim2.new(1,-77,1,-28),function()
        local v=string.gsub(box.Text,"^%s*(.-)%s*$","%1")
        if v=="" then status.Text="Enter a code first."; status.TextColor3=C.ICE
        elseif #v>64 then status.Text="Code is too long."; status.TextColor3=C.ICE
        elseif string.find(v,"%s") then status.Text="Code contains spaces."; status.TextColor3=C.ICE
        else status.Text="Format looks valid: "..v; status.TextColor3=C.GREEN end
        log("Code format preview checked")
    end,C.DEEP)
    toggle(p,"Spam redeem","Demo preference only",prefs.spam,function(v)
        prefs.spam=v; log("Spam redeem preference changed")
    end)
    stepper(p,"Auto-submit value","UI selector only",{1,2,3,4,5},3,function(v)
        prefs.auto=v; log("Displayed selector set to "..v)
    end)
end
do
    local p=page("Brainrots")
    card(p,"SPAWN FEED","Tap to create a sample notification.",63)
    local r=card(p,"LATEST EVENT",nil,78)
    local status=label(r,"Waiting for a test event.",UDim2.new(1,-16,0,18),UDim2.fromOffset(8,25),8,C.MUTED)
    button(r,"TEST SPAWN",UDim2.fromOffset(95,23),UDim2.new(1,-104,1,-28),function()
        status.Text="TEST • Sample Brainrot appeared"; status.TextColor3=C.GREEN
        log("Sample spawn event created")
    end,C.DEEP)
    toggle(p,"Spawn notifications","Demo preference only",prefs.feed,function(v)
        prefs.feed=v; log("Spawn feed preference changed")
    end)
    card(p,"LIVE DETECTION","This UI does not inspect live game internals.",54)
end
do
    local p=page("Discord")
    card(p,"MESSAGE PREVIEW","Preview text for your own authorized bot/backend.",63)
    local box=textbox(p,"Type sample notification...",UDim2.new(1,-3,0,36),UDim2.new()); box.LayoutOrder=2
    local r=card(p,"PREVIEW",nil,82); r.LayoutOrder=3
    local status=label(r,"No message created.",UDim2.new(1,-16,0,28),UDim2.fromOffset(8,25),8,C.MUTED)
    button(r,"PREVIEW",UDim2.fromOffset(72,23),UDim2.new(1,-81,1,-28),function()
        status.Text="❄ ARCTIC SNIPER • "..(box.Text~="" and box.Text or "Sample notification")
        status.TextColor3=C.ICE; log("Message preview created")
    end,C.DEEP)
    card(p,"CONNECTION","Preview only; no Discord message or webhook is sent.",54)
end
do
    local p=page("Settings")
    card(p,"PERSONALIZATION","Settings for this interface session.",57)
    toggle(p,"Notifications","UI preference only",prefs.notifications,function(v)
        prefs.notifications=v; log("Notification preference changed")
    end)
    stepper(p,"Panel scale","Display setting",{70,80,90,100},4,function(v)
        scale.Scale=math.min(v/100,1); log("Panel scale set to "..v.."%")
    end)
    card(p,"WINDOW CONTROLS","Drag the top bar to move the panel. Minimize to show the AS reopen button.",61)
end
do
    local p=page("Activity Log")
    local f=card(p,"ACTIVITY LOG",nil,300)
    local list=make("ScrollingFrame",{Name="LogList",Size=UDim2.new(1,-16,1,-62),
        Position=UDim2.fromOffset(8,27),BackgroundColor3=C.BG,BorderSizePixel=0,
        ScrollBarThickness=3,ScrollBarImageColor3=C.BLUE,CanvasSize=UDim2.new()},f)
    corner(list,8); stroke(list,C.BORDER,.8)
    button(f,"CLEAR LOG",UDim2.fromOffset(80,22),UDim2.new(1,-89,1,-27),function()
        table.clear(logs)
        for _,ch in ipairs(list:GetChildren()) do if ch:IsA("TextLabel") then ch:Destroy() end end
        list.CanvasSize=UDim2.new()
    end,C.DEEP)
end

-- Light, occasional frost glints rather than a constant snowstorm.
task.spawn(function()
    while gui.Parent do
        if main.Visible then
            local flake=make("TextLabel",{BackgroundTransparency=1,Text="✦",TextColor3=C.ICE,
                TextTransparency=.78,TextSize=math.random(8,12),Font=Enum.Font.Gotham,
                Size=UDim2.fromOffset(14,14),Position=UDim2.new(math.random(5,95)/100,0,-.04,0),
                ZIndex=10},main)
            local tw=TweenService:Create(flake,TweenInfo.new(math.random(6,9),Enum.EasingStyle.Linear),{
                Position=UDim2.new(flake.Position.X.Scale+math.random(-4,4)/100,0,1.05,0),
                TextTransparency=1,
            })
            tw:Play()
            tw.Completed:Connect(function() if flake.Parent then flake:Destroy() end end)
        end
        task.wait(1.1)
    end
end)

log("Arctic Sniper V2 Frost UI loaded")
show("Home")
