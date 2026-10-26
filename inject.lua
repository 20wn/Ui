-- ==============================================================================
--                        MAYSTRO MENU - FIVEM INJECTOR
-- ==============================================================================
-- يقوم برسم واجهة المنيو (UI) مباشرة على الشاشة عبر FiveM DUI
-- يمرر ضغطات الكيبورد والماوس مباشرة إلى الواجهة حتى تستجيب فوراً
-- ==============================================================================

local isMenuVisible = true
local duiObj = nil
local txd = nil
local txn = nil

local WebURL = "https://htmlpreview.github.io/?https://github.com/20wn/Ui/blob/main/index.html"

local Features = {
    godmode = false,
    superJump = false,
    invisible = false,
    punch = false,
    noclip = false,
    noclipSpeed = 2,
    ragdoll = false
}

-- تهيئة الـ DUI لجلب ورسم المنيو
local function InitUI()
    if not duiObj then
        duiObj = CreateDui(WebURL, 1920, 1080)
        while not IsDuiAvailable(duiObj) do
            Wait(50)
        end
        local duiHandle = GetDuiHandle(duiObj)
        txd = CreateRuntimeTxd('maystro_txd')
        txn = CreateRuntimeTextureFromDuiHandle(txd, 'maystro_txn', duiHandle)
        print("^2[MAYSTRO MENU]^7 UI Texture Loaded successfully!")
    end
end

-- حلقة رسم المنيو وتمرير الماوس
CreateThread(function()
    InitUI()
    SetNuiFocus(true, true)

    while true do
        Wait(0)

        if isMenuVisible then
            SetMouseCursorActiveThisFrame()

            -- رسم المنيو على الشاشة
            if txd and txn then
                DrawSprite('maystro_txd', 'maystro_txn', 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
            end

            -- تتبع حركة ونقرات الماوس لتشغيل أزرار المنيو
            if duiObj then
                local mx = GetControlNormal(0, 239)
                local my = GetControlNormal(0, 240)
                local px = math.floor(mx * 1920)
                local py = math.floor(my * 1080)
                SendDuiMouseMove(duiObj, px, py)

                if IsControlJustPressed(0, 237) then
                    SendDuiMouseDown(duiObj, 'left')
                elseif IsControlJustReleased(0, 237) then
                    SendDuiMouseUp(duiObj, 'left')
                end
            end
        end
    end
end)

-- حلقة التقاط أزرار الكيبورد وتمريرها فوراً للواجهة لكي تستجيب وتفتح
CreateThread(function()
    while true do
        Wait(0)
        if duiObj then
            -- زر F5 (Control 166)
            if IsControlJustPressed(0, 166) then
                SendDuiMessage(duiObj, json.encode({ action = 'setKeybind', key = 'F5' }))
                SendDuiMessage(duiObj, json.encode({ action = 'toggleMenu' }))
            -- زر Enter (Control 191 / 18)
            elseif IsControlJustPressed(0, 191) or IsControlJustPressed(0, 18) then
                SendDuiMessage(duiObj, json.encode({ action = 'setKeybind', key = 'Enter' }))
            -- زر Space (Control 22)
            elseif IsControlJustPressed(0, 22) then
                SendDuiMessage(duiObj, json.encode({ action = 'setKeybind', key = 'Space' }))
            -- زر E (Control 38)
            elseif IsControlJustPressed(0, 38) then
                SendDuiMessage(duiObj, json.encode({ action = 'setKeybind', key = 'E' }))
            -- زر Insert (Control 121)
            elseif IsControlJustPressed(0, 121) then
                SendDuiMessage(duiObj, json.encode({ action = 'setKeybind', key = 'Insert' }))
                SendDuiMessage(duiObj, json.encode({ action = 'toggleMenu' }))
            end
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

-- حلقة تفعيل الهاكات في اللعبة
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

            if IsControlPressed(0, 32) then dx = dx - math.sin(h)*speed*math.cos(p); dy = dy + math.cos(h)*speed*math.cos(p); dz = dz + math.sin(p)*speed end
            if IsControlPressed(0, 33) then dx = dx + math.sin(h)*speed*math.cos(p); dy = dy - math.cos(h)*speed*math.cos(p); dz = dz - math.sin(p)*speed end
            if IsControlPressed(0, 22) then dz = dz + speed end
            if IsControlPressed(0, 21) then dz = dz - speed end
            SetEntityCoordsNoOffset(ped, x + dx, y + dy, z + dz, true, true, true)
        end

        Wait(sleep)
    end
end)

print("^2[MAYSTRO MENU]^7 UI Injected & Active! Press F5 or Enter to select keybind.")
