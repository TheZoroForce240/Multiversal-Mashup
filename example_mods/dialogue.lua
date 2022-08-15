--shaggy mod dialogue system recreated in lua lol
--og code by srPerez
local tb_x = 60;
local tb_y = 410;
local tb_fx = -510 + 40;
local tb_fy = 320;
local tb_rx = 200 - 55;
local btrans = 0
local dcd = 7
local tb_appear = 0
local talk = 1
local dialogueEnded = false
local dialogue = { 'Test Test', 'amongus' }
local dface = { 'normal', 'normal' }
local dchar = { 'zsh', 'bf' }
local dside = { 1, -1 } --omg is that a fnf dsides reference
local curr_dial = 0
local curr_char = 0

function loadDialogueFile(path)  --file parsing in lua bruhhhhhh
    local rawText = getTextFromFile(path)
    --debugPrint(rawText)
    local lines = rawText:split("\n")
    
    for i = 0, #lines do 
        local lineStr = tostring(lines[i+1])
        --debugPrint(lineStr)
        local splitline = lineStr:split(":")

        local splitAgainForNewLines = tostring(splitline[4]):split("#")--dialogue uses hashtag for new line
        local finalDial = ""
        if #splitAgainForNewLines > 1 then 
            for j = 0, #splitAgainForNewLines-1 do 
                finalDial = finalDial..tostring(splitAgainForNewLines[j+1])
                finalDial = finalDial..'\n'
            end
        else 
            finalDial = splitline[4]
        end
 
        dialogue[i+1] = finalDial
        dface[i+1] = tostring(splitline[2]) --port
        dchar[i+1] = tostring(splitline[1]) --character
        dside[i+1] = tonumber(splitline[3]) --1 = no flip, -1 = flip, flip for bf side and shit
    end
end


function string:split( inSplitPattern, outResults ) -- from here, code isnt mine, https://stackoverflow.com/questions/19262761/lua-need-to-split-at-comma
    if not outResults then
      outResults = { }
    end
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    while theSplitStart do
      table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    end
    table.insert( outResults, string.sub( self, theStart ) )
    return outResults
end

local afterAction = 'countdown'

local shouldCallFinalDialEvent = false
local shouldCutOff = false

function setUpDialogue(forcePath)

    local song = string.lower(songName)
    local dialoguePath = ''

    --debugPrint(song)

    if song == 'where-are-you' then 
        dialoguePath = '1-pre-whereareyou'
        btrans = 1
    elseif song == 'eruption' then 
        dialoguePath = '2-pre-eruption'
        if getProperty('endingSong') then
            dialoguePath = '3-post-eruption'
            afterAction = 'transform'
        end
        --debugPrint(dialoguePath)
        --debugPrint(afterAction)
        btrans = 0
    elseif song == 'kaio-ken' then 

    elseif song == 'whats-new' then 
        btrans = 1
        dialoguePath = '5-pre-whatsnew'
        if getProperty('endingSong') then
            dialoguePath = '6-post-whatsnew'
            afterAction = 'transform'
            btrans = 0
        end
    elseif song == 'blast' then 
        if getProperty('endingSong') then
            dialoguePath = '7-post-blast'
            afterAction = 'end'
        end
    elseif song == 'super-saiyan' then 
        
        dialoguePath = 'cs/found_scooby'
        afterAction = 'endDial'
        --[[if getProperty('scoob.ID') == 1 then --dumb but works
            dialoguePath = 'cs/scooby_hold_talk'
            afterAction = 'cs2'
        elseif getProperty('scoob.ID') == 2 then 
            dialoguePath = 'cs/gf_sass'
            afterAction = 'cs3'
        end]]--        
    elseif song == 'god-eater' then 
        afterAction = 'endDial'
    elseif song == 'soothing-power' then 

    elseif song == 'thunderstorm' then 

    elseif song == 'dissasembler' then 

    elseif song == 'astral-calamity' then 

    elseif song == 'talladega' then 

    end
    

    if forcePath ~= '' then 
        dialoguePath = forcePath
    end

    if dialoguePath ~= '' then 
        loadDialogueFile('data/z_textbox/'..dialoguePath..'.txt')
    end
end

