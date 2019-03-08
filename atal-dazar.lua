local AtalDazar = DraduxAutoMarking:NewModule("AtalDazar", "AceEvent-3.0")

function AtalDazar:OnInitialize()
    AtalDazar.tracking = false
    AtalDazar:Disable()
end

function AtalDazar:OnEnable()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:AddDefaultConfigurations(AtalDazar:GetName(), AtalDazar.enemies)

    AtalDazar.mdtDungeon = BattleForAzeroth:GetMdtDungeon(AtalDazar:GetName())

    local name, texture = BattleForAzeroth:GetInfo(AtalDazar:GetName())
    DraduxAutoMarking:AddMenuEntry(name, texture, AtalDazar, BattleForAzeroth)

    AtalDazar:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    AtalDazar:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function AtalDazar:IsMarking()
    return AtalDazar.tracking
end

function AtalDazar:CheckZone()
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    local ZoneID = BattleForAzeroth:GetInstanceID(AtalDazar:GetName())
    local CurrentZone = DraduxAutoMarking:GetCurrentInstance()

    if ZoneID == CurrentZone and not AtalDazar.tracking then
        AtalDazar.tracking = true
        AtalDazar:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        AtalDazar:RegisterEvent("ENCOUNTER_START")
        DraduxAutoMarking:StartScanner(AtalDazar:GetName())
        DraduxAutoMarking:TrackCombatLog()
    elseif ZoneID ~= CurrentZone then
        AtalDazar.tracking = false
        AtalDazar:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        AtalDazar:UnregisterEvent("ENCOUNTER_START")
        DraduxAutoMarking:StopScanner(AtalDazar:GetName())
        DraduxAutoMarking:UntrackCombatLog()
    end
end

function AtalDazar:ShowConfiguration()
    DraduxAutoMarking:ShowConfiguration(AtalDazar.enemies, function(id, name, hideInfo, extraConfiguration)
        AtalDazar:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    end)
end

function AtalDazar:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    if not AtalDazar.configurationFrames then
        AtalDazar.configurationFrames = {}
    end

    local info = {
        hide = hideInfo,
        mdtDungeon = AtalDazar.mdtDungeon
    }

    if not AtalDazar.configurationFrames[id] then
        local frame = DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, function()
            local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
            return BattleForAzeroth:GetDB(AtalDazar:GetName())
        end)

        AtalDazar.configurationFrames[id] = frame
    else
        DraduxAutoMarking:AddContentFrame(AtalDazar.configurationFrames[id])
    end

    AtalDazar.configurationFrames[id]:Load()
end

function AtalDazar:HandleSpecial(unit, npc, specialName)
    if specialName == "encounter" then
        -- It's handled by ENCOUNTER_START
        return false
    end

    print(string.format("%s - %s: Unknown special name \"%s\"", DraduxAutoMarking:GetName(), AtalDazar:GetName(), specialName))
    return false
end


function AtalDazar:ZONE_CHANGED_NEW_AREA()
    AtalDazar:CheckZone()
end

function AtalDazar:PLAYER_ENTERING_WORLD()
    AtalDazar:CheckZone()
end

function AtalDazar:NAME_PLATE_UNIT_ADDED(event, unit)
    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    BattleForAzeroth:NameplateUnitAdded(AtalDazar:GetName(), unit)
end

function AtalDazar:ENCOUNTER_START(event, encounterID)
    if encounterID == 2085 then
        local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
        local npc = BattleForAzeroth:GetNpcConfiguration(AtalDazar:GetName(), 122965)
        if npc and npc.specials and npc.specials.encounter then
            C_Timer.After(0.1, function()
                for i=2,4 do
                    DraduxAutoMarking:RequestMarker("boss" .. i, false, npc.specials.encounter, {
                        onMarkerSet = "LOCK",
                        onMarkerIsMissing = "RELEASE",
                        onDamageTaken = "NONE",
                        onNoDamageTaken = "NONE",
                        onUnitDied = "NONE",
                        onUnitDoesNotExists = "RELEASE"
                    })
                end
            end)
        end
    end
end