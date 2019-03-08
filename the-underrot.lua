local TheUnderrot = DraduxAutoMarking:NewModule("TheUnderrot", "AceEvent-3.0")

function TheUnderrot:OnInitialize()
    TheUnderrot.tracking = false
    TheUnderrot:Disable()
end

function TheUnderrot:OnEnable()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:AddDefaultConfigurations(TheUnderrot:GetName(), TheUnderrot.enemies)

    TheUnderrot.mdtDungeon = BattleForAzeroth:GetMdtDungeon(TheUnderrot:GetName())

    local name, texture = BattleForAzeroth:GetInfo(TheUnderrot:GetName())
    DraduxAutoMarking:AddMenuEntry(name, texture, TheUnderrot, BattleForAzeroth)

    TheUnderrot:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    TheUnderrot:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function TheUnderrot:IsMarking()
    return TheUnderrot.tracking
end

function TheUnderrot:CheckZone()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    local ZoneID = BattleForAzeroth:GetInstanceID(TheUnderrot:GetName())
    local CurrentZone = DraduxAutoMarking:GetCurrentInstance()

    if ZoneID == CurrentZone and not TheUnderrot.tracking then
        TheUnderrot.tracking = true
        TheUnderrot:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StartScanner(TheUnderrot:GetName())
        DraduxAutoMarking:TrackCombatLog()
    elseif ZoneID ~= CurrentZone then
        TheUnderrot.tracking = false
        TheUnderrot:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StopScanner(TheUnderrot:GetName())
        DraduxAutoMarking:UntrackCombatLog()
    end
end

function TheUnderrot:ShowConfiguration()
    DraduxAutoMarking:ShowConfiguration(TheUnderrot.enemies, function(id, name, hideInfo, extraConfiguration)
        TheUnderrot:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    end)
end

function TheUnderrot:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    if not TheUnderrot.configurationFrames then
        TheUnderrot.configurationFrames = {}
    end

    local info = {
        hide = hideInfo,
        mdtDungeon = TheUnderrot.mdtDungeon
    }

    if not TheUnderrot.configurationFrames[id] then
        local frame = DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, function()
            local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
            return BattleForAzeroth:GetDB(TheUnderrot:GetName())
        end)

        TheUnderrot.configurationFrames[id] = frame
    else
        DraduxAutoMarking:AddContentFrame(TheUnderrot.configurationFrames[id])
    end

    TheUnderrot.configurationFrames[id]:Load()
end

function TheUnderrot:HandleSpecial(unit, npc, specialName)
    print(string.format("%s - %s: Unknown special name \"%s\"", DraduxAutoMarking:GetName(), TheUnderrot:GetName(), specialName))
    return false
end


function TheUnderrot:ZONE_CHANGED_NEW_AREA()
    TheUnderrot:CheckZone()
end

function TheUnderrot:PLAYER_ENTERING_WORLD()
    TheUnderrot:CheckZone()
end

function TheUnderrot:NAME_PLATE_UNIT_ADDED(event, unit)
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:NameplateUnitAdded(TheUnderrot:GetName(), unit)
end