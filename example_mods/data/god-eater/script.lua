function onCreate()
    if difficulty ~= 0 then 
        addLuaScript('extra keys')
    end
end

function onCountdownStarted()
    triggerEvent('Activate extra keys', 9)
    setFPS(framerate)
end

local allowEnd = false
function onEndSong()
	-- Block the first countdown and start a timer of 0.8 seconds to play the dialogue
	if not allowEnd and isStoryMode then
        endCutscene()
		allowEnd = true;
		return Function_Stop;        
	end    
	return Function_Continue;
end


local allowCountdown = false
function onStartCountdown()
	-- Block the first countdown and start a timer of 0.8 seconds to play the dialogue
	if not allowCountdown and not seenCutscene and isStoryMode then
        godIntro()
        
		allowCountdown = true;
		return Function_Stop;   
	end    
	return Function_Continue;
end

function godIntro() 
    setFPS(120) --shaggy mod cutscenes NEED to be 120 fps, or else they will be sped up/slowed down, no idea why it even happens tbh, since it uses timers
    characterPlayAnim('dad','back', true)
    runTimer('godP1', 3, 1)
    runTimer('shk', 0.002, 1)
end

local cs_time = 0
local cs_wait = false;
local cs_zoom = 0.65;

local timerthing = 0.002 --timers are being affected by fps and im really fucking confused rn

local endDialStuff = false





local sShake = 0

local godCutEndThing = false



local debrisShit = {
    {-300, -120, 'ceil', 1, 1, -4, -40},
    {0, -120, 'ceil', 1, 1, -4, -51},
    {200, -120, 'ceil', 1, 1, -4, 40}
};

local stopCutsceneTimer = false

local dfS = 1
local toDfS = 1

function onTimerCompleted(tag, loops, loopsLeft)

    if tag == 'shk' then 
        if not getProperty('startedCountdown') then 
            if (sShake > 0) then
				sShake = sShake - 0.5;
				setProperty('camGame.angle', getRandomFloat(-sShake, sShake));
			end
            runTimer('shk', 0.002, 1)
        end
    elseif tag == 'shkUp' then 
        sShake = sShake+0.51;
        if not godCutEndThing then 
            runTimer('shkUp', 0.002, 1)
        end
    elseif tag == 'godP1' then 
        runTimer('godP2', 0.85, 1)
        characterPlayAnim('dad','snap', true)
    elseif tag == 'godP2' then 
        playSound('snap')
        playSound('undSnap')
        sShake = 10;
        runTimer('godP3', 1.5, 1)
        runTimer('snap', 0.06, 1)
    elseif tag == 'godP3' then 
        runTimer('shkUp', 0.002, 1)
        runTimer('godP4', 1, 1)
    elseif tag == 'godP4' then 

        --spawn debris

        for i = 0,#debrisShit-1 do 
            local deb = 'debrisExplosion'..i
            makeAnimatedLuaSprite(deb, 'bgs/god_bg', debrisShit[i+1][1], debrisShit[i+1][2]);
            addAnimationByPrefix(deb, 'idle', 'deb_'..debrisShit[i+1][3], 30)
            objectPlayAnimation(deb,'idle');
            --debris.frameWidth * (debrisShit[i][3] / 0.75)
            local width = math.floor(getProperty(deb..'.frameWidth') * (debrisShit[i+1][4]/0.75))	
            setProperty(deb..'.scale.x', width/getProperty(deb..'.frameWidth'))
            setProperty(deb..'.scale.y', width/getProperty(deb..'.frameWidth'))
            setScrollFactor(deb, debrisShit[i+1][4], debrisShit[i+1][4])
            addLuaSprite(deb, true);
            updateHitbox(deb)
        end

        sShake = sShake + 5
        playSound('ascend')
        characterPlayAnim('bf','hurt', true)
        setProperty('boyfriend.specialAnim', true)
        runTimer('hit', 0.4, 1)
        runTimer('scared', 1, 1)
        runTimer('fly', 2, 1)
        --cutend
        triggerEvent('cutend')
        godCutEndThing = true --have duped one for cutscene thing
    elseif tag == 'hit' then 
        --movegf
        characterPlayAnim('bf','hurt', true)
        setProperty('boyfriend.specialAnim', true)
        triggerEvent('movegf')
    elseif tag == 'scared' then 
        characterPlayAnim('bf','scared', true)
        setProperty('boyfriend.specialAnim', true)
    elseif tag == 'fly' then 
        playSound('shagFly')
        characterPlayAnim('dad','idle', true)
        runTimer('introEnd', 1.5, 1)
        --movesh
        triggerEvent('moveshag')
    elseif tag == 'introEnd' then 
        startCountdown()

    elseif tag == 'snap' then 
        characterPlayAnim('dad','snapped', true)




    elseif tag == 'cs' then 

            if cs_time == 200 then --i wish there was a switch case for lua
                setProperty('camFollow.x', getProperty('camFollow.x')-500)
                setProperty('camFollow.y', getProperty('camFollow.y')-200)
            elseif cs_time == 400 then 
                characterPlayAnim('dad','smile', true)
            elseif cs_time == 500 then 
                if not cs_wait then 
                    setProperty('inCutscene', true)
                    addLuaScript('dialogue')
                    triggerEvent('restartThing', 'cs/sh_amazing')
                    cs_wait = true; 
                end
            elseif cs_time == 700 then
                playSound('burst') 
                godCutEndThing = false
                triggerEvent('stopShit')
                characterPlayAnim('dad','stand', true)
                setProperty('dad.x', 100)
                setProperty('dad.y', 100)
                setProperty('gf.x', 400)
                setProperty('gf.y', 130)
                setProperty('boyfriend.x', 770)
                setProperty('boyfriend.y', 450)
                setProperty('gf.scrollFactor.x', 0.95)
				setProperty('gf.scrollFactor.y', 0.95)
				local width = math.floor(getProperty('gf.width'))	
				setProperty('gf.scale.x', width/getProperty('gf.frameWidth'))
				setProperty('gf.scale.y', width/getProperty('gf.frameWidth'))

                setProperty('camFollow.x', getProperty('camFollow.x')+100)
                setProperty('camFollow.y', getProperty('boyfriend.y'))
                setProperty('camFollowPos.x', getProperty('camFollow.x'))
                setProperty('camFollowPos.y', getProperty('camFollow.y'))
                cs_zoom = 0.8
                setProperty('camGame.zoom', cs_zoom)

                setProperty('scoob.x', -300)
                setProperty('scoob.y', 290)
                setProperty('scoob.flipX', true)
                triggerEvent('Shaggy trail alpha', '1')
                
            elseif cs_time == 800 then 
                if not cs_wait then 
                    setProperty('inCutscene', true)
                    triggerEvent('restartThing', 'cs/sh_expo')
                    cs_wait = true;
                    --cs_reset = true;
                    playMusic('cs_finale', 1, true)
                end
                
            elseif cs_time == 840 then 
                playSound('exit')
                setProperty('doorFrame.alpha', 1)
                setProperty('doorFrame.x', getProperty('doorFrame.x')-90)
                setProperty('doorFrame.y', getProperty('doorFrame.y')-130)
                toDfS = 700;
            elseif cs_time == 1150 then 
                if not cs_wait then 
                    setProperty('inCutscene', true)
                    triggerEvent('restartThing', 'cs/sh_bye')
                    triggerEvent('setFinalDialEvent')
                    cs_wait = true;
                    --cs_reset = true;
                end
            elseif cs_time == 1400 then 
                playSound('exit')
                toDfS = 1;
            elseif cs_time == 1645 then 
                makeLuaSprite('cs_black', '', -500, -500);
                makeGraphic('cs_black', 3000, 2000, '0xFF000000')
                setScrollFactor('cs_black', 0, 0);
                addLuaSprite('cs_black', true);
                setProperty('cs_black.alpha', 0)
                cs_wait = true
                cs_time = cs_time + 1
                playMusic('cs_credits', 1, false)

                runTimer('showTitle', 3)
                runTimer('showThanks', 3+2.5)
                runTimer('showEnding', 3+5)
                runTimer('endCreds', 3+5+12)

            elseif cs_time == 1646 then 
                setProperty('cs_black.alpha', getProperty('cs_black.alpha')+0.0025)
            elseif cs_time == 1651 then 
                endSong();
            end
    
    
			if (cs_time > 700) then
				objectPlayAnimation('scoob', 'idle');
            end
			if (cs_time > 1150) then
                setProperty('scoob.alpha', getProperty('scoob.alpha') - 0.004)
                setProperty('dad.alpha', getProperty('dad.alpha') - 0.004)
            end
    
            setProperty('dad.specialAnim', true) --fuck you psych
            setProperty('dad.idleSuffix', 'fuck you')
            setProperty('dad.stunned', true)
            setProperty('dad.debugMode', true)
    
            setProperty('gf.specialAnim', true) --fuck you psych
            setProperty('gf.stunned', true)
    
    
    
            setProperty('camGame.zoom', getProperty('camGame.zoom') + (cs_zoom - getProperty('camGame.zoom'))/12)
            setProperty('camGame.angle', getProperty('camGame.angle') + (0 - getProperty('camGame.angle'))/12)
    
            if endDialStuff then 
                cs_wait = false;
                setProperty('inCutscene', false)
                endDialStuff = false
            end
    
    
            if not cs_wait then
                cs_time = cs_time + 1
            end
            if not stopCutsceneTimer then 
                dfS = dfS + ((toDfS - dfS) / 18);
                local width = math.floor(dfS)	
                setProperty('doorFrame.scale.x', width/getProperty('doorFrame.frameWidth'))
                setProperty('doorFrame.scale.y', width/getProperty('doorFrame.frameWidth'))
                runTimer('cs', timerthing, 1)
            end
            


    elseif tag == 'showTitle' then 
        
        makeLuaSprite('title', 'sh_title', screenWidth / 2 - 400, screenHeight / 2 - 300);

        local width = math.floor(getProperty('title.width')*1.2)	
        setProperty('title.scale.x', width/getProperty('title.frameWidth'))
        setProperty('title.scale.y', width/getProperty('title.frameWidth'))
        setProperty('title.scrollFactor.x', 0)
        setProperty('title.scrollFactor.y', 0)

        setProperty('title.offset.x', (getProperty('title.frameWidth')-getProperty('title.width'))*0.5)
        setProperty('title.offset.y', (getProperty('title.frameHeight')-getProperty('title.height'))*0.5)
        --offset.x = (frameWidth - width) * 0.5;
		--offset.y = (frameHeight - height) * 0.5;

        addLuaSprite('title', true)
    elseif tag == 'showThanks' then 
        stopCutsceneTimer = true
        local count = 0 
        local textshit = {"T", "H", "A", "N", "K", "S", " ", "F", "O", "R", " ", "P", "L", "A", "Y", "I", "N", "G",
        " ", "T", "H", "I", "S", " ", "M", "O", "D"} --ik its dumb but idc it took like 3 hours to get this to work
        local x = -139 --got from tracing on og mod
        local y = screenHeight / 2 + 300
        local consecutiveSpaces = 0
        local xPos = 0
        local lastWasSpace = true
        local lastMadeLetter = 0
        for i = 0,#textshit-1 do
            local n = 'thank'..lastMadeLetter 
            local letter = textshit[count+1]

            if letter == " " then 
                consecutiveSpaces = consecutiveSpaces + 1
                lastWasSpace = true
            else 
                if lastMadeLetter > 0 then 
                    xPos = getProperty('thank'..(lastMadeLetter-1)..'.x') + getProperty('thank'..(lastMadeLetter-1)..'.width')
                else 
                    lastWasSpace = false
                end
                if consecutiveSpaces > 0 then 
                    xPos = xPos + (40*consecutiveSpaces)
                end
                consecutiveSpaces = 0
                
                makeAnimatedLuaSprite(n, 'alphabet', xPos,y);
                addAnimationByPrefix(n,'idle', string.upper(letter)..' bold', 24, true);
                objectPlayAnimation(n, 'idle');
                updateHitbox(n)
                addLuaSprite(n, true)
                
                lastMadeLetter = lastMadeLetter+1
            end
            count = count + 1
        end
        for i = 0, lastMadeLetter-1 do 
            local n = 'thank'..i
            setProperty(n..'.x', getProperty(n..'.x')+x)
        end

    elseif tag == 'showEnding' then 
        playSound('ending')

        local count = 0 
        local textshit = {"M",'A','I','N', ' ', 'E', 'N', 'D', 'I', 'N', 'G'}
        local x = 202.5
        local y = screenHeight / 2 + 380
        local consecutiveSpaces = 0
        local xPos = 0
        local lastWasSpace = true
        local lastMadeLetter = 0
        for i = 0,#textshit-1 do
            local n = 'ending'..lastMadeLetter 
            local letter = textshit[count+1]

            if letter == " " then 
                consecutiveSpaces = consecutiveSpaces + 1
                lastWasSpace = true
            else 
                if lastMadeLetter > 0 then 
                    xPos = getProperty('ending'..(lastMadeLetter-1)..'.x') + getProperty('ending'..(lastMadeLetter-1)..'.width')
                end
                if consecutiveSpaces > 0 then 
                    xPos = xPos + (40*consecutiveSpaces)
                end
                consecutiveSpaces = 0
                
                makeAnimatedLuaSprite(n, 'alphabet', xPos,y);
                addAnimationByPrefix(n,'idle', string.upper(letter)..' bold', 24, true);
                objectPlayAnimation(n, 'idle');
                updateHitbox(n)
                addLuaSprite(n, true)
                lastMadeLetter = lastMadeLetter+1
            end
            count = count + 1
        end
        for i = 0, lastMadeLetter-1 do 
            local n = 'ending'..i
            setProperty(n..'.x', getProperty(n..'.x')+x)
        end

    elseif tag == 'endCreds' then 
        endSong();
    end
end


local grav = 0.15;

local vsp = {-20,-20,-20}

function onUpdate(elapsed)

    if godCutEndThing and not getProperty('startedCountdown') then 
        for i = 0,#debrisShit-1 do 
            local deb = 'debrisExplosion'..i
            local hsp = debrisShit[i+1][7]/2
            vsp[i+1] = vsp[i+1] + grav

            setProperty(deb..'.x', getProperty(deb..'.x') + hsp);
            setProperty(deb..'.y', getProperty(deb..'.y') + vsp[i+1]);
            setProperty(deb..'.angle', getProperty(deb..'.angle') - (hsp/2));
        end
    end

end

function onDestroy()
    setFPS(framerate)
end

function setFPS(n)

    setPropertyFromClass('ClientPrefs', 'framerate', n)  --funni code that definity cant be used for fucking breaking the game
    if(getPropertyFromClass('ClientPrefs', 'framerate') > getPropertyFromClass('flixel.FlxG', 'drawFramerate')) then
        setPropertyFromClass('flixel.FlxG', 'updateFramerate', getPropertyFromClass('ClientPrefs', 'framerate'))
        setPropertyFromClass('flixel.FlxG', 'drawFramerate', getPropertyFromClass('ClientPrefs', 'framerate'))
    else
        setPropertyFromClass('flixel.FlxG', 'drawFramerate', getPropertyFromClass('ClientPrefs', 'framerate'))
        setPropertyFromClass('flixel.FlxG', 'updateFramerate', getPropertyFromClass('ClientPrefs', 'framerate'))
    end
end

function endCutscene()

    setFPS(120) --shaggy mod cutscenes NEED to be 120 fps, or else they will be sped up/slowed down, no idea why it even happens tbh, since it uses timers



    setProperty('camFollow.x', getProperty('boyfriend.x')+(getProperty('boyfriend.width')/2)-100)
    setProperty('camFollow.y', getProperty('boyfriend.y')+(getProperty('boyfriend.height')/2)-100)
    runTimer('cs', timerthing, 1)

    makeAnimatedLuaSprite('scoob', 'characters/scooby', 1700,290);
    addAnimationByPrefix('scoob','walk', 'scoob_walk', 30, false);
    addAnimationByPrefix('scoob','idle', 'scoob_idle', 30, false);
    addAnimationByPrefix('scoob','scare', 'scoob_scare', 24, false);
    addAnimationByPrefix('scoob','blur', 'scoob_blur', 30, false);
    addAnimationByPrefix('scoob','half', 'scoob_half', 30, false);
    addAnimationByPrefix('scoob','fall', 'scoob_fall', 30, false);
    objectPlayAnimation('scoob', 'idle', true);
    addLuaSprite('scoob', true)

    makeLuaSprite('doorFrame', 'doorframe', -160, 160)
    updateHitbox('doorFrame')
    setProperty('doorFrame.alpha', 0)
    addLuaSprite('doorFrame', false)

    setObjectOrder('doorFrame', getObjectOrder('gfGroup'))

    local width = 1	
    setProperty('doorFrame.scale.x', width/getProperty('doorFrame.frameWidth'))
    setProperty('doorFrame.scale.y', width/getProperty('doorFrame.frameWidth'))
end

function modCredits()

end

function onEvent(name, value1, value2)
	if name == 'endDial' then 
        --debugPrint('bruh')
        endDialStuff = true
    elseif name == 'onFinalDial' then 
        musicFadeOut(0.01, 0)
    end
end