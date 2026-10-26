-- ==============================================================================
--                        MAYSTRO MENU - FIVEM EXECUTOR
-- ==============================================================================
-- تم إزالة F5: التحكم بالكامل والزر يحدده المستخدم عبر واجهة الـ JS (Keybind Box)
-- ==============================================================================

local Features = {
    godmode = false,
    superJump = false,
    invisible = false,
    punch = false
}

-- إعطاء الفوكس للـ NUI فوراً لكي يستقبل ضغط الزر من الـ JS
SetNuiFocus(true, true)

-- استقبال النقرات من الـ NUI وتنفيذ ميزات الهاك
RegisterNUICallback('itemClicked', function(data, cb)
    local id = data.id
    local enabled = data.enabled

    if id == 'godmode' then
        Features.godmode = enabled
        SetEntityInvincible(PlayerPedId(), enabled)
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
        print("[MAYSTRO] Punch: " .. tostring(enabled))
    end

    if cb then cb('ok') end
end)

-- حلقة الميزات المستمرة
CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()

        if Features.godmode then
            sleep = 0
            SetEntityInvincible(ped, true)
            SetPlayerInvincible(PlayerId(), true)
        end

        if Features.superJump then
            sleep = 0
            SetSuperJumpThisFrame(PlayerId())
        end

        if Features.punch then
            sleep = 0
            SetPlayerMeleeWeaponDamageModifier(PlayerId(), 100.0)
        end

        Wait(sleep)
    end
end)

print("^2[MAYSTRO MENU]^7 Ready - select your keybind in UI!")
