-- ==============================================================================
--                        MAYSTRO MENU - FIVEM EXECUTOR LOADER
-- ==============================================================================
-- هذا الملف مخصص للحقن المباشر عبر الإنجكتر (Injector / Lua Executor)
-- يقوم بإنشاء أو تفعيل الـ NUI وعرض القائمة مباشرة مع تفعيل الأزرار والوظائف
-- ==============================================================================

local ResourceName = GetCurrentResourceName() or "ui"
local isMenuVisible = false

-- 1. تعريف وظائف المنيو (Godmode, SuperJump, etc.)
local Features = {
    godmode = false,
    superJump = false,
    invisible = false,
    punch = false
}

-- 2. إرسال أمر فتح / إغلاق القائمة إلى الـ NUI
local function ToggleMenu(state)
    isMenuVisible = state
    SetNuiFocus(state, state)
    SendNUIMessage({
        action = state and "openMenu" or "closeMenu"
    })
end

-- 3. استقبال النقرات من الـ NUI وتنفيذ الميزات
RegisterNUICallback('itemClicked', function(data, cb)
    local id = data.id
    local enabled = data.enabled

    if id == 'godmode' then
        Features.godmode = enabled
        SetEntityInvincible(PlayerPedId(), enabled)
        print("[MAYSTRO] Godmode set to: " .. tostring(enabled))

    elseif id == 'superJump' then
        Features.superJump = enabled
        print("[MAYSTRO] Super Jump set to: " .. tostring(enabled))

    elseif id == 'invisible' then
        Features.invisible = enabled
        SetEntityVisible(PlayerPedId(), not enabled, 0)
        print("[MAYSTRO] Invisibility set to: " .. tostring(enabled))

    elseif id == 'punch' then
        Features.punch = enabled
        print("[MAYSTRO] Super Punch set to: " .. tostring(enabled))
    end

    if cb then cb('ok') end
end)

-- استقبال حدث إغلاق القائمة
RegisterNUICallback('closeMenu', function(data, cb)
    ToggleMenu(false)
    if cb then cb('ok') end
end)

-- 4. حلقة لتنفيذ ميزات الهاك التي تحتاج تحديث مستمر (Tick Loop)
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

-- 5. فتح وإغلاق القائمة بضغط زر (F5 افتراضياً، كود الزر: 166)
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 166) then -- F5
            ToggleMenu(not isMenuVisible)
        end
    end
end)

-- 6. فتح القائمة تلقائياً فور الحقن
CreateThread(function()
    Wait(200)
    ToggleMenu(true)
    print("^2[MAYSTRO MENU]^7 Injected & Loaded successfully! Press F5 to toggle.")
end)
