local SiegeOfBoralus = DraduxAutoMarking:NewModule("SiegeOfBoralus", "AceEvent-3.0")

function SiegeOfBoralus:OnInitialize()
    SiegeOfBoralus.tracking = false
    SiegeOfBoralus:Disable()
end

function SiegeOfBoralus:OnEnable()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:AddDefaultConfigurations(SiegeOfBoralus:GetName(), SiegeOfBoralus.enemies)

    SiegeOfBoralus.mdtDungeon = BattleForAzeroth:GetMdtDungeon(SiegeOfBoralus:GetName())

    local name, texture = BattleForAzeroth:GetInfo(SiegeOfBoralus:GetName())
    DraduxAutoMarking:AddMenuEntry(name, texture, SiegeOfBoralus, BattleForAzeroth)

    SiegeOfBoralus:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    SiegeOfBoralus:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function SiegeOfBoralus:IsMarking()
    return SiegeOfBoralus.tracking
end

function SiegeOfBoralus:CheckZone()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    local ZoneID = BattleForAzeroth:GetInstanceID(SiegeOfBoralus:GetName())
    local CurrentZone = DraduxAutoMarking:GetCurrentInstance()

    if ZoneID == CurrentZone and not SiegeOfBoralus.tracking then
        SiegeOfBoralus.tracking = true
        SiegeOfBoralus:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StartScanner(SiegeOfBoralus:GetName())
        DraduxAutoMarking:TrackCombatLog()
    elseif ZoneID ~= CurrentZone then
        SiegeOfBoralus.tracking = false
        SiegeOfBoralus:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StopScanner(SiegeOfBoralus:GetName())
        DraduxAutoMarking:UntrackCombatLog()
    end
end

function SiegeOfBoralus:ShowConfiguration()
    DraduxAutoMarking:ShowConfiguration(SiegeOfBoralus.enemies, function(id, name, hideInfo, extraConfiguration)
        SiegeOfBoralus:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    end)
end

function SiegeOfBoralus:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    if not SiegeOfBoralus.configurationFrames then
        SiegeOfBoralus.configurationFrames = {}
    end

    local info = {
        hide = hideInfo,
        mdtDungeon = SiegeOfBoralus.mdtDungeon
    }

    if not SiegeOfBoralus.configurationFrames[id] then
        local frame = DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, function()
            local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
            return BattleForAzeroth:GetDB(SiegeOfBoralus:GetName())
        end)

        SiegeOfBoralus.configurationFrames[id] = frame
    else
        DraduxAutoMarking:AddContentFrame(SiegeOfBoralus.configurationFrames[id])
    end

    SiegeOfBoralus.configurationFrames[id]:Load()
end

function SiegeOfBoralus:HandleSpecial(unit, npc, specialName)
    print(string.format("%s - %s: Unknown special name \"%s\"", DraduxAutoMarking:GetName(), SiegeOfBoralus:GetName(), specialName))
    return false
end


function SiegeOfBoralus:ZONE_CHANGED_NEW_AREA()
    SiegeOfBoralus:CheckZone()
end

function SiegeOfBoralus:PLAYER_ENTERING_WORLD()
    SiegeOfBoralus:CheckZone()
end

function SiegeOfBoralus:NAME_PLATE_UNIT_ADDED(event, unit)
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:NameplateUnitAdded(SiegeOfBoralus:GetName(), unit)
end