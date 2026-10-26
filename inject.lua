-- ==============================================================================
--                        MAYSTRO MENU - FIVEM INJECTOR
-- ==============================================================================
-- تم إزالة F5 نهائياً: الزر يحدده المستخدم بنفسه عبر واجهة المنيو (Keybind Box)
-- ==============================================================================

local Features = {
    godmode = false,
    superJump = false,
    invisible = false,
    punch = false,
    noclip = false,
    noclipSpeed = 2,
    ragdoll = false
}

-- إعطاء الفوكس للـ NUI فوراً لكي يستقبل ضغط الزر من الـ JS وتعيين الزر المفضل للمستخدم
SetNuiFocus(true, true)

-- استقبال أحداث النقر والتفعيل من واجهة NUI (JS)
RegisterNUICallback('itemClicked', function(data, cb)
    local id = data.id
    local enabled = data.enabled
    local val = data.val
    local ped = PlayerPedId()
    local player = PlayerId()

    if id == 'godmode' then
        Features.godmode = enabled
        SetEntityInvincible(ped, enabled)
        SetPlayerInvincible(player, enabled)
        print("[MAYSTRO] Godmode: " .. tostring(enabled))

    elseif id == 'superJump' then
        Features.superJump = enabled
        print("[MAYSTRO] Super Jump: " .. tostring(enabled))

    elseif id == 'invisible' then
        Features.invisible = enabled
        SetEntityVisible(ped, not enabled, 0)
        print("[MAYSTRO] Invisible: " .. tostring(enabled))

    elseif id == 'punch' then
        Features.punch = enabled
        print("[MAYSTRO] Super Punch: " .. tostring(enabled))

    elseif id == 'noclip' then
        Features.noclip = enabled
        if val then Features.noclipSpeed = val end
        SetEntityCollision(ped, not enabled, not enabled)
        FreezeEntityPosition(ped, enabled)
        print("[MAYSTRO] Noclip: " .. tostring(enabled))

    elseif id == 'ragdoll' then
        Features.ragdoll = enabled
        if enabled then
            SetPedToRagdoll(ped, 3000, 3000, 0, 0, 0, 0)
        end
        print("[MAYSTRO] Ragdoll: " .. tostring(enabled))
    end

    if cb then cb('ok') end
end)

-- حلقة الميزات المستمرة في اللعبة
CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local player = PlayerId()

        -- وضع الخلود
        if Features.godmode then
            sleep = 0
            SetEntityInvincible(ped, true)
            SetPlayerInvincible(player, true)
            ClearPedBloodDamage(ped)
            SetEntityHealth(ped, 200)
        end

        -- قفز خارق
        if Features.superJump then
            sleep = 0
            SetSuperJumpThisFrame(player)
        end

        -- لكمة خارقة
        if Features.punch then
            sleep = 0
            SetPlayerMeleeWeaponDamageModifier(player, 100.0)
        end

        -- نو كليب
        if Features.noclip then
            sleep = 0
            local x, y, z = table.unpack(GetEntityCoords(ped, true))
            local speed = (Features.noclipSpeed or 2) * 0.4
            local h = math.rad(GetGameplayCamRelativeHeading() + GetEntityHeading(ped))
            local p = math.rad(GetGameplayCamRelativePitch())
            local dx, dy, dz = 0.0, 0.0, 0.0

            if IsControlPressed(0, 32) then dx = dx - math.sin(h)*speed*math.cos(p); dy = dy + math.cos(h)*speed*math.cos(p); dz = dz + math.sin(p)*speed end
            if IsControlPressed(0, 33) then dx = dx + math.sin(h)*speed*math.cos(p); dy = dy - math.cos(h)*speed*math.cos(p); dz = dz - math.sin(p)*speed end
            if IsControlPressed(0, 22) then dz = dz + speed end
            if IsControlPressed(0, 21) then dz = dz - speed end
            SetEntityCoordsNoOffset(ped, x + dx, y + dy, z + dz, true, true, true)
        end

        Wait(sleep)
    end
end)

print("^2[MAYSTRO MENU]^7 Ready! Select your keybind on the screen now.")