function onCreate()
    
    setUpDialogue('');

    setProperty('vocals.volume', 0)

    if getProperty('endingSong') then
        runTimer('hudFade', 0.003, 1)
        removeLuaScript('extra keys') --should optimize more???
    end

    makeLuaSprite('black', '', -500, -500);
	makeGraphic('black', 3000, 2000, '0xFF000000')
	setScrollFactor('black', 0, 0);
    --setProperty('black.alpha', 0)
	addLuaSprite('black', true);

    makeLuaSprite('dimWhite', '', -500, -500);
	makeGraphic('dimWhite', 3000, 2000, '0xFFFFFFFF')
	setScrollFactor('dimWhite', 0, 0);
    setProperty('dimWhite.alpha', 0)
	addLuaSprite('dimWhite', true);

    makeLuaSprite('tbox', 'Textbox', tb_x, tb_y);
    addLuaSprite('tbox', true)
    setScrollFactor('tbox', 0, 0);
    updateHitbox('tbox')

    makeLuaText('dropText', " ", 2000, 140, tb_y + 25)
    setScrollFactor('dropText', 0, 0);
    setObjectCamera('dropText', 'game') --fuck you pscyh
    setTextSize('dropText', 32)
    setTextAlignment('dropText', 'left')
    setTextBorder('dropText', 1, '0x00FFFFFF')
    setTextFont('dropText', 'pixel.otf')
    setTextColor('dropText', '0x00000000')
    addLuaText('dropText', true)

    setProperty('tbox.alpha', 0)

    faceRender();

    if btrans == 0 then
        dcd = 2;
        setProperty('black.alpha', 0)
    elseif btrans == 2 then
        dcd = 11;
    end

    runTimer('dcd', 0.2, 1)
    runTimer('tb_appear', 0.03, 1)
    runTimer('talk', 0.025, 1)
    --runTimer('prs', 0.001, 1)

    --playMusic('phantomMenu', 0, true)
    --musicFadeIn(1.4, 0, 0.7)
    --startDialogue('dialogue', '');
end

local stopTimers = false
function onSongStart()
    stopTimers = true
    close(true)
end

function onUpdatePost(elapsed)
    if getProperty('inCutscene') then 
        if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.ANY') and not dialogueEnded then -- on key press
            if curr_char <= string.len(dialogue[curr_dial+1]) then
                curr_char = string.len(dialogue[curr_dial+1]);
            else
                curr_char = 0;
                curr_dial = curr_dial + 1;

                if (curr_dial >= #dialogue-1) then
                    if shouldCallFinalDialEvent then 
                        shouldCallFinalDialEvent = false
                        triggerEvent('onFinalDial')
                    end
                end

                if (curr_dial >= #dialogue) then --ending dialogue
                    

                    doAfterAction()
                    --musicFadeOut(1, 0)
                else
                    --if (textIndex == 'cs/sh_bye' && curr_dial == 3)
                    --{
                    --    cs_mus.stop();
                    --}
                    --fimage = dchar[curr_dial] + '_' + dface[curr_dial];
                    --[[if (fimage != "n")
                    {
                        fsprite.destroy();
                        faceRender();
                        fsprite.flipX = false;
                        if (dside[curr_dial] == -1)
                        {
                            fsprite.flipX = true;
                        }
                    }]]--
                    faceRender()
                end
            end
        end
    end
end

function doAfterAction()
    talk = 0;
    setProperty('dropText.alpha', 0)
    curr_dial = 0;
    tb_appear = 0;
    dialogueEnded = true

    if afterAction == 'countdown' then 
        startCountdown()
    elseif afterAction == 'end' then 
        endSong()
    elseif afterAction == 'transform' then
        musicFadeOut(1, 0)
        setProperty('inCutscene', false) --for the camera 
        runTimer('superShag', 0.008, 1)
    elseif afterAction == 'endDial' then
        triggerEvent('endDial')
    end
end

function faceRender()

    local fimage = dchar[curr_dial+1]..'_'..dface[curr_dial+1];
    local jx = tb_fx;
    local doFlipX = false
    if dside[curr_dial+1] == -1 then
        jx = tb_rx;
        doFlipX = true
    end

    makeLuaSprite('fsprite', 'dialogue/f_'..fimage, tb_x + (getProperty('tbox.width') / 2) + jx, tb_y - tb_fy);
    --centerOffsets('fsprite')
    --updateHitbox('fsprite')
    setProperty('fsprite.flipX', doFlipX)
	setScrollFactor('fsprite', 0, 0);
	addLuaSprite('fsprite', true);
end

local cutTime = 0


function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'dcd' then 
        setProperty('black.alpha', getProperty('black.alpha') - 0.15)
        dcd = dcd - 1;
        if dcd == 0 then
            tb_appear = 1;
        end
        if not stopTimers then
            runTimer('dcd', 0.3, 1)
        end
    elseif tag == 'tb_appear' then 

        if (tb_appear == 1) then
            if (getProperty('tbox.alpha') < 1) then
                setProperty('tbox.alpha', getProperty('tbox.alpha') + 0.1)
            end
        else
            if (getProperty('tbox.alpha') > 0) then
                setProperty('tbox.alpha', getProperty('tbox.alpha') - 0.1)
            end
        end
        setProperty('dropText.alpha', getProperty('tbox.alpha'))
        setProperty('fsprite.alpha', getProperty('tbox.alpha'))
        setProperty('dimWhite.alpha', getProperty('tbox.alpha')/2)
        if not stopTimers then
            runTimer('tb_appear', 0.05, 1)
        end
    elseif tag == 'talk' then 
        if talk == 1 then 
            local newtxt = string.sub(dialogue[curr_dial+1], 0, curr_char);
            local charat = string.sub(dialogue[curr_dial+1], curr_char - 1, 1);
            if (curr_char <= string.len(dialogue[curr_dial+1]) and tb_appear == 1) then
                if (charat ~= ' ') then
                    --vc_sfx = FlxG.sound.load(TextData.vcSound(dchar[curr_dial], dface[curr_dial]));
                    --vc_sfx.play();
                    if dchar[curr_dial+1] == 'bf' or dchar[curr_dial+1] == 'gf' or dchar[curr_dial+1] == 'zp' or dchar[curr_dial+1] == 'scb' then 
                        playSound('defB')
                    else 
                        playSound('defA')
                    end
                end
                curr_char = curr_char + 1;
            end

            if shouldCutOff then 
                if (curr_dial >= #dialogue-1) and curr_char >= 16 then
                    doAfterAction()
                    shouldCutOff = false
                end
            end

            setTextString('dropText', newtxt)

            

            if not stopTimers then
                runTimer('talk', 0.025, 1)
            end
        end
    elseif tag == 'prs' then
        --just moved it to update lol

        if not stopTimers then
            prs.reset(0.001 / (getPropertyFromClass('flixel.FlxG', 'elapsed') / (1/60)));
        end
    elseif tag == 'endDial' then
        startCountdown()
    elseif tag == 'superShag' then
        if cutTime == 0 then 
            setProperty('camFollow.x', getProperty('dad.x') + (getProperty('dad.width') / 2) - 100)
            setProperty('camFollow.y', getProperty('dad.y') + (getProperty('dad.height') / 2))
            setProperty('cameraSpeed', 2)
        elseif cutTime == 15 then 
            characterPlayAnim('dad', 'powerup')
        elseif cutTime == 48 then 
            characterPlayAnim('dad', 'idle_s')
            setProperty('dad.idleSuffix', '_s')
            triggerEvent('Shaggy burst');

            
            setProperty('burst.x', getProperty('dad.x') + (getProperty('dad.width') / 2))
            setProperty('burst.y', getProperty('dad.y') + (getProperty('dad.height') / 2))

            setProperty('burst.x', getProperty('burst.x') - 1000)
            setProperty('burst.y', getProperty('burst.y') - 100)
            playSound('powerup')
        elseif cutTime == 95 then 
            setProperty('camGame.angle', 0)
        elseif cutTime == 200 then 
            endSong()
        end
    
        local ssh = 45;
        local stime = 30;
        local corneta = (stime - (cutTime - ssh)) / stime;
    
        if (cutTime % 6 >= 3) then
            corneta = corneta * -1;
        end
        if (cutTime >= ssh and cutTime <= ssh + stime) then
            setProperty('camGame.angle', corneta * 5)
        end
    
        cutTime = cutTime + 1
        runTimer('superShag', 0.008, 1)
    elseif tag == 'hudFade' then

        if getProperty('camHUD.alpha') > 0 then 
            setProperty('camHUD.alpha', getProperty('camHUD.alpha') - 0.01)
            runTimer('hudFade', 0.003, 1)
        end
        
    end
end

function onEvent(name, value1, value2)

	if name == 'restartThing' then 
        dialogue = { 'Test Test' }
        dface = { 'normal' }
        dchar = { 'zsh' }
        dside = { 1 }
        setUpDialogue(value1);
        curr_dial = 0
        curr_char = 0
        tb_appear = 0
        talk = 1
        dcd = 2;
        setProperty('black.alpha', 0)
        dialogueEnded = false
        talk = 1   
        setTextString('dropText', '')
        faceRender()
        runTimer('talk', 0.025, 1)
    elseif name == 'setCutOff' then 
        shouldCutOff = true
    elseif name == 'setFinalDialEvent' then 
        shouldCallFinalDialEvent = true
    end
end