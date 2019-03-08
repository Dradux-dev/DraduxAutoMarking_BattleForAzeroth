local Freehold = DraduxAutoMarking:NewModule("Freehold", "AceEvent-3.0")

function Freehold:OnInitialize()
    Freehold.tracking = false
    Freehold:Disable()
end

function Freehold:OnEnable()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:AddDefaultConfigurations(Freehold:GetName(), Freehold.enemies)

    Freehold.mdtDungeon = BattleForAzeroth:GetMdtDungeon(Freehold:GetName())

    local name, texture = BattleForAzeroth:GetInfo(Freehold:GetName())
    DraduxAutoMarking:AddMenuEntry(name, texture, Freehold, BattleForAzeroth)

    Freehold:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    Freehold:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Freehold:IsMarking()
    return Freehold.tracking
end

function Freehold:CheckZone()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    local ZoneID = BattleForAzeroth:GetInstanceID(Freehold:GetName())
    local CurrentZone = DraduxAutoMarking:GetCurrentInstance()

    if ZoneID == CurrentZone and not Freehold.tracking then
        Freehold.tracking = true
        Freehold:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StartScanner(Freehold:GetName())
        DraduxAutoMarking:TrackCombatLog()
    elseif ZoneID ~= CurrentZone then
        Freehold.tracking = false
        Freehold:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StopScanner(Freehold:GetName())
        DraduxAutoMarking:UntrackCombatLog()
    end
end

function Freehold:ShowConfiguration()
    DraduxAutoMarking:ShowConfiguration(Freehold.enemies, function(id, name, hideInfo, extraConfiguration)
        Freehold:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    end)
end

function Freehold:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    if not Freehold.configurationFrames then
        Freehold.configurationFrames = {}
    end

    local info = {
        hide = hideInfo,
        mdtDungeon = Freehold.mdtDungeon
    }

    if not Freehold.configurationFrames[id] then
        local frame = DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, function()
            local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
            return BattleForAzeroth:GetDB(Freehold:GetName())
        end)

        Freehold.configurationFrames[id] = frame
    else
        DraduxAutoMarking:AddContentFrame(Freehold.configurationFrames[id])
    end

    Freehold.configurationFrames[id]:Load()
end

function Freehold:HandleSpecial(unit, npc, specialName)
    print(string.format("%s - %s: Unknown special name \"%s\"", DraduxAutoMarking:GetName(), Freehold:GetName(), specialName))
    return false
end


function Freehold:ZONE_CHANGED_NEW_AREA()
    Freehold:CheckZone()
end

function Freehold:PLAYER_ENTERING_WORLD()
    Freehold:CheckZone()
end

function Freehold:NAME_PLATE_UNIT_ADDED(event, unit)
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:NameplateUnitAdded(Freehold:GetName(), unit)
end