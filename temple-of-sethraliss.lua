local TempleOfSethraliss = DraduxAutoMarking:NewModule("TempleOfSethraliss", "AceEvent-3.0")

function TempleOfSethraliss:OnInitialize()
    TempleOfSethraliss.tracking = false
    TempleOfSethraliss:Disable()
end

function TempleOfSethraliss:OnEnable()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:AddDefaultConfigurations(TempleOfSethraliss:GetName(), TempleOfSethraliss.enemies)

    TempleOfSethraliss.mdtDungeon = BattleForAzeroth:GetMdtDungeon(TempleOfSethraliss:GetName())

    local name, texture = BattleForAzeroth:GetInfo(TempleOfSethraliss:GetName())
    DraduxAutoMarking:AddMenuEntry(name, texture, TempleOfSethraliss, BattleForAzeroth)

    TempleOfSethraliss:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    TempleOfSethraliss:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function TempleOfSethraliss:IsMarking()
    return TempleOfSethraliss.tracking
end

function TempleOfSethraliss:CheckZone()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    local ZoneID = BattleForAzeroth:GetInstanceID(TempleOfSethraliss:GetName())
    local CurrentZone = DraduxAutoMarking:GetCurrentInstance()

    if ZoneID == CurrentZone and not TempleOfSethraliss.tracking then
        TempleOfSethraliss.tracking = true
        TempleOfSethraliss:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StartScanner(TempleOfSethraliss:GetName())
        DraduxAutoMarking:TrackCombatLog()
    elseif ZoneID ~= CurrentZone then
        TempleOfSethraliss.tracking = false
        TempleOfSethraliss:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StopScanner(TempleOfSethraliss:GetName())
        DraduxAutoMarking:UntrackCombatLog()
    end
end

function TempleOfSethraliss:ShowConfiguration()
    DraduxAutoMarking:ShowConfiguration(TempleOfSethraliss.enemies, function(id, name, hideInfo, extraConfiguration)
        TempleOfSethraliss:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    end)
end

function TempleOfSethraliss:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    if not TempleOfSethraliss.configurationFrames then
        TempleOfSethraliss.configurationFrames = {}
    end

    local info = {
        hide = hideInfo,
        mdtDungeon = TempleOfSethraliss.mdtDungeon
    }

    if not TempleOfSethraliss.configurationFrames[id] then
        local frame = DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, function()
            local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
            return BattleForAzeroth:GetDB(TempleOfSethraliss:GetName())
        end)

        TempleOfSethraliss.configurationFrames[id] = frame
    else
        DraduxAutoMarking:AddContentFrame(TempleOfSethraliss.configurationFrames[id])
    end

    TempleOfSethraliss.configurationFrames[id]:Load()
end

function TempleOfSethraliss:HandleSpecial(unit, npc, specialName)
    print(string.format("%s - %s: Unknown special name \"%s\"", DraduxAutoMarking:GetName(), TempleOfSethraliss:GetName(), specialName))
    return false
end


function TempleOfSethraliss:ZONE_CHANGED_NEW_AREA()
    TempleOfSethraliss:CheckZone()
end

function TempleOfSethraliss:PLAYER_ENTERING_WORLD()
    TempleOfSethraliss:CheckZone()
end

function TempleOfSethraliss:NAME_PLATE_UNIT_ADDED(event, unit)
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:NameplateUnitAdded(TempleOfSethraliss:GetName(), unit)
end