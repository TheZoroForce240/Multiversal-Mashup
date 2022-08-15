
local dimToggled,rotateCam,rotateHud = false
local camrot,hudrot = 0
local camrotSpeed,camrotRange, hudrotSpeed, hudrotRange = 1


function onEvent(name, value1, value2)

	if name == 'Change Cam Speed' then 
        setProperty('cameraSpeed', tonumber(value1))
	elseif name == 'Shaggy burst' then 
        setProperty('burst.alpha', 1);
        objectPlayAnimation('burst', 'burst');
        playSound('burst')
    elseif name == 'Camera rotate on' then 
        rotateCam = true
        camrotSpeed = tonumber(value1)
        camrotRange = tonumber(value2)
    elseif name == 'Camera rotate off' then 
        rotateCam = false
        setProperty('camGame.angle',0)
    elseif name == 'HUD Camera rotate on' then 
        rotateHud = true
        hudrotSpeed = tonumber(value1)
        hudrotRange = tonumber(value2)
    elseif name == 'HUD Camera rotate off' then 
        rotateHud = false
        setProperty('camHUD.angle',0)
    elseif name == 'Toggle bg dim' then 
        
        dimToggled = not dimToggled
	end
end

function onCreatePost()
    makeLuaSprite('bgdim', '', -500, -500);
	makeGraphic('bgdim', 3000, 2000, '0xFF000000')
    setObjectCamera('bgdim', 'hud')
	setScrollFactor('bgdim', 0, 0);
    setProperty('bgdim.alpha', 0)
	addLuaSprite('bgdim', false);


    makeAnimatedLuaSprite('burst', 'burst', getProperty('dad.x'),getProperty('dad.y'));
	addAnimationByPrefix('burst', 'burst', 'burst', 24, false);
	objectPlayAnimation('burst', 'burst');
	setProperty('burst.alpha', 0);
    setProperty('burst.x', getProperty('burst.x') - ((getProperty('burst.width') - getProperty('dad.width')) / 2)); --offset
    setProperty('burst.y', getProperty('burst.y') - ((getProperty('burst.height') - getProperty('dad.height')) / 2));

	addLuaSprite('burst');
end

function onUpdate(elapsed) --please no lua crash

    if dimToggled then 
        if getProperty('bgdim.alpha') < 0.5 then 
            setProperty('bgdim.alpha', getProperty('bgdim.alpha') + (0.01* 120 * elapsed))
        end
    else 
        if getProperty('bgdim.alpha') > 0 then 
            setProperty('bgdim.alpha', getProperty('bgdim.alpha') - (0.01* 120 * elapsed))
        end
    end

    if rotateCam then 
        camrot = camrot + (1 * 120 * elapsed) 
        setProperty('camGame.angle', math.sin(camrot/100*camrotSpeed)*camrotRange)
    else 
        camrot = 0
    end

    if rotateHud then 
        hudrot = hudrot + (1 * 120 * elapsed) 
        setProperty('camHUD.angle', math.sin(hudrot/100*hudrotSpeed)*hudrotRange)
    else 
        hudrot = 0
    end
end

function onTimerCompleted(tag, loops, loopsleft)
	if tag == 'popupEnd' then 
		doTweenX('popupEnd', 'popupBox', -getProperty('popupBox.width')-500, 0.5, 'quantInOut')
		doTweenX('popupTextEnd', 'popupText', -getProperty('popupBox.width')-500, 0.5, 'quantInOut')
	end
end


function onSongStart()
	makeLuaSprite('popupBox', '', 0, 200)
	makeGraphic('popupBox', 300, 200, '0xFF000000')
	setProperty('popupBox.x', -getProperty('popupBox.width'))

	doTweenX('popup', 'popupBox', 0, 0.5, 'quantInOut')
	runTimer('popupEnd', 4)
	setObjectCamera('popupBox', 'hud')
	addLuaSprite('popupBox')
	setProperty('popupBox.alpha', 0.7)

	local text = 'test lol'

	if (songName == 'GODSPEED') then 
		text = 'Godspeed\nMashup by HeckinLeBork\n\nGod Eater, Blast, Kaio-ken and Super Saiyan by srPerez\n\nImprobable Outset by Rozebud'
		if (getPropertyFromClass('PlayState', 'god')) then 
			text = 'Godspeed (God Version)\nMashup by HeckinLeBork\n\nGod Eater, Blast, Kaio-ken and Super Saiyan by srPerez\n\nHellclown by Rozebud'
			defaultZoom = 0.56
		end
	elseif (songName == 'GODSPEED-old') then
		text = 'Godspeed (old)\nMashup by HeckinLeBork\n\nGod Eater, Blast, Kaio-ken and Super Saiyan by srPerez\n\nImprobable Outset by Rozebud'
    elseif songName == 'universal-catastrophy' then 
        text = 'Universal Catastrophy\nMashup by HeckinLeBork\n\nTalladega and Final Destination by srPerez'
    elseif songName == 'Monsters-Arent-Real' then 
        text = 'Monsters Arent Real\nMashup by HeckinLeBork\n\nKaio-ken by srPerez\n\nFoolhardy by Rozebud\n\nCredit goes to whoever made the og meme clip'
    elseif songName == "What I wanna know is where's the caveman" then 
        text = "Boy am I glad that he's frozen in there and that we're out here and that he's m'sheriff and that we're frozen out here and we're in there and I just remembered we're out here.\nWhat I wanna know is where's the caveman\n\nMashup by HeckinLeBork\n\nWhere are you, Eruption, Whats New and Soothing Power by srPerez"
	end

	makeLuaText('popupText', text, getProperty('popupBox.width'), getProperty('popupBox.x')+5, getProperty('popupBox.y')+5)
	setTextSize('popupText', 20)
	addLuaText('popupText')
	doTweenX('popupText', 'popupText', 5, 0.5, 'quantInOut')	
end