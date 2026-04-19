-- ClutchScreamer v3.1
-- Works with OSR startLights server script OR standalone

local sim  = ac.getSim()
local beep = ui.MediaPlayer('beep.wav')

local volume = tonumber(ac.load('cs_volume')) or 1.0

local phase        = "idle"
local clutchTimer  = 0
local fadeAlpha    = 1.0
local flashTimer   = 0
local outFired     = false
local prevTimeLeft = sim.sessionTimeLeft

-- OSR event data
local hasEvent   = false
local startTime  = 0
local delayTime  = 0

local HOLD_COUNTDOWN = 10000  -- ms
local OUT_DURATION   = 2.0
local FLASH_INTERVAL = 0.07
local FADE_SPEED     = 1.2

-- Listen for OSR startLights server event
triggerStart = ac.OnlineEvent({
    key       = ac.StructItem.key("Start Lights"),
    startTime = ac.StructItem.float(),
    delayTime = ac.StructItem.float()
}, function(sender, message)
    startTime = message.startTime
    delayTime = message.delayTime
    hasEvent  = true
    outFired  = false
    phase     = "idle"
end, ac.SharedNamespace.ServerScript)

function script.update(dt)
    -- Reset on new session
    if sim.sessionTimeLeft > prevTimeLeft + 5 then
        outFired = false
        hasEvent = false
        phase    = "idle"
    end
    prevTimeLeft = sim.sessionTimeLeft

    local timeToGo

    if hasEvent then
        -- OSR mode: use server event timing
        timeToGo = (startTime + delayTime) - sim.currentSessionTime
    else
        -- Standalone mode: use sim.timeToSessionStart
        timeToGo = sim.timeToSessionStart
    end

    -- Show CLUTCH! in last 10 seconds
    if not outFired and timeToGo > 0 and timeToGo <= HOLD_COUNTDOWN then
        if phase ~= "holding" then
            phase      = "holding"
            flashTimer = 0
        end
    end

    -- Lights out
    if not outFired and timeToGo <= 0 and (hasEvent or sim.isSessionStarted) then
        outFired    = true
        phase       = "OUT"
        clutchTimer = OUT_DURATION
        fadeAlpha   = 1.0
        flashTimer  = 0
        beep:setCurrentTime(0)
        beep:setVolume(volume)
        beep:play()
    end

    if phase == "OUT" then
        clutchTimer = clutchTimer - dt
        flashTimer  = flashTimer  + dt
        if clutchTimer <= 0 then
            phase     = "fade"
            fadeAlpha = 1.0
        end
    elseif phase == "holding" then
        flashTimer = flashTimer + dt
    elseif phase == "fade" then
        fadeAlpha = fadeAlpha - FADE_SPEED * dt
        if fadeAlpha <= 0 then
            fadeAlpha = 0
            phase     = "idle"
        end
    end
end

function script.windowMain(dt)
    local W, H = 400, 220

    if phase == "holding" then
        local pulse = (math.sin(flashTimer * 6) + 1) * 0.5
        ui.drawRectFilled(vec2(0, 0), vec2(W, H), rgbm(0.3 * pulse, 0, 0.5 * pulse, 0.6))

        ui.pushFont(ui.Font.Title)
        local text = "CLUTCH!"
        local ts   = ui.measureText(text)
        local cx   = (W - ts.x) * 0.5
        local cy   = (H - ts.y) * 0.5 - 12
        ui.drawText(text, vec2(cx + 2, cy + 2), rgbm(0, 0, 0, 0.8))
        ui.drawText(text, vec2(cx, cy), rgbm(1, 0.85, 1, 1))
        ui.popFont()

        local sub = "HOLD THE CLUTCH!"
        local ss  = ui.measureText(sub)
        ui.drawText(sub, vec2((W - ss.x) * 0.5, cy + ts.y + 4), rgbm(0.8, 0.5, 1, 1))

    elseif phase == "OUT" then
        local flashOn = math.floor(flashTimer / FLASH_INTERVAL) % 2 == 0
        ui.drawRectFilled(vec2(0, 0), vec2(W, H),
            flashOn and rgbm(0.9, 0.05, 0.0, 0.7) or rgbm(1.0, 0.55, 0.0, 0.6))

        ui.pushFont(ui.Font.Title)
        local text = "CLUTCH OUT!"
        local ts   = ui.measureText(text)
        local cx   = (W - ts.x) * 0.5
        local cy   = (H - ts.y) * 0.5 - 12
        ui.drawText(text, vec2(cx + 2, cy + 2), rgbm(0, 0, 0, 0.8))
        ui.drawText(text, vec2(cx, cy), rgbm(1, 1, 1, 1))
        ui.popFont()

        local sub = "GO GO GO!"
        local ss  = ui.measureText(sub)
        ui.drawText(sub, vec2((W - ss.x) * 0.5, cy + ts.y + 4), rgbm(1, 0.85, 0.1, 1))

    elseif phase == "fade" then
        local a = math.max(0, fadeAlpha)
        ui.pushFont(ui.Font.Title)
        local text = "CLUTCH OUT!"
        local ts   = ui.measureText(text)
        local cx   = (W - ts.x) * 0.5
        local cy   = (H - ts.y) * 0.5 - 12
        ui.drawText(text, vec2(cx, cy), rgbm(1, 1, 1, a))
        ui.popFont()
    end
end

function script.windowSettings(dt)
    ui.text('Volume: ' .. math.floor(volume * 100) .. '%')
    if ui.button('-10%') then
        volume = math.max(0, volume - 0.1)
        ac.store('cs_volume', tostring(volume))
    end
    if ui.button('+10%') then
        volume = math.min(1, volume + 0.1)
        ac.store('cs_volume', tostring(volume))
    end
    if ui.button('Test beep') then
        beep:setCurrentTime(0)
        beep:setVolume(volume)
        beep:play()
    end
    if hasEvent then
        ui.text('Mode: OSR server')
    else
        ui.text('Mode: Standalone')
    end
end
