local KingsRest = DraduxAutoMarking:NewModule("KingsRest", "AceEvent-3.0")

function KingsRest:OnInitialize()
    KingsRest.tracking = false
    KingsRest:Disable()
end

function KingsRest:OnEnable()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:AddDefaultConfigurations(KingsRest:GetName(), KingsRest.enemies)

    KingsRest.mdtDungeon = BattleForAzeroth:GetMdtDungeon(KingsRest:GetName())

    local name, texture = BattleForAzeroth:GetInfo(KingsRest:GetName())
    DraduxAutoMarking:AddMenuEntry(name, texture, KingsRest, BattleForAzeroth)

    KingsRest:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    KingsRest:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function KingsRest:IsMarking()
    return KingsRest.tracking
end

function KingsRest:CheckZone()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    local ZoneID = BattleForAzeroth:GetInstanceID(KingsRest:GetName())
    local CurrentZone = DraduxAutoMarking:GetCurrentInstance()

    if ZoneID == CurrentZone and not KingsRest.tracking then
        KingsRest.tracking = true
        KingsRest:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StartScanner(KingsRest:GetName())
        DraduxAutoMarking:TrackCombatLog()
    elseif ZoneID ~= CurrentZone then
        KingsRest.tracking = false
        KingsRest:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StopScanner(KingsRest:GetName())
        DraduxAutoMarking:UntrackCombatLog()
    end
end

function KingsRest:ShowConfiguration()
    DraduxAutoMarking:ShowConfiguration(KingsRest.enemies, function(id, name, hideInfo, extraConfiguration)
        KingsRest:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    end)
end

function KingsRest:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    if not KingsRest.configurationFrames then
        KingsRest.configurationFrames = {}
    end

    local info = {
        hide = hideInfo,
        mdtDungeon = KingsRest.mdtDungeon
    }

    if not KingsRest.configurationFrames[id] then
        local frame = DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, function()
            local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
            return BattleForAzeroth:GetDB(KingsRest:GetName())
        end)

        KingsRest.configurationFrames[id] = frame
    else
        DraduxAutoMarking:AddContentFrame(KingsRest.configurationFrames[id])
    end

    KingsRest.configurationFrames[id]:Load()
end

function KingsRest:HandleSpecial(unit, npc, specialName)
    print(string.format("%s - %s: Unknown special name \"%s\"", DraduxAutoMarking:GetName(), KingsRest:GetName(), specialName))
    return false
end


function KingsRest:ZONE_CHANGED_NEW_AREA()
    KingsRest:CheckZone()
end

function KingsRest:PLAYER_ENTERING_WORLD()
    KingsRest:CheckZone()
end

function KingsRest:NAME_PLATE_UNIT_ADDED(event, unit)
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:NameplateUnitAdded(KingsRest:GetName(), unit)
end