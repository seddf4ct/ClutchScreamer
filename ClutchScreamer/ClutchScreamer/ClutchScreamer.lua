-- ClutchScreamer v3.3
-- Works with OSR startLights server script OR standalone
-- Wheelspin detector after lights out

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
local hasEvent  = false
local startTime = 0
local delayTime = 0

-- Wheelspin detector
local spinPhase     = "none"   -- none | LIFT | MORE | GOOD | spinFade
local spinTimer     = 0
local spinFadeAlpha = 1.0
local SPIN_DURATION = 2.5
local SPIN_FADE     = 1.5
local SPIN_MONITOR  = 6.0     -- seconds after lights out to monitor spin
local spinMonTimer  = 0
local SPIN_HIGH     = 0.15    -- slip ratio above this = too much spin
local SPIN_LOW      = 0.02    -- slip ratio below this = not enough

local HOLD_COUNTDOWN = 10000
local OUT_DURATION   = 2.0
local FLASH_INTERVAL = 0.07
local FADE_SPEED     = 1.2

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
    if sim.sessionTimeLeft > prevTimeLeft + 5 then
        outFired  = false
        hasEvent  = false
        phase     = "idle"
        spinPhase = "none"
    end
    prevTimeLeft = sim.sessionTimeLeft

    local timeToGo
    if hasEvent then
        timeToGo = (startTime + delayTime) - sim.currentSessionTime
    else
        timeToGo = sim.timeToSessionStart
    end

    if not outFired and timeToGo > 0 and timeToGo <= HOLD_COUNTDOWN then
        if phase ~= "holding" then
            phase      = "holding"
            flashTimer = 0
        end
    end

    if not outFired and timeToGo <= 0 and (hasEvent or sim.isSessionStarted) then
        outFired      = true
        phase         = "OUT"
        clutchTimer   = OUT_DURATION
        fadeAlpha     = 1.0
        flashTimer    = 0
        spinMonTimer  = SPIN_MONITOR
        spinPhase     = "none"
        beep:setCurrentTime(0)
        beep:setVolume(volume)
        beep:play()
    end

    -- Wheelspin monitoring after lights out
    if spinMonTimer > 0 then
        spinMonTimer = spinMonTimer - dt

        local car = ac.getCar(0)
        if car ~= nil and car.speedKmh > 5 then
            -- Average driven wheel slip
            local slip = 0
            local count = 0
            for i = 0, 3 do
                local w = car.wheels[i]
                if w ~= nil then
                    slip  = slip + math.abs(w.slipRatio)
                    count = count + 1
                end
            end
            if count > 0 then slip = slip / count end

            local newSpinPhase
            if slip > SPIN_HIGH then
                newSpinPhase = "LIFT"
            elseif slip < SPIN_LOW then
                newSpinPhase = "MORE"
            else
                newSpinPhase = "GOOD"
            end

            if newSpinPhase ~= spinPhase then
                spinPhase     = newSpinPhase
                spinTimer     = SPIN_DURATION
                spinFadeAlpha = 1.0
            end
        end

        if spinMonTimer <= 0 then
            spinPhase = "spinFade"
        end
    end

    -- Timers
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

    if spinTimer > 0 then
        spinTimer = spinTimer - dt
        if spinTimer <= 0 then
            spinPhase     = "spinFade"
            spinFadeAlpha = 1.0
        end
    end

    if spinPhase == "spinFade" then
        spinFadeAlpha = spinFadeAlpha - SPIN_FADE * dt
        if spinFadeAlpha <= 0 then
            spinFadeAlpha = 0
            spinPhase     = "none"
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

    -- Wheelspin overlay
    if spinPhase == "LIFT" or spinPhase == "MORE" or spinPhase == "GOOD" then
        local text, bgCol, textCol
        if spinPhase == "LIFT" then
            text    = "LIFT!"
            bgCol   = rgbm(0.9, 0.0, 0.0, 0.75)
            textCol = rgbm(1, 1, 0, 1)
        elseif spinPhase == "MORE" then
            text    = "MORE THROTTLE!"
            bgCol   = rgbm(0.0, 0.3, 0.9, 0.75)
            textCol = rgbm(1, 1, 1, 1)
        else
            text    = "PERFECT LAUNCH!"
            bgCol   = rgbm(0.0, 0.7, 0.1, 0.75)
            textCol = rgbm(1, 1, 1, 1)
        end

        ui.drawRectFilled(vec2(0, H - 56), vec2(W, H), bgCol)

        ui.pushFont(ui.Font.Title)
        local ts = ui.measureText(text)
        local cx = (W - ts.x) * 0.5
        local cy = H - 52
        ui.drawText(text, vec2(cx + 2, cy + 2), rgbm(0, 0, 0, 1))
        ui.drawText(text, vec2(cx, cy), textCol)
        ui.popFont()

    elseif spinPhase == "spinFade" and spinFadeAlpha > 0 then
        local a = math.max(0, spinFadeAlpha)
        ui.drawRectFilled(vec2(0, H - 56), vec2(W, H), rgbm(0, 0, 0, 0.4 * a))
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
    ui.separator()
    if hasEvent then
        ui.text('Mode: OSR server')
    else
        ui.text('Mode: Standalone')
    end
end
