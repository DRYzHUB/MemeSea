-- Mango Cat Hub | Meme Sea
-- UI library carregada do repositório fornecido e com os nomes da interface personalizados.

local LibrarySource = game:HttpGet("https://raw.githubusercontent.com/bloxfruitsnokey/Banana/refs/heads/main/Banana/ui.luau")
LibrarySource = LibrarySource
    :gsub("Nousigi Hub", "Mango Cat Hub")
    :gsub("Nousigi", "Mango")
    :gsub("Nousigi Hub", "Mango Cat Hub")

local Library = loadstring(LibrarySource)()

local _wait = task.wait
repeat _wait() until game:IsLoaded()
local _env = getgenv and getgenv() or {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local rs_Monsters = ReplicatedStorage:WaitForChild("MonsterSpawn")
local Modules = ReplicatedStorage:WaitForChild("ModuleScript")
local OtherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local Monsters = workspace:WaitForChild("Monster")

local MQuestSettings = require(Modules:WaitForChild("Quest_Settings"))
local MSetting = require(Modules:WaitForChild("Setting"))

local NPCs = workspace:WaitForChild("NPCs")
local Raids = workspace:WaitForChild("Raids")
local Location = workspace:WaitForChild("Location")
local Region = workspace:WaitForChild("Region")
local Island = workspace:WaitForChild("Island")

local Quests_Npc = NPCs:WaitForChild("Quests_Npc")
local EnemyLocation = Location:WaitForChild("Enemy_Location")
local QuestLocation = Location:WaitForChild("QuestLocaion")

local Items = Player:WaitForChild("Items")
local QuestFolder = Player:WaitForChild("QuestFolder")
local Ability = Player:WaitForChild("Ability")
local PlayerData = Player:WaitForChild("PlayerData")
local PlayerLevel = PlayerData:WaitForChild("Level")

local sethiddenproperty = sethiddenproperty or (function()end)

local CFrame_Angles = CFrame.Angles
local CFrame_new = CFrame.new
local Vector3_new = Vector3.new

local _huge = math.huge

task.spawn(function()
  if not _env.LoadedHideUsername then
    _env.LoadedHideUsername = true
    local Label = Player.PlayerGui.MainGui.PlayerName
    
    local function Update()
      local Level = PlayerLevel.Value
      local IsMax = Level >= MSetting.Setting.MaxLevel
      Label.Text = ("%s • Lv. %i%s"):format("Anonymous", Level, IsMax and " (Max)" or "")
    end
    
    Label:GetPropertyChangedSignal("Text"):Connect(Update)Update()
  end
end)

local Loaded, Funcs, Folders = {}, {}, {} do
  Loaded.ItemsPrice = {
    Aura = function()
      return Funcs:GetMaterial("Meme Cube") > 0 and Funcs:GetData("Money") >= 10000000 -- 1x Meme Cube, $10.000.000
    end,
    FlashStep = function()
      return Funcs:GetData("Money") >= 100000 -- $100.000
    end,
    Instinct = function()
      return Funcs:GetData("Money") >= 2500000 -- $2.500.000
    end
  }
  Loaded.Shop = {
    {"Weapons", {
      {"Buy Katana", "$5.000 Money", {"Weapon_Seller", "Doge"}},
      {"Buy Hanger", "$25.000 Money", {"Weapon_Seller", "Hanger"}},
      {"Buy Flame Katana", "1x Cheems Cola and $50.000", {"Weapon_Seller", "Cheems"}},
      {"Buy Banana", "1x Cat Food and $350.000", {"Weapon_Seller", "Smiling Cat"}},
      {"Buy Bonk", "5x Money Bags and $1.000.000", {"Weapon_Seller", "Meme Man"}},
      {"Buy Pumpkin", "1x Nugget Man and $3.500.000", {"Weapon_Seller", "Gravestone"}},
      {"Buy Popcat", "10.000 Pops Clicker", {"Weapon_Seller", "Ohio Popcat"}}
    }},
    {"Ability", {
      {"Buy Flash Step", "$100.000 Money", {"Ability_Teacher", "Giga Chad"}},
      {"Buy Instinct", "$2.500.000 Money", {"Ability_Teacher", "Nugget Man"}},
      {"Buy Aura", "1x Meme Cube and $10.000.000", {"Ability_Teacher", "Aura Master"}}
    }},
    {"Fighting Style", {
      {"Buy Combat", "$0 Money", {"FightingStyle_Teacher", "Maxwell"}},
      {"Buy Baller", "10x Balls and $10.000.000", {"FightingStyle_Teacher", "Baller"}}
    }}
  }
  Loaded.WeaponsList = { "Fight", "Power", "Weapon" }
  Loaded.EnemeiesList = {}
  Loaded.EnemiesSpawns = {}
  Loaded.EnemiesQuests = {}
  Loaded.Islands = {}
  Loaded.Quests = {}
  
  local function RedeemCode(Code)
    return OtherEvent.MainEvents.Code:InvokeServer(Code)
  end
  
  Funcs.RAllCodes = function(self)
    if Modules:FindFirstChild("CodeList") then
      local List = require(Modules.CodeList)
      for Code, Info in pairs(type(List) == "table" and List or {}) do
        if type(Code) == "string" and type(Info) == "table" and Info.Status then RedeemCode(Code) end
      end
    end
  end
  
  Funcs.GetPlayerLevel = function(self)
    return PlayerLevel.Value
  end
  
  Funcs.GetCurrentQuest = function(self)
    for _,Quest in pairs(Loaded.Quests) do
      if Quest.Level <= self:GetPlayerLevel() and not Quest.RaidBoss and not Quest.SpecialQuest then
        return Quest
      end
    end
  end
  
  Funcs.CheckQuest = function(self)
    for _,v in ipairs(QuestFolder:GetChildren()) do
      if v.Target.Value ~= "None" then
        return v
      end
    end
  end
  
  Funcs.VerifySword = function(self, SName)
    local Swords = Items.Weapon
    return Swords:FindFirstChild(SName) and Swords[SName].Value > 0
  end
  
  Funcs.VerifyAccessory = function(self, AName)
    local Accessories = Items.Accessory
    return Accessories:FindFirstChild(AName) and Accessories[AName].Value > 0
  end
  
  Funcs.GetMaterial = function(self, MName)
    local ItemStorage = Items.ItemStorage
    return ItemStorage:FindFirstChild(MName) and ItemStorage[MName].Value or 0
  end
  
  Funcs.AbilityUnlocked = function(self, Ablt)
    return Ability:FindFirstChild(Ablt) and Ability[Ablt].Value
  end
  
  Funcs.CanBuy = function(self, Item)
    if Loaded.ItemsPrice[Item] then
      return Loaded.ItemsPrice[Item]()
    end
    return false
  end
  
  Funcs.GetData = function(self, Data)
    return PlayerData:FindFirstChild(Data) and PlayerData[Data].Value or 0
  end
  
  for Npc,Quest in pairs(MQuestSettings) do
    if QuestLocation:FindFirstChild(Npc) then
      table.insert(Loaded.Quests, {
        RaidBoss = Quest.Raid_Boss,
        SpecialQuest = Quest.Special_Quest,
        QuestPos = QuestLocation[Npc].CFrame,
        EnemyPos = EnemyLocation[Quest.Target].CFrame,
        Level = Quest.LevelNeed,
        Enemy = Quest.Target,
        NpcName = Npc
      })
    end
  end
  
  table.sort(Loaded.Quests, function(a, b) return a.Level > b.Level end)
  for _,v in ipairs(Loaded.Quests) do
    table.insert(Loaded.EnemeiesList, v.Enemy)Loaded.EnemiesQuests[v.Enemy] = v.NpcName
  end
end

local Settings = Settings or {} do
  Settings.AutoStats_Points = 1
  Settings.BringMobs = true
  Settings.FarmDistance = 9
  Settings.ViewHitbox = false
  Settings.AntiAFK = true
  Settings.AutoHaki = true
  Settings.AutoClick = true
  Settings.ToolFarm = "Fight" -- [[ "Fight", "Power", "Weapon" ]]
  Settings.FarmCFrame = CFrame_new(0, Settings.FarmDistance, 0) * CFrame_Angles(math.rad(-90), 0, 0)
end

local function PlayerClick()
  local Char = Player.Character
  if Char then
    if Settings.AutoClick then
      VirtualUser:CaptureController()
      VirtualUser:Button1Down(Vector2.new(1e4, 1e4))
    end
    if Settings.AutoHaki and Char:FindFirstChild("AuraColor_Folder") and Funcs:AbilityUnlocked("Aura") then
      if #Char.AuraColor_Folder:GetChildren() < 1 then
        OtherEvent.MainEvents.Ability:InvokeServer("Aura")
      end
    end
  end
end

local function IsAlive(Char)
  local Hum = Char and Char:FindFirstChild("Humanoid")
  return Hum and Hum.Health > 0
end

local function GetNextEnemie(EnemieName)
  for _,v in ipairs(Monsters:GetChildren()) do
    if (not EnemieName or v.Name == EnemieName) and IsAlive(v) then
      return v
    end
  end
  return false
end

local function GoTo(CFrame, Move)
  local Char = Player.Character
  if IsAlive(Char) then
    return Move and ( Char:MoveTo(CFrame.p) or true ) or Char:SetPrimaryPartCFrame(CFrame)
  end
end

local function EquipWeapon()
  local Backpack, Char = Player:FindFirstChild("Backpack"), Player.Character
  if IsAlive(Char) and Backpack then
    for _,v in ipairs(Backpack:GetChildren()) do
      if v:IsA("Tool") and v.ToolTip:find(Settings.ToolFarm) then
        Char.Humanoid:EquipTool(v)
      end
    end
  end
end

local function BringMobsTo(_Enemie, CFrame, SBring)
  for _,v in ipairs(Monsters:GetChildren()) do
    if (SBring or v.Name == _Enemie) and IsAlive(v) then
      local PP, Hum = v.PrimaryPart, v.Humanoid
      if PP and (PP.Position - CFrame.p).Magnitude < 500 then
        Hum.WalkSpeed = 0
        Hum:ChangeState(14)
        PP.CFrame = CFrame
        PP.CanCollide = false
        PP.Transparency = Settings.ViewHitbox and 0.8 or 1
        PP.Size = Vector3.new(50, 50, 50)
      end
    end
  end
  return pcall(sethiddenproperty, Player, "SimulationRadius", _huge)
end

local function KillMonster(_Enemie, SBring)
  local Enemy = typeof(_Enemie) == "Instance" and _Enemie or GetNextEnemie(_Enemie)
  if IsAlive(Enemy) and Enemy.PrimaryPart then
    GoTo(Enemy.PrimaryPart.CFrame * Settings.FarmCFrame)EquipWeapon()
    if not Enemy:FindFirstChild("Reverse_Mark") then PlayerClick() end
    if Settings.BringMobs then BringMobsTo(_Enemie, Enemy.PrimaryPart.CFrame, SBring) end
    return true
  end
end

local function TakeQuest(QuestName, CFrame, Wait)
  local QuestGiver = Quests_Npc:FindFirstChild(QuestName)
  if QuestGiver and Player:DistanceFromCharacter(QuestGiver.WorldPivot.p) < 5 then
    return fireproximityprompt(QuestGiver.Block.QuestPrompt), _wait(Wait or 0.1)
  end
  GoTo(CFrame or QuestLocation[QuestName].CFrame)
end

local function ClearQuests(Ignore)
  for _,v in ipairs(QuestFolder:GetChildren()) do
    if v.QuestGiver.Value ~= Ignore and v.Target.Value ~= "None" then
      OtherEvent.QuestEvents.Quest:FireServer("Abandon_Quest", { QuestSlot = v.Name })
    end
  end
end

local function GetRaidEnemies()
  for _,v in ipairs(Monsters:GetChildren()) do
    if v:GetAttribute("Raid_Enemy") and IsAlive(v) then
      return v
    end
  end
end

local function GetRaidMap()
  for _,v in ipairs(Raids:GetChildren()) do
    if v.Joiners:FindFirstChild(Player.Name) then
      return v
    end
  end
end

local function VerifyQuest(QName)
  local Quest = Funcs:CheckQuest()
  return Quest and Quest.QuestGiver.Value == QName
end

_env.FarmFuncs = {
  {"_Floppa Sword", (function()
    if not Funcs:VerifySword("Floppa") then
      if VerifyQuest("Cool Floppa Quest") then
        GoTo(CFrame_new(794, -31, -440))
        fireproximityprompt(Island.FloppaIsland["Lava Floppa"].ClickPart.ProximityPrompt)
      else
        ClearQuests("Cool Floppa Quest")
        TakeQuest("Cool Floppa Quest", CFrame_new(758, -31, -424))
      end
      return true
    end
  end)},
  {"Meme Beast", (function()
    local MemeBeast = Monsters:FindFirstChild("Meme Beast") or rs_Monsters:FindFirstChild("Meme Beast")
    if MemeBeast then
      GoTo(MemeBeast.WorldPivot)EquipWeapon()PlayerClick()
      return true
    end
  end)},
  {"Lord Sus", (function()
    local LordSus = Monsters:FindFirstChild("Lord Sus") or rs_Monsters:FindFirstChild("Lord Sus")
    if LordSus then
      if not VerifyQuest("Floppa Quest 32") and Funcs:GetPlayerLevel() >= 1550 then
        ClearQuests("Floppa Quest 32")TakeQuest("Floppa Quest 32", nil, 1)
      else
        KillMonster(LordSus)
      end
      return true
    elseif Funcs:GetMaterial("Sussy Orb") > 0 then
      if Player:DistanceFromCharacter(Vector3_new(6644, -95, 4811)) < 5 then
        fireproximityprompt(Island.ForgottenIsland.Summon3.Summon.SummonPrompt)
      else GoTo(CFrame_new(6644, -95, 4811)) end
      return true
    end
  end)},
  {"Evil Noob", (function()
    local EvilNoob = Monsters:FindFirstChild("Evil Noob") or rs_Monsters:FindFirstChild("Evil Noob")
    if EvilNoob then
      if not VerifyQuest("Floppa Quest 29") and Funcs:GetPlayerLevel() >= 1400 then
        ClearQuests("Floppa Quest 29")TakeQuest("Floppa Quest 29", nil, 1)
      else
        KillMonster(EvilNoob)
      end
      return true
    elseif Funcs:GetMaterial("Noob Head") > 0 then
      if Player:DistanceFromCharacter(Vector3_new(-2356, -81, 3180)) < 5 then
        fireproximityprompt(Island.MoaiIsland.Summon2.Summon.SummonPrompt)
      else GoTo(CFrame_new(-2356, -81, 3180)) end
      return true
    end
  end)},
  {"Giant Pumpkin", (function()
    local Pumpkin = Monsters:FindFirstChild("Giant Pumpkin") or rs_Monsters:FindFirstChild("Giant Pumpkin")
    if Pumpkin then
      if not VerifyQuest("Floppa Quest 23") and Funcs:GetPlayerLevel() >= 1100 then
        ClearQuests("Floppa Quest 23")TakeQuest("Floppa Quest 23", nil, 1)
      else
        KillMonster(Pumpkin)
      end
      return true
    elseif Funcs:GetMaterial("Flame Orb") > 0 then
      if Player:DistanceFromCharacter(Vector3_new(-1180, -93, 1462)) < 5 then
        fireproximityprompt(Island.PumpkinIsland.Summon1.Summon.SummonPrompt)
      else GoTo(CFrame_new(-1180, -93, 1462)) end
      return true
    end
  end)},
  {"Race V2 Orb", (function()
    if Funcs:GetPlayerLevel() >= 500 then
      local Quest, Enemy = "Dancing Banana Quest", "Sogga"
      if VerifyQuest(Quest) then
        if KillMonster(Enemy) then else GoTo(EnemyLocation[Enemy].CFrame) end
      else ClearQuests(Quest)TakeQuest(Quest, CFrame_new(-2620, -80, -2001)) end
      return true
    end
  end)},
  {"Level Farm", (function()
    local Quest, QuestChecker = Funcs:GetCurrentQuest(), Funcs:CheckQuest()
    if Quest then
      if QuestChecker then
        local _QuestName = QuestChecker.QuestGiver.Value
        if _QuestName == Quest.NpcName then
          if KillMonster(Quest.Enemy) then else GoTo(Quest.EnemyPos) end
        else
          if KillMonster(QuestChecker.Target.Value) then else GoTo(QuestLocation[_QuestName].CFrame) end
        end
      else TakeQuest(Quest.NpcName) end
    end
    return true
  end)},
  {"Raid Farm", (function()
    if Funcs:GetPlayerLevel() >= 1000 then
      local RaidMap = GetRaidMap()
      if RaidMap then
        if RaidMap:GetAttribute("Starting") ~= 0 then
          OtherEvent.MiscEvents.StartRaid:FireServer("Start")_wait(1)
        else
          local Enemie = GetRaidEnemies()
          if Enemie then KillMonster(Enemie, true) else
            local Spawn = RaidMap:FindFirstChild("Spawn_Location")
            if Spawn then GoTo(Spawn.CFrame) end
          end
        end
      else
        local Raid = Region:FindFirstChild("RaidArea")
        if Raid then GoTo(CFrame_new(Raid.Position)) end
      end
      return true
    end
  end)},
  {"FS Enemie", (function()
    local Enemy = _env.SelecetedEnemie
    local Quest = Loaded.EnemiesQuests[Enemy]
    if VerifyQuest(Quest) or not _env["FS Take Quest"] then
      if KillMonster(Enemy) then else GoTo(EnemyLocation[Enemy].CFrame) end
    else ClearQuests(Quest)TakeQuest(Quest) end
    return true
  end)},
  {"Nearest Farm", (function() return KillMonster(GetNextEnemie()) end)}
}

if not _env.LoadedFarm then
  _env.LoadedFarm = true
  task.spawn(function()
    while _wait() do
      for _,f in _env.FarmFuncs do
        if _env[f[1]] then local s,r=pcall(f[2])if s and r then break end;end
      end
    end
  end)
end

local Window = Library:CreateWindow({
    Title = "Mango Cat Hub",
    Desc = "- Meme Sea",
})

local Tabs = {
    Discord = Window:AddTab("Discord"),
    MainFarm = Window:AddTab("Farm"),
    Items = Window:AddTab("Items"),
    Stats = Window:AddTab("Stats"),
    Teleport = Window:AddTab("Teleport"),
    Shop = Window:AddTab("Shop"),
    Misc = Window:AddTab("Misc"),
}

local function Section(tab, name)
    return tab:AddSection(name)
end

local function AddHubToggle(section, title, desc, flag, default)
    section:AddToggle(flag, {
        Text = title,
        Desc = desc,
        Default = default == nil and (_env[flag] == true) or default,
        Callback = function(value)
            _env[flag] = value
        end,
    })
end

-- Discord / informações
do
    local s = Section(Tabs.Discord, "Comunidade")
    s:AddLabel("Mango Cat Hub | Comunidade")
    s:AddLabel("Interface Mango Cat Hub carregada.")
    s:AddButton({
        Title = "Informações",
        Callback = function()
            Library:Notify({
                Title = "Mango Cat Hub",
                Description = "Mango Cat Hub carregado com sucesso.",
                Duration = 4,
            }, true)
        end,
    })
end

-- Farm
do
    local s = Section(Tabs.MainFarm, "Configuração de farm")
    s:AddDropdown("FarmTool", {
        Text = "Ferramenta de farm",
        Values = Loaded.WeaponsList,
        Default = Settings.ToolFarm,
        Callback = function(value)
            Settings.ToolFarm = value
        end,
    })
    AddHubToggle(s, "Auto Farm Level", ("MaxLevel: %i"):format(MSetting.Setting.MaxLevel), "Level Farm", false)
    AddHubToggle(s, "Auto Farm Nearest", "Ataca o inimigo vivo mais próximo.", "Nearest Farm", false)

    local e = Section(Tabs.MainFarm, "Inimigos")
    e:AddDropdown("SelectedEnemy", {
        Text = "Selecionar inimigo",
        Values = Loaded.EnemeiesList,
        Default = Loaded.EnemeiesList[1],
        Search = true,
        Callback = function(value)
            _env.SelecetedEnemie = value
        end,
    })
    AddHubToggle(e, "Auto Farm Selected", "Farme o inimigo selecionado.", "FS Enemie", false)
    AddHubToggle(e, "Pegar missão do inimigo selecionado", "Tenta obter a missão correspondente.", "FS Take Quest", true)

    local b = Section(Tabs.MainFarm, "Bosses")
    AddHubToggle(b, "Auto Meme Beast", "Meme Beast aparece periodicamente.", "Meme Beast", false)

    local r = Section(Tabs.MainFarm, "Raid")
    AddHubToggle(r, "Auto Farm Raid", "Requer nível 1000.", "Raid Farm", false)
end

-- Items, bosses e recursos
do
    local s = Section(Tabs.Items, "Powers")
    s:AddButton({
        Title = "Reroll Powers 10X [250k Money]",
        Callback = function()
            OtherEvent.MainEvents.Modules:FireServer("Random_Power", {
                Type = "Decuple",
                NPCName = "Floppa Gacha",
                GachaType = "Money",
            })
        end,
    })
    s:AddToggle("AutoStorePowers", {
        Text = "Auto Store Powers",
        Default = false,
        Callback = function(value)
            _env.AutoStorePowers = value
            if value then
                task.spawn(function()
                    while _env.AutoStorePowers do
                        _wait()
                        for _, v in ipairs(Player.Backpack:GetChildren()) do
                            if v:IsA("Tool") and v.ToolTip == "Power" and v:GetAttribute("Using") == nil then
                                v.Parent = Player.Character
                                OtherEvent.MainEvents.Modules:FireServer("Eatable_Power", {
                                    Action = "Store",
                                    Tool = v,
                                })
                            end
                        end
                    end
                end)
            end
        end,
    })

    local aura = Section(Tabs.Items, "Aura Color")
    aura:AddButton({
        Title = "Reroll Aura Color [10 Gems]",
        Callback = function()
            OtherEvent.MainEvents.Modules:FireServer("Reroll_Color", "Halfed Sorcerer")
        end,
    })

    local bosses = Section(Tabs.Items, "Bosses")
    AddHubToggle(bosses, "Auto Giant Pumpkin", "Drops de boss.", "Giant Pumpkin", false)
    AddHubToggle(bosses, "Auto Evil Noob", "Drops de boss.", "Evil Noob", false)
    AddHubToggle(bosses, "Auto Lord Sus", "Drops de boss.", "Lord Sus", false)

    local race = Section(Tabs.Items, "Race")
    AddHubToggle(race, "Auto Awakening Orb", "Requer nível 500.", "Race V2 Orb", false)

    local weapons = Section(Tabs.Items, "Weapons")
    AddHubToggle(weapons, "Auto Floppa", "Obtém a espada exclusiva Floppa.", "_Floppa Sword", false)

    local popcat = Section(Tabs.Items, "Popcat")
    popcat:AddToggle("AutoPopcat", {
        Text = "Auto Popcat",
        Default = false,
        Callback = function(value)
            _env.AutoPopcat = value
            local clickDetector = Island.FloppaIsland.Popcat_Clickable.Part.ClickDetector
            if value then
                GoTo(CFrame_new(400, -37, -588))
                task.spawn(function()
                    while _env.AutoPopcat do
                        RunService.Heartbeat:Wait()
                        fireclickdetector(clickDetector)
                    end
                end)
            end
        end,
    })
end

-- Stats
do
    local StatsName, SelectedStats = {
        ["Power"] = "MemePowerLevel",
        ["Health"] = "DefenseLevel",
        ["Weapon"] = "SwordLevel",
        ["Melee"] = "MeleeLevel",
    }, {}

    local s = Section(Tabs.Stats, "Pontos")
    s:AddSlider({
        Text = "Pontos por melhoria",
        Min = 1,
        Max = 100,
        Default = Settings.AutoStats_Points,
        Precise = false,
        Callback = function(value)
            Settings.AutoStats_Points = value
        end,
    })
    s:AddToggle("AutoStats", {
        Text = "Auto Stats",
        Default = false,
        Callback = function(value)
            _env.AutoStats = value
            if value then
                task.spawn(function()
                    local points = PlayerData.SkillPoint
                    while _env.AutoStats do
                        _wait(0.5)
                        for statName, enabled in pairs(SelectedStats) do
                            local stat = PlayerData:FindFirstChild(StatsName[statName])
                            if enabled and points.Value > 0 and stat and stat.Value < MSetting.Setting.MaxLevel then
                                OtherEvent.MainEvents.StatsFunction:InvokeServer({
                                    Target = StatsName[statName],
                                    Action = "UpgradeStats",
                                    Amount = math.clamp(Settings.AutoStats_Points, 0, MSetting.Setting.MaxLevel - stat.Value),
                                })
                            end
                        end
                    end
                end)
            end
        end,
    })

    local stats = Section(Tabs.Stats, "Selecionar atributos")
    for name in pairs(StatsName) do
        stats:AddToggle("Stat_" .. name, {
            Text = name,
            Default = false,
            Callback = function(value)
                SelectedStats[name] = value
            end,
        })
    end
end

-- Teleporte
do
    local s = Section(Tabs.Teleport, "Ilhas")
    local islandNames = {}
    for _, v in ipairs(Location:WaitForChild("SpawnLocations"):GetChildren()) do
        table.insert(islandNames, v.Name)
    end
    s:AddDropdown("Islands", {
        Text = "Ilhas",
        Values = islandNames,
        Search = true,
        Callback = function(value)
            local target = Location.SpawnLocations:FindFirstChild(value)
            if target then GoTo(target.CFrame) end
        end,
    })

    local q = Section(Tabs.Teleport, "Missões")
    local questNames = {}
    for _, v in ipairs(Location:WaitForChild("QuestLocaion"):GetChildren()) do
        table.insert(questNames, v.Name)
    end
    q:AddDropdown("Quests", {
        Text = "Missões",
        Values = questNames,
        Search = true,
        Callback = function(value)
            local target = Location.QuestLocaion:FindFirstChild(value)
            if target then GoTo(target.CFrame) end
        end,
    })
end

-- Shop
do
    local s = Section(Tabs.Shop, "Compra automática")
    s:AddToggle("AutoBuyAbility", {
        Text = "Auto Buy Abilities",
        Desc = "Aura, Instinct e Flash Step.",
        Default = false,
        Callback = function(value)
            _env.AutoBuyAbility = value
            if value then
                task.spawn(function()
                    while _env.AutoBuyAbility do
                        _wait(1)
                        if not Funcs:AbilityUnlocked("Instinct") and Funcs:CanBuy("Instinct") then
                            OtherEvent.MainEvents.Modules:FireServer("Ability_Teacher", "Nugget Man")
                        elseif not Funcs:AbilityUnlocked("FlashStep") and Funcs:CanBuy("FlashStep") then
                            OtherEvent.MainEvents.Modules:FireServer("Ability_Teacher", "Giga Chad")
                        elseif not Funcs:AbilityUnlocked("Aura") and Funcs:CanBuy("Aura") then
                            OtherEvent.MainEvents.Modules:FireServer("Ability_Teacher", "Aura Master")
                        else
                            _wait(3)
                        end
                    end
                end)
            end
        end,
    })

    for _, category in ipairs(Loaded.Shop) do
        local cat = Section(Tabs.Shop, category[1])
        for _, item in ipairs(category[2]) do
            local itemName, itemDesc, purchase = item[1], item[2], item[3]
            cat:AddButton({
                Title = itemName,
                Callback = function()
                    if type(purchase) == "table" then
                        OtherEvent.MainEvents.Modules:FireServer(unpack(purchase))
                    elseif type(purchase) == "function" then
                        purchase()
                    end
                end,
            })
        end
    end
end

-- Misc
do
    local s = Section(Tabs.Misc, "Geral")
    s:AddButton({
        Title = "Resgatar todos os códigos",
        Callback = function()
            Funcs:RAllCodes()
        end,
    })
    s:AddSlider({
        Text = "Distância de farm",
        Min = 5,
        Max = 15,
        Default = Settings.FarmDistance,
        Precise = false,
        Callback = function(value)
            Settings.FarmDistance = value or 8
            Settings.FarmCFrame = CFrame_new(0, Settings.FarmDistance, 0) * CFrame_Angles(math.rad(-90), 0, 0)
        end,
    })
    s:AddToggle("AutoHaki", {
        Text = "Auto Aura",
        Default = Settings.AutoHaki,
        Callback = function(value) Settings.AutoHaki = value end,
    })
    s:AddToggle("AutoAttack", {
        Text = "Auto Attack",
        Default = Settings.AutoClick,
        Callback = function(value) Settings.AutoClick = value end,
    })
    s:AddToggle("BringMobs", {
        Text = "Bring Mobs",
        Default = Settings.BringMobs,
        Callback = function(value) Settings.BringMobs = value end,
    })
    s:AddToggle("AntiAFK", {
        Text = "Anti AFK",
        Default = Settings.AntiAFK,
        Callback = function(value) Settings.AntiAFK = value end,
    })

    local team = Section(Tabs.Misc, "Team")
    team:AddButton({
        Title = "Join Cheems Team",
        Callback = function()
            OtherEvent.MainEvents.Modules:FireServer("Change_Team", "Cheems Recruiter")
        end,
    })
    team:AddButton({
        Title = "Join Floppa Team",
        Callback = function()
            OtherEvent.MainEvents.Modules:FireServer("Change_Team", "Floppa Recruiter")
        end,
    })

    local other = Section(Tabs.Misc, "Outros")
    other:AddToggle("RemoveNotifications", {
        Text = "Remove Notifications",
        Default = false,
        Callback = function(value)
            Player.PlayerGui.AnnounceGui.Enabled = not value
        end,
    })
end

Library:Notify({
    Title = "Mango Cat Hub",
    Description = "Interface carregada.",
    Duration = 4,
}, true)

task.spawn(function()
    if not _env.AntiAfk then
        _env.AntiAfk = true
        while _wait(60 * 10) do
            if Settings.AntiAFK then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end
    end
end)
