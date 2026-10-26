-- ==============================================================================
--                        MAYSTRO MENU - FIVEM INJECTOR
-- ==============================================================================
-- هذا الملف تضعه أو تنسخ ما بداخله مباشرة في الإنجكتر عند فتح اللعبة
-- يقوم بعرض واجهة الـ UI مباشرة على الشاشة عبر محرك FiveM DUI / NUI
-- رابط المستودع: https://github.com/20wn/Ui.git
-- اختصار فتح / إغلاق المنيو: زر F5
-- ==============================================================================

local isMenuVisible = true
local duiObj = nil
local txd = nil
local txn = nil

-- رابط واجهة المستخدم (HTML) من المستودع
local WebURL = "https://htmlpreview.github.io/?https://github.com/20wn/Ui/blob/main/index.html"

-- ميزات الهاك
local Features = {
    godmode = false,
    superJump = false,
    invisible = false,
    punch = false,
    noclip = false,
    noclipSpeed = 2,
    ragdoll = false
}

-- تهيئة محرك العرض للـ UI
local function SetupUI()
    if not duiObj then
        duiObj = CreateDui(WebURL, 1920, 1080)
        while not IsDuiAvailable(duiObj) do
            Wait(50)
        end
        local duiHandle = GetDuiHandle(duiObj)
        txd = CreateRuntimeTxd('maystro_txd')
        txn = CreateRuntimeTextureFromDuiHandle(txd, 'maystro_txn', duiHandle)
        print("^2[MAYSTRO MENU]^7 UI Texture initialized successfully!")
    end
end

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
        print("^2[MAYSTRO MENU]^7 Opened (Press F5 to close)")
    else
        print("^3[MAYSTRO MENU]^7 Closed (Press F5 to open)")
    end
end

-- أمر لفتح / إغلاق المنيو
RegisterCommand("maystro", function()
    ToggleMaystroMenu()
end, false)

-- حلقة رسم واجهة الـ UI على الشاشة وتمرير حركة ونقرات الماوس
CreateThread(function()
    SetupUI()
    ToggleMaystroMenu(true)

    while true do
        Wait(0)

        if isMenuVisible then
            -- إظهار مؤشر الماوس
            SetMouseCursorActiveThisFrame()

            -- رسم واجهة الـ UI كطبقة كاملة فوق شاشة اللعبة
            if txd and txn then
                DrawSprite('maystro_txd', 'maystro_txn', 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
            end

            -- تتبع حركة الماوس وإرسالها للـ UI
            if duiObj then
                local mx = GetControlNormal(0, 239)
                local my = GetControlNormal(0, 240)
                local px = math.floor(mx * 1920)
                local py = math.floor(my * 1080)
                SendDuiMouseMove(duiObj, px, py)

                -- النقر بزر الماوس الأيسر
                if IsControlJustPressed(0, 237) then
                    SendDuiMouseDown(duiObj, 'left')
                elseif IsControlJustReleased(0, 237) then
                    SendDuiMouseUp(duiObj, 'left')
                end
            end
        end
    end
end)

-- حلقة فتح / إغلاق المنيو بزر F5 (Control 166)
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 166) then -- F5
            ToggleMaystroMenu()
        end
    end
end)

-- استقبال نقرات الأزرار من الـ UI
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

RegisterNUICallback('closeMenu', function(data, cb)
    ToggleMaystroMenu(false)
    if cb then cb('ok') end
end)

-- حلقة تنفيذ قدرات الهاك (Godmode, SuperJump, Punch, Noclip)
CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local player = PlayerId()

        if Features.godmode then
            sleep = 0
            SetEntityInvincible(ped, true)
            SetPlayerInvincible(player, true)
            ClearPedBloodDamage(ped)
            SetEntityHealth(ped, 200)
        end

        if Features.superJump then
            sleep = 0
            SetSuperJumpThisFrame(player)
        end

        if Features.punch then
            sleep = 0
            SetPlayerMeleeWeaponDamageModifier(player, 100.0)
        end

        if Features.noclip then
            sleep = 0
            local x, y, z = table.unpack(GetEntityCoords(ped, true))
            local speed = (Features.noclipSpeed or 2) * 0.4
            local h = math.rad(GetGameplayCamRelativeHeading() + GetEntityHeading(ped))
            local p = math.rad(GetGameplayCamRelativePitch())
            local dx, dy, dz = 0.0, 0.0, 0.0

            if IsControlPressed(0, 32) then -- W
                dx = dx - math.sin(h)*speed*math.cos(p)
                dy = dy + math.cos(h)*speed*math.cos(p)
                dz = dz + math.sin(p)*speed
            end
            if IsControlPressed(0, 33) then -- S
                dx = dx + math.sin(h)*speed*math.cos(p)
                dy = dy - math.cos(h)*speed*math.cos(p)
                dz = dz - math.sin(p)*speed
            end
            if IsControlPressed(0, 22) then -- Space
                dz = dz + speed
            end
            if IsControlPressed(0, 21) then -- Shift
                dz = dz - speed
            end
            SetEntityCoordsNoOffset(ped, x + dx, y + dy, z + dz, true, true, true)
        end

        Wait(sleep)
    end
end)

print("^2===========================================^7")
print("^2  [MAYSTRO MENU] Loaded & Ready!           ^7")
print("^2  Press F5 to Toggle Menu (Open / Close)   ^7")
print("^2===========================================^7")
