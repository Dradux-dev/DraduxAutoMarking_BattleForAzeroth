local BattleForAzeroth = DraduxAutoMarking:NewModule("BattleForAzeroth")

local defaultSavedVars = {
    profile = {}
}

local instances = {
    AtalDazar = {
        id = 1763,
        name = "Atal'Dazar",
        texture = "Interface\\Addons\\DraduxAutoMarking_BattleForAzeroth\\media\\atal-dazar",
        mdtDungeon = 15
    },
    Freehold = {
        id = 1754,
        name = "Freehold",
        texture = "Interface\\Addons\\DraduxAutoMarking_BattleForAzeroth\\media\\freehold",
        mdtDungeon = 16
    },
    KingsRest = {
        id = 1762,
        name = "King's Rest",
        texture = "Interface\\Addons\\DraduxAutoMarking_BattleForAzeroth\\media\\kings-rest",
        mdtDungeon = 17
    },
    ShrineOfTheStorm = {
        id = 1864,
        name = "Shrine of the Storm",
        texture = "Interface\\Addons\\DraduxAutoMarking_BattleForAzeroth\\media\\shrine-of-the-storm",
        mdtDungeon = 18
    },
    SiegeOfBoralus = {
        id = 1822,
        name = "Siege of Boralus",
        texture = "Interface\\Addons\\DraduxAutoMarking_BattleForAzeroth\\media\\siege-of-boralus",
        mdtDungeon = 19
    },
    TempleOfSethraliss = {
        id = 1877,
        name = "Temple of Sethraliss",
        texture = "Interface\\Addons\\DraduxAutoMarking_BattleForAzeroth\\media\\temple-of-sethraliss",
        mdtDungeon = 20
    },
    TheMotherlode = {
        id = 1594,
        name = "The MOTHERLODE!!",
        texture = "Interface\\Addons\\DraduxAutoMarking_BattleForAzeroth\\media\\the-motherlode",
        mdtDungeon = 21
    },
    TheUnderrot = {
        id = 1841,
        name = "The Underrot",
        texture = "Interface\\Addons\\DraduxAutoMarking_BattleForAzeroth\\media\\the-underrot",
        mdtDungeon = 22
    },
    TolDagor = {
        id = 1771,
        name = "Tol Dagor",
        "Interface\\Addons\\DraduxAutoMarking_BattleForAzeroth\\media\\tol-dagor",
        mdtDungeon = 23
    },
    WaycrestManor = {
        id = 1862,
        name = "Waycrest Manor",
        texture = "Interface\\Addons\\DraduxAutoMarking_BattleForAzeroth\\media\\waycrest-manor",
        mdtDungeon = 24
    }
}


function BattleForAzeroth:OnEnable()
    BattleForAzeroth.db = LibStub("AceDB-3.0"):New("DraduxAutoMarkingBattleForAzerothDB", defaultSavedVars)

    DraduxAutoMarking:EnableModule("AtalDazar")
    DraduxAutoMarking:EnableModule("Freehold")
    DraduxAutoMarking:EnableModule("KingsRest")
    DraduxAutoMarking:EnableModule("ShrineOfTheStorm")
    DraduxAutoMarking:EnableModule("SiegeOfBoralus")
    DraduxAutoMarking:EnableModule("TempleOfSethraliss")
    DraduxAutoMarking:EnableModule("TheMotherlode")
    DraduxAutoMarking:EnableModule("TheUnderrot")
    DraduxAutoMarking:EnableModule("TolDagor")
    DraduxAutoMarking:EnableModule("WaycrestManor")
end

function BattleForAzeroth:GetDB(moduleName)
    if not BattleForAzeroth.db then
        BattleForAzeroth.db = LibStub("AceDB-3.0"):New("DraduxAutoMarkingBattleForAzerothDB", defaultSavedVars)
    end

    if not BattleForAzeroth.db.profile[moduleName] then
        BattleForAzeroth.db.profile[moduleName] = {}
    end

    return BattleForAzeroth.db.profile[moduleName]
end

function BattleForAzeroth:SetDB(moduleName, db)
    if not BattleForAzeroth.db then
        BattleForAzeroth.db = LibStub("AceDB-3.0"):New("DraduxAutoMarkingBattleForAzerothDB", defaultSavedVars)
    end

    if not db then
        db = defaultSavedVars.profile[moduleName]
    end

    BattleForAzeroth.db.profile[moduleName] =  db
end

function BattleForAzeroth:GetNpcConfiguration(moduleName, npc_id)
    local db = BattleForAzeroth:GetDB(moduleName)
    return db[npc_id]
end

function BattleForAzeroth:AddDefaultConfiguration(moduleName, npc_id, data)
    if not defaultSavedVars.profile[moduleName] then
        defaultSavedVars.profile[moduleName] = {}
    end

    defaultSavedVars.profile[moduleName][npc_id] = data
end

function BattleForAzeroth:AddDefaultConfigurations(moduleName, enemies)
    for id, entry in pairs(enemies) do
        local configuration = {
            markers = entry.markers
        }

        if entry.specials then
            configuration.specials = {}

            for specialName, data in pairs(entry.specials) do
                configuration.specials[specialName] = data.defaultVars
            end
        end

        BattleForAzeroth:AddDefaultConfiguration(moduleName, id, configuration)
    end
end

function BattleForAzeroth:NameplateUnitAdded(moduleName, unit)
    local guid = UnitGUID(unit)
    local npc_id = DraduxAutoMarking:GetNpcID(guid)

    local BattleForAzeroth = DraduxAutoMarking:GetModule("BattleForAzeroth")
    local npc = BattleForAzeroth:GetNpcConfiguration(moduleName, npc_id)
    if npc then
        local markers = npc.markers

        if npc.specials then
            for index, special in ipairs(npc.specials) do
                if AtalDazar:HandleSpecial(unit, npc, special.name) then
                    markers = npc.special.markers
                end
            end
        end

        if markers then
            DraduxAutoMarking:RequestMarker(unit, true, markers, {
                onMarkerSet = "NONE",
                onMarkerIsMissing = "RELEASE",
                onDamageTaken = "LOCK",
                onNoDamageTaken = "UNLOCK",
                onUnitDied = "RELEASE",
                onUnitDoesNotExists = "NONE"
            })
        end
    end
end

function BattleForAzeroth:GetInfo(name)
    if not instances[name] then
        return
    end

    return instances[name].name, instances[name].texture
end

function BattleForAzeroth:GetInstanceID(name)
    if not instances[name] then
        return
    end

    return instances[name].id
end

function BattleForAzeroth:GetMdtDungeon(name)
    if not instances[name] then
        return
    end

    return instances[name].mdtDungeon
end