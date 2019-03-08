local TolDagor = DraduxAutoMarking:NewModule("TolDagor", "AceEvent-3.0")

function TolDagor:OnInitialize()
    TolDagor.tracking = false
    TolDagor:Disable()
end

function TolDagor:OnEnable()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:AddDefaultConfigurations(TolDagor:GetName(), TolDagor.enemies)

    TolDagor.mdtDungeon = BattleForAzeroth:GetMdtDungeon(TolDagor:GetName())

    local name, texture = BattleForAzeroth:GetInfo(TolDagor:GetName())
    DraduxAutoMarking:AddMenuEntry(name, texture, TolDagor, BattleForAzeroth)

    TolDagor:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    TolDagor:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function TolDagor:IsMarking()
    return TolDagor.tracking
end

function TolDagor:CheckZone()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    local ZoneID = BattleForAzeroth:GetInstanceID(TolDagor:GetName())
    local CurrentZone = DraduxAutoMarking:GetCurrentInstance()

    if ZoneID == CurrentZone and not TolDagor.tracking then
        TolDagor.tracking = true
        TolDagor:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StartScanner(TolDagor:GetName())
        DraduxAutoMarking:TrackCombatLog()
    elseif ZoneID ~= CurrentZone then
        TolDagor.tracking = false
        TolDagor:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StopScanner(TolDagor:GetName())
        DraduxAutoMarking:UntrackCombatLog()
    end
end

function TolDagor:ShowConfiguration()
    DraduxAutoMarking:ShowConfiguration(TolDagor.enemies, function(id, name, hideInfo, extraConfiguration)
        TolDagor:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    end)
end

function TolDagor:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    if not TolDagor.configurationFrames then
        TolDagor.configurationFrames = {}
    end

    local info = {
        hide = hideInfo,
        mdtDungeon = TolDagor.mdtDungeon
    }

    if not TolDagor.configurationFrames[id] then
        local frame = DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, function()
            local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
            return BattleForAzeroth:GetDB(TolDagor:GetName())
        end)

        TolDagor.configurationFrames[id] = frame
    else
        DraduxAutoMarking:AddContentFrame(TolDagor.configurationFrames[id])
    end

    TolDagor.configurationFrames[id]:Load()
end

function TolDagor:HandleSpecial(unit, npc, specialName)
    print(string.format("%s - %s: Unknown special name \"%s\"", DraduxAutoMarking:GetName(), TolDagor:GetName(), specialName))
    return false
end


function TolDagor:ZONE_CHANGED_NEW_AREA()
    TolDagor:CheckZone()
end

function TolDagor:PLAYER_ENTERING_WORLD()
    TolDagor:CheckZone()
end

function TolDagor:NAME_PLATE_UNIT_ADDED(event, unit)
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:NameplateUnitAdded(TolDagor:GetName(), unit)
end