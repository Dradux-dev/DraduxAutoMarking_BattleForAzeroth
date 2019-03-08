local ShrineOfTheStorm = DraduxAutoMarking:NewModule("ShrineOfTheStorm", "AceEvent-3.0")

function ShrineOfTheStorm:OnInitialize()
    ShrineOfTheStorm.tracking = false
    ShrineOfTheStorm:Disable()
end

function ShrineOfTheStorm:OnEnable()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:AddDefaultConfigurations(ShrineOfTheStorm:GetName(), ShrineOfTheStorm.enemies)

    ShrineOfTheStorm.mdtDungeon = BattleForAzeroth:GetMdtDungeon(ShrineOfTheStorm:GetName())

    local name, texture = BattleForAzeroth:GetInfo(ShrineOfTheStorm:GetName())
    DraduxAutoMarking:AddMenuEntry(name, texture, ShrineOfTheStorm, BattleForAzeroth)

    ShrineOfTheStorm:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    ShrineOfTheStorm:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function ShrineOfTheStorm:IsMarking()
    return ShrineOfTheStorm.tracking
end

function ShrineOfTheStorm:CheckZone()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    local ZoneID = BattleForAzeroth:GetInstanceID(ShrineOfTheStorm:GetName())
    local CurrentZone = DraduxAutoMarking:GetCurrentInstance()

    if ZoneID == CurrentZone and not ShrineOfTheStorm.tracking then
        ShrineOfTheStorm.tracking = true
        ShrineOfTheStorm:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StartScanner(ShrineOfTheStorm:GetName())
        DraduxAutoMarking:TrackCombatLog()
    elseif ZoneID ~= CurrentZone then
        ShrineOfTheStorm.tracking = false
        ShrineOfTheStorm:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StopScanner(ShrineOfTheStorm:GetName())
        DraduxAutoMarking:UntrackCombatLog()
    end
end

function ShrineOfTheStorm:ShowConfiguration()
    DraduxAutoMarking:ShowConfiguration(ShrineOfTheStorm.enemies, function(id, name, hideInfo, extraConfiguration)
        ShrineOfTheStorm:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    end)
end

function ShrineOfTheStorm:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    if not ShrineOfTheStorm.configurationFrames then
        ShrineOfTheStorm.configurationFrames = {}
    end

    local info = {
        hide = hideInfo,
        mdtDungeon = ShrineOfTheStorm.mdtDungeon
    }

    if not ShrineOfTheStorm.configurationFrames[id] then
        local frame = DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, function()
            local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
            return BattleForAzeroth:GetDB(ShrineOfTheStorm:GetName())
        end)

        ShrineOfTheStorm.configurationFrames[id] = frame
    else
        DraduxAutoMarking:AddContentFrame(ShrineOfTheStorm.configurationFrames[id])
    end

    ShrineOfTheStorm.configurationFrames[id]:Load()
end

function ShrineOfTheStorm:HandleSpecial(unit, npc, specialName)
    print(string.format("%s - %s: Unknown special name \"%s\"", DraduxAutoMarking:GetName(), ShrineOfTheStorm:GetName(), specialName))
    return false
end


function ShrineOfTheStorm:ZONE_CHANGED_NEW_AREA()
    ShrineOfTheStorm:CheckZone()
end

function ShrineOfTheStorm:PLAYER_ENTERING_WORLD()
    ShrineOfTheStorm:CheckZone()
end

function ShrineOfTheStorm:NAME_PLATE_UNIT_ADDED(event, unit)
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:NameplateUnitAdded(ShrineOfTheStorm:GetName(), unit)
end