-- ==============================================================================
--                        MAYSTRO MENU - FIVEM CLIENT & INJECTOR
-- ==============================================================================
-- يعمل كـ Resource عادي في FiveM وأيضاً يمكن حقنه مباشرة عبر أي Lua Executor
-- اختصار فتح / إغلاق المنيو: زر F5 (أو كتابة أمر maystro/ في الكونسول أو الشات)
-- ==============================================================================

local isMenuVisible = false

local Features = {
    godmode = false,
    superJump = false,
    invisible = false,
    punch = false,
    noclip = false,
    noclipSpeed = 2,
    ragdoll = false
}

-- دالة فتح وإغلاق المنيو
function ToggleMaystroMenu(state)
    if state == nil then
        state = not isMenuVisible
    end
    isMenuVisible = state

    SetNuiFocus(isMenuVisible, isMenuVisible)
    SendNUIMessage({
        action = isMenuVisible and "openMenu" or "closeMenu"
    })

    if isMenuVisible then
        print("^2[MAYSTRO MENU]^7 Menu Opened")
    else
        print("^3[MAYSTRO MENU]^7 Menu Closed")
    end
end

-- تسجيل أمر لفتح المنيو من الشات أو الكونسول F8
RegisterCommand("maystro", function()
    ToggleMaystroMenu()
end, false)

-- استقبال أحداث النقر والتفعيل من واجهة NUI (JS)
RegisterNUICallback('itemClicked', function(data, cb)
    local id = data.id
    local enabled = data.enabled
    local val = data.val

    if id == 'godmode' then
        Features.godmode = enabled
        SetEntityInvincible(PlayerPedId(), enabled)
        SetPlayerInvincible(PlayerId(), enabled)
        print("[MAYSTRO] Godmode: " .. tostring(enabled))

    elseif id == 'superJump' then
        Features.superJump = enabled
        print("[MAYSTRO] Super Jump: " .. tostring(enabled))

    elseif id == 'invisible' then
        Features.invisible = enabled
        SetEntityVisible(PlayerPedId(), not enabled, 0)
        print("[MAYSTRO] Invisible: " .. tostring(enabled))

    elseif id == 'punch' then
        Features.punch = enabled
        print("[MAYSTRO] Super Punch: " .. tostring(enabled))

    elseif id == 'noclip' then
        Features.noclip = enabled
        if val then Features.noclipSpeed = val end
        local ped = PlayerPedId()
        SetEntityCollision(ped, not enabled, not enabled)
        FreezeEntityPosition(ped, enabled)
        print("[MAYSTRO] Noclip: " .. tostring(enabled) .. " (Speed: " .. tostring(Features.noclipSpeed) .. ")")

    elseif id == 'ragdoll' then
        Features.ragdoll = enabled
        if enabled then
            SetPedToRagdoll(PlayerPedId(), 3000, 3000, 0, 0, 0, 0)
        end
        print("[MAYSTRO] Ragdoll: " .. tostring(enabled))
    end

    if cb then cb('ok') end
end)

-- استقبال حدث إغلاق المنيو من NUI
RegisterNUICallback('closeMenu', function(data, cb)
    ToggleMaystroMenu(false)
    if cb then cb('ok') end
end)

-- حلقة تكرارية مستمرة لتطبيق مميزات الهاك (Tick Loop)
CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local player = PlayerId()

        -- وضع الخلود (Godmode)
        if Features.godmode then
            sleep = 0
            SetEntityInvincible(ped, true)
            SetPlayerInvincible(player, true)
            SetPedCanRagdoll(ped, false)
            ClearPedBloodDamage(ped)
            ResetPedVisibleDamage(ped)
            ClearPedLastWeaponDamage(ped)
            SetEntityHealth(ped, 200)
        end

        -- قفز خارق (Super Jump)
        if Features.superJump then
            sleep = 0
            SetSuperJumpThisFrame(player)
        end

        -- لكمة خارقة (Super Punch)
        if Features.punch then
            sleep = 0
            SetPlayerMeleeWeaponDamageModifier(player, 100.0)
        end

        -- نو كليب (Noclip)
        if Features.noclip then
            sleep = 0
            local x, y, z = table.unpack(GetEntityCoords(ped, true))
            local dx, dy, dz = 0.0, 0.0, 0.0
            local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(ped)
            local pitch = GetGameplayCamRelativePitch()
            local speed = (Features.noclipSpeed or 2) * 0.4

            -- W / S / Space / Shift
            if IsControlPressed(0, 32) then -- W
                local radH = math.rad(heading)
                local radP = math.rad(pitch)
                dx = dx - math.sin(radH) * speed * math.cos(radP)
                dy = dy + math.cos(radH) * speed * math.cos(radP)
                dz = dz + math.sin(radP) * speed
            end
            if IsControlPressed(0, 33) then -- S
                local radH = math.rad(heading)
                local radP = math.rad(pitch)
                dx = dx + math.sin(radH) * speed * math.cos(radP)
                dy = dy - math.cos(radH) * speed * math.cos(radP)
                dz = dz - math.sin(radP) * speed
            end
            if IsControlPressed(0, 22) then -- Space (Up)
                dz = dz + speed
            end
            if IsControlPressed(0, 21) then -- Shift (Down)
                dz = dz - speed
            end

            SetEntityCoordsNoOffset(ped, x + dx, y + dy, z + dz, true, true, true)
        end

        Wait(sleep)
    end
end)

-- حلقة الاستماع لزر فتح وإغلاق المنيو (F5 - Control ID: 166)
CreateThread(function()
    while true do
        Wait(0)
        -- زر F5 في GTA V / FiveM هو Control 166
        if IsControlJustPressed(0, 166) then
            ToggleMaystroMenu()
        end
    end
end)

-- فتح المنيو تلقائياً أول مرة بعد الحقن
CreateThread(function()
    Wait(300)
    ToggleMaystroMenu(true)
    print("^2[MAYSTRO MENU]^7 Injected & Loaded successfully! Press ^3F5^7 to toggle.")
end)
