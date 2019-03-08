local TheMotherlode = DraduxAutoMarking:NewModule("TheMotherlode", "AceEvent-3.0")

function TheMotherlode:OnInitialize()
    TheMotherlode.tracking = false
    TheMotherlode:Disable()
end

function TheMotherlode:OnEnable()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:AddDefaultConfigurations(TheMotherlode:GetName(), TheMotherlode.enemies)

    TheMotherlode.mdtDungeon = BattleForAzeroth:GetMdtDungeon(TheMotherlode:GetName())

    local name, texture = BattleForAzeroth:GetInfo(TheMotherlode:GetName())
    DraduxAutoMarking:AddMenuEntry(name, texture, TheMotherlode, BattleForAzeroth)

    TheMotherlode:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    TheMotherlode:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function TheMotherlode:IsMarking()
    return TheMotherlode.tracking
end

function TheMotherlode:CheckZone()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    local ZoneID = BattleForAzeroth:GetInstanceID(TheMotherlode:GetName())
    local CurrentZone = DraduxAutoMarking:GetCurrentInstance()

    if ZoneID == CurrentZone and not TheMotherlode.tracking then
        TheMotherlode.tracking = true
        TheMotherlode:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StartScanner(TheMotherlode:GetName())
        DraduxAutoMarking:TrackCombatLog()
    elseif ZoneID ~= CurrentZone then
        TheMotherlode.tracking = false
        TheMotherlode:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StopScanner(TheMotherlode:GetName())
        DraduxAutoMarking:UntrackCombatLog()
    end
end

function TheMotherlode:ShowConfiguration()
    DraduxAutoMarking:ShowConfiguration(TheMotherlode.enemies, function(id, name, hideInfo, extraConfiguration)
        TheMotherlode:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    end)
end

function TheMotherlode:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    if not TheMotherlode.configurationFrames then
        TheMotherlode.configurationFrames = {}
    end

    local info = {
        hide = hideInfo,
        mdtDungeon = TheMotherlode.mdtDungeon
    }

    if not TheMotherlode.configurationFrames[id] then
        local frame = DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, function()
            local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
            return BattleForAzeroth:GetDB(TheMotherlode:GetName())
        end)

        TheMotherlode.configurationFrames[id] = frame
    else
        DraduxAutoMarking:AddContentFrame(TheMotherlode.configurationFrames[id])
    end

    TheMotherlode.configurationFrames[id]:Load()
end

function TheMotherlode:HandleSpecial(unit, npc, specialName)
    print(string.format("%s - %s: Unknown special name \"%s\"", DraduxAutoMarking:GetName(), TheMotherlode:GetName(), specialName))
    return false
end


function TheMotherlode:ZONE_CHANGED_NEW_AREA()
    TheMotherlode:CheckZone()
end

function TheMotherlode:PLAYER_ENTERING_WORLD()
    TheMotherlode:CheckZone()
end

function TheMotherlode:NAME_PLATE_UNIT_ADDED(event, unit)
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:NameplateUnitAdded(TheMotherlode:GetName(), unit)
end