local StdUi = LibStub("StdUi")

local AtalDazar = DraduxAutoMarking:GetModule("AtalDazar")

if not AtalDazar.enemies[122965].specials then
    AtalDazar.enemies[122965].specials = {}
end

-- Encounter ID: 2085
-- boss1: Vol'kaal
-- boss2: Reanimation Totem
-- boss3: Reanimation Totem
-- boss4: Reanimation Totem

AtalDazar.enemies[122965].specials.encounter = {
    defaultVars = {
        {
            index = 6,
            allowed = true,
            priority = 100,
        },
        {
            index = 4,
            allowed = true,
            priority = 100,
        },
        {
            index = 3,
            allowed = true,
            priority = 100,
        },
        {
            index = 2,
            allowed = true,
            priority = 100,
        },
        {
            index = 1,
            allowed = true,
            priority = 100,
        }
    },
    gui = function(frame)
        frame.encounter = {}
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.encounter.title = title
        title:SetJustifyH("LEFT")
        title:SetJustifyV("CENTER")
        title:SetTextColor(1, 1, 1, 1)
        title:SetPoint("TOPLEFT", frame.triangle, "BOTTOMLEFT", 0, -20)
        title:SetText("Mark Totems, when encounter begins")

        local skull = StdUi:MarkerConfigurationFrame(frame, 8)
        frame.encounter.skull = skull
        StdUi:GlueBelow(skull, title, 0, -10, "LEFT")

        local cross = StdUi:MarkerConfigurationFrame(frame, 7)
        frame.encounter .cross = cross
        StdUi:GlueRight(cross, skull, 15, 0)

        local square = StdUi:MarkerConfigurationFrame(frame, 6)
        frame.encounter.square = square
        StdUi:GlueRight(square, cross, 15, 0)

        local moon = StdUi:MarkerConfigurationFrame(frame, 5)
        frame.encounter.moon = moon
        StdUi:GlueRight(moon, square, 15, 0)

        local triangle = StdUi:MarkerConfigurationFrame(frame, 4)
        frame.encounter.triangle = triangle
        StdUi:GlueBelow(triangle, skull, 0, -5, "LEFT")

        local diamond = StdUi:MarkerConfigurationFrame(frame, 3)
        frame.encounter.diamond = diamond
        StdUi:GlueRight(diamond, triangle, 15, 0)

        local circle = StdUi:MarkerConfigurationFrame(frame, 2)
        frame.encounter.circle = circle
        StdUi:GlueRight(circle, diamond, 15, 0)

        local star = StdUi:MarkerConfigurationFrame(frame, 1)
        frame.encounter.star = star
        StdUi:GlueRight(star, circle, 15, 0)

        frame:SetHeight(frame:GetHeight() + 90)
    end,
    save = function(npc, frame)
        local lut = {
            frame.encounter.star,
            frame.encounter.circle,
            frame.encounter.diamond,
            frame.encounter.triangle,
            frame.encounter.moon,
            frame.encounter.square,
            frame.encounter.cross,
            frame.encounter.skull
        }

        if not npc.specials then
            npc.specials = {}
        end

        npc.specials.encounter = {}
        for marker=1, 8 do
            local markerFrame = lut[marker]
            if markerFrame then
                table.insert(npc.specials.encounter, {
                    index = marker,
                    allowed = markerFrame.allowed:GetChecked(),
                    priority = markerFrame.priority:GetValue()
                })
            end
        end
    end,
    load = function(npc, frame)
        local lut = {
            frame.encounter.star,
            frame.encounter.circle,
            frame.encounter.diamond,
            frame.encounter.triangle,
            frame.encounter.moon,
            frame.encounter.square,
            frame.encounter.cross,
            frame.encounter.skull
        }

        if not npc.specials then
            npc.specials = {}
        end

        if not npc.specials.encounter then
            npc.specials.encounter = {}
        end

        for _, marker in ipairs(npc.specials.encounter) do
            local markerFrame = lut[marker.index]
            if markerFrame then
                markerFrame.allowed:SetChecked(marker.allowed)
                markerFrame.priority:SetValue(marker.priority or 0)
            end
        end
    end
}
