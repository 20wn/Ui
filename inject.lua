-- ==============================================================================
--                        MAYSTRO MENU - FIVEM INJECTOR
-- ==============================================================================
-- 1. عند الحقن يظهر لك مربع اختيار الزر: Set Keybind (Enter key ...)
-- 2. اضغط على أي زر في الكيبورد (مثلاً F5, M, X, Insert, E, إلخ...)
-- 3. سيتم كتابة الزر الذي اخترته فوراً داخل المربع ثم يفتح لك المنيو
-- 4. وسيصبح ذلك الزر هو زر فتح وإغلاق المنيو دائماً
-- ==============================================================================

local isMenuVisible = true
local duiObj = nil
local txd = nil
local txn = nil

-- رابط المنيو مع كسر الكاش لضمان جلب التحديث فوراً
local WebURL = "https://htmlpreview.github.io/?https://github.com/20wn/Ui/blob/main/index.html?v=" .. tostring(GetGameTimer())

local Features = {
    godmode = false,
    superJump = false,
    invisible = false,
    punch = false,
    noclip = false,
    noclipSpeed = 2,
    ragdoll = false
}

-- خريطة جميع أزرار الكيبورد في FiveM لاكتشاف أي زر يضغطه اللاعب
local KeyMap = {
    [166] = "F5", [167] = "F6", [168] = "F7", [169] = "F8", [56] = "F9", [57] = "F10", [344] = "F11",
    [288] = "F1", [289] = "F2", [170] = "F3",
    [121] = "INSERT", [211] = "DELETE", [212] = "HOME", [213] = "PAGEUP", [214] = "PAGEDOWN",
    [244] = "M", [73] = "X", [74] = "H", [38] = "E", [44] = "Q", [45] = "R", [47] = "G", [23] = "F",
    [249] = "N", [246] = "Y", [245] = "T",
    [191] = "ENTER", [18] = "ENTER", [22] = "SPACE", [21] = "SHIFT", [36] = "CTRL", [19] = "ALT",
    [157] = "1", [158] = "2", [159] = "3", [160] = "4", [164] = "5", [165] = "6",
    [161] = "7", [162] = "8", [163] = "9", [156] = "0", [243] = "~"
}

local chosenKeyControl = nil
local chosenKeyName = nil

-- تهيئة الـ DUI
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

-- دالة فتح وإغلاق المنيو
function ToggleMenu(state)
    if state == nil then
        isMenuVisible = not isMenuVisible
    else
        isMenuVisible = state
    end

    SetNuiFocus(isMenuVisible, isMenuVisible)
    if isMenuVisible then
        print("^2[MAYSTRO MENU]^7 Menu Opened")
    else
        print("^3[MAYSTRO MENU]^7 Menu Closed")
    end
end

-- حلقة رسم المنيو وتتبع الماوس
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

            -- تتبع حركة ونقرات الماوس
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

-- حلقة التقاط الزر الذي يضغطه اللاعب فوراً وتمريره للمربع
CreateThread(function()
    while true do
        Wait(0)
        if duiObj then
            -- المرحلة 1: اللاعب يضغط الزر الذي يريده
            if not chosenKeyControl then
                for controlId, keyName in pairs(KeyMap) do
                    if IsControlJustPressed(0, controlId) or IsDisabledControlJustPressed(0, controlId) then
                        chosenKeyControl = controlId
                        chosenKeyName = keyName
                        print("^2[MAYSTRO MENU]^7 Key Chosen: " .. keyName)
                        -- إرسال الحرف المختار للـ UI
                        SendDuiMessage(duiObj, json.encode({ action = 'setKeybind', key = keyName }))
                        break
                    end
                end
            else
                -- المرحلة 2: بعد اختيار الزر، يصبح هذا الزر هو زر فتح وإغلاق المنيو!
                if IsControlJustPressed(0, chosenKeyControl) or IsDisabledControlJustPressed(0, chosenKeyControl) then
                    ToggleMenu()
                    SendDuiMessage(duiObj, json.encode({ action = 'toggleMenu' }))
                end
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

print("^2[MAYSTRO MENU]^7 Injected! Press any key to set your keybind.")
