local WaycrestManor = DraduxAutoMarking:NewModule("WaycrestManor", "AceEvent-3.0")

function WaycrestManor:OnInitialize()
    WaycrestManor.tracking = false
    WaycrestManor:Disable()
end

function WaycrestManor:OnEnable()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:AddDefaultConfigurations(WaycrestManor:GetName(), WaycrestManor.enemies)

    WaycrestManor.mdtDungeon = BattleForAzeroth:GetMdtDungeon(WaycrestManor:GetName())

    local name, texture = BattleForAzeroth:GetInfo(WaycrestManor:GetName())
    DraduxAutoMarking:AddMenuEntry(name, texture, WaycrestManor, BattleForAzeroth)

    WaycrestManor:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    WaycrestManor:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function WaycrestManor:IsMarking()
    return WaycrestManor.tracking
end

function WaycrestManor:CheckZone()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    local ZoneID = BattleForAzeroth:GetInstanceID(WaycrestManor:GetName())
    local CurrentZone = DraduxAutoMarking:GetCurrentInstance()

    if ZoneID == CurrentZone and not WaycrestManor.tracking then
        WaycrestManor.tracking = true
        WaycrestManor:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StartScanner(WaycrestManor:GetName())
        DraduxAutoMarking:TrackCombatLog()
    elseif ZoneID ~= CurrentZone then
        WaycrestManor.tracking = false
        WaycrestManor:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StopScanner(WaycrestManor:GetName())
        DraduxAutoMarking:UntrackCombatLog()
    end
end

function WaycrestManor:ShowConfiguration()
    DraduxAutoMarking:ShowConfiguration(WaycrestManor.enemies, function(id, name, hideInfo, extraConfiguration)
        WaycrestManor:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    end)
end

function WaycrestManor:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    if not WaycrestManor.configurationFrames then
        WaycrestManor.configurationFrames = {}
    end

    local info = {
        hide = hideInfo,
        mdtDungeon = WaycrestManor.mdtDungeon
    }

    if not WaycrestManor.configurationFrames[id] then
        local frame = DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, function()
            local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
            return BattleForAzeroth:GetDB(WaycrestManor:GetName())
        end)

        WaycrestManor.configurationFrames[id] = frame
    else
        DraduxAutoMarking:AddContentFrame(WaycrestManor.configurationFrames[id])
    end

    WaycrestManor.configurationFrames[id]:Load()
end

function WaycrestManor:HandleSpecial(unit, npc, specialName)
    print(string.format("%s - %s: Unknown special name \"%s\"", DraduxAutoMarking:GetName(), WaycrestManor:GetName(), specialName))
    return false
end


function WaycrestManor:ZONE_CHANGED_NEW_AREA()
    WaycrestManor:CheckZone()
end

function WaycrestManor:PLAYER_ENTERING_WORLD()
    WaycrestManor:CheckZone()
end

function WaycrestManor:NAME_PLATE_UNIT_ADDED(event, unit)
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:NameplateUnitAdded(WaycrestManor:GetName(), unit)
end