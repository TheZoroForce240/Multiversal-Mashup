

local isLava = true
local zoom = 0.6
function onCreate()
	zoom = getProperty('defaultCamZoom')


	--setObjectCamera('void', 'game')
	makeLuaSprite('camPos', '', getProperty('camFollow.x'), getProperty('camFollow.y'));

	makeLuaSprite('blackBarTop', '', 0, 0);
	setScrollFactor('blackBarTop', 0, 0)
	makeGraphic('blackBarTop', screenWidth, screenHeight*0.2, '0xFF000000')
    setObjectCamera('blackBarTop', 'hud')
	addLuaSprite('blackBarTop', false)

	makeLuaSprite('blackBarBottom', '', 0, screenHeight*0.8);
	setScrollFactor('blackBarBottom', 0, 0)
	makeGraphic('blackBarBottom', screenWidth, screenHeight*0.2, '0xFF000000')
    setObjectCamera('blackBarBottom', 'hud')
	addLuaSprite('blackBarBottom', false)

	precacheImage('doorframe')
	precacheImage('bgs/WBG/BGBG')
	precacheImage('bgs/WBG/LavaLimits')
	precacheImage('bgs/WBG/BGSpikes')
	precacheImage('bgs/WBG/Spikes')
	precacheImage('bgs/WBG/Ground')

	precacheImage('bgs/box/bg_boxn')
	precacheImage('bgs/box/bg_boxr')

	precacheImage('bgs/OBG/sky')
	precacheImage('bgs/OBG/clouds')
	precacheImage('bgs/OBG/backmount')
	precacheImage('bgs/OBG/middlemount')
	precacheImage('bgs/OBG/ground')
	

    --close(true)
	addLuaScript('shaggyGameOver')
	setUpBG(true)

	--

	
end

function onMoveCamera(char)

    doTweenX('camPosX', 'camPos', getProperty('camFollow.x'), stepCrochet/250, 'quantInOut')
	doTweenY('camPosY', 'camPos', getProperty('camFollow.y'), stepCrochet/250, 'quantInOut')
	local targetZoom = zoom
	if char == 'dad' then 
		targetZoom = targetZoom + 0.15
	end
	doTweenZoom('camGameZoom', 'camGame', targetZoom, stepCrochet/250, 'linear')
    setProperty('defaultCamZoom', targetZoom)
end
function onStepHit()
	if curStep < 8*16 then 
		if curStep % 32 == 0 or curStep % 128 == 112 then 
			triggerEvent('Add Camera Zoom', 0.05, 0.05)
		end
	elseif (curStep >= 8*16 and curStep <= 24*16) or (curStep >= 64*16 and curStep <= 80*16) then 
		if curStep % 16 == 0 or curStep % 256 == 56+128 or curStep % 256 == 120+128 then 
			triggerEvent('Add Camera Zoom', 0.05, 0.05)
		end
	elseif (curStep >= 24*16 and curStep <= 38*16) or (curStep >= 80*16 and curStep <= 94*16) then
		if curStep % 8 == 0 then 
			triggerEvent('Add Camera Zoom', 0.05, 0.05)
		end
	elseif (curStep >= 40*16 and curStep <= 56*16) or (curStep >= 96*16 and curStep <= 112*16) then
		if curStep % 8 == 0 then 
			triggerEvent('Add Camera Zoom', 0.03, 0.03)
		end

		if curStep % 64 == 0 or curStep % 64 == 60 then 
			triggerEvent('Add Camera Zoom', -0.12, 0.08)
		end
	end
end
function onUpdatePost(elapsed)
	if not getProperty('endingSong') and not inGameOver then 
		setProperty('camFollow.x', getProperty('camPos.x'))
		setProperty('camFollow.y', getProperty('camPos.y'))
		if curStep >= 128 then 
			runHaxeCode('game.wiggleShit.set_waveSpeed(0.8);')
		runHaxeCode('game.wiggleShit.set_waveFrequency(1);')
		runHaxeCode('game.wiggleShit.set_waveAmplitude(0.02);')
		end
	else 
		runHaxeCode('game.wiggleShit.set_waveSpeed(0);')
		runHaxeCode('game.wiggleShit.set_waveFrequency(0);')
		runHaxeCode('game.wiggleShit.set_waveAmplitude(0);')
	end

	--setProperty('healthBar.scale.x', 0.6)
	--setProperty('healthBarBG.scale.x', 0.6)

	--setProperty('healthBar.y', 200)
	--setProperty('healthBarBG.y', 200-4)



	runHaxeCode('game.wiggleShit.update('..elapsed..');')

end

function onCountdownStarted()
	for i = 0, (getPropertyFromClass('PlayState', 'keyAmmount'))-1 do 
		if not middlescroll then 
			setPropertyFromGroup('playerStrums', i, 'x', _G['defaultOpponentStrumX'..i])
			setPropertyFromGroup('opponentStrums', i, 'x', _G['defaultPlayerStrumX'..i])
		end

		if downscroll then 
			setPropertyFromGroup('playerStrums', i, 'y', _G['defaultOpponentStrumY'..i]+20)
			setPropertyFromGroup('opponentStrums', i, 'y', _G['defaultPlayerStrumY'..i]+20)
		end

	end
end

function onCreatePost()
	setProperty('dad.z', -200)
	addCharacterToList('zephUCFlipped', 'dad')

	--addHaxeLibrary('FlxBar', 'flixel.ui')
	addHaxeLibrary('FlxBar')
	runHaxeCode('game.healthBar.createGradientBar([0xFF144800, 0xFF144800, 0xFF144800], [0xFF000000, 0xFF000000, 0xFFffee00]);')

	addHaxeLibrary('ShaderFilter', 'openfl.filters')
	addHaxeLibrary('WiggleEffect')
	addHaxeLibrary('WiggleEffectType', 'WiggleEffect')

	if (not getPropertyFromClass('ClientPrefs', 'performanceMode')) then  
		runHaxeCode('game.camGame.setFilters([new ShaderFilter(game.wiggleShit.shader)]);')
		runHaxeCode('game.camHUD.setFilters([new ShaderFilter(game.wiggleShit.shader)]);')
	end

end

local switchToBoxingRing = false



function setUpBG(firstTime)
	if not firstTime then 


		if isLava then 
			if not switchToBoxingRing then 
				removeLuaSprite('boxn')
				removeLuaSprite('boxr')
			else 
				removeLuaSprite('outsky')
				removeLuaSprite('outclouds')
				removeLuaSprite('outbackmount')
				removeLuaSprite('outmiddlemount')
				removeLuaSprite('outground')
			end

			triggerEvent('Change Character', 'dad', 'zephUC')
			triggerEvent('Change Character', 'bf', 'shagUC')
			runHaxeCode('game.healthBar.createGradientBar([0xFF144800, 0xFF144800, 0xFF144800], [0xFF000000, 0xFF000000, 0xFFffee00]);')
			--setProperty('dad.x', defaultOpponentX)
			--setProperty('boyfriend.x', defaultBoyfriendX)
		else 
			removeLuaSprite('bg')
			removeLuaSprite('lava')
			removeLuaSprite('bgspikes')
			removeLuaSprite('spikes')
			removeLuaSprite('ground')
			triggerEvent('Change Character', 'dad', 'zephUCFlipped') 
			triggerEvent('Change Character', 'bf', 'shagUCFlipped') --flip left and right lol
			runHaxeCode('game.healthBar.createGradientBar([0xFF144800, 0xFF144800, 0xFF144800], [0xFF000000, 0xFF000000, 0xFFffee00]);')
			--setProperty('dad.x', defaultBoyfriendX)
			--setProperty('boyfriend.x', defaultOpponentX)
		end
		--cameraSetTarget('dad')
		runHaxeCode('game.camGame.flashSprite.scaleX *= -1;') --why not just flip the camera?
		

	end

	if isLava then 
		makeLuaSprite('bg', 'bgs/WBG/BGBG', -1940, -1112);
		setScrollFactor('bg', 0.5, 0.5)
		--updateHitbox('bg')
		addLuaSprite('bg', false);
	
		makeLuaSprite('lava', 'bgs/WBG/LavaLimits', -1770, 168);
		setScrollFactor('lava', 0.55, 0.55)
		--updateHitbox('lava')
		addLuaSprite('lava', false);
	
		makeLuaSprite('bgspikes', 'bgs/WBG/BGSpikes', 112, -36);
		setScrollFactor('bgspikes', 0.6, 0.6)
		--updateHitbox('bgspikes')
		addLuaSprite('bgspikes', false);
	
		makeLuaSprite('spikes', 'bgs/WBG/Spikes', -1186, -234);
		setScrollFactor('spikes', 0.8, 0.8)
		--updateHitbox('spikes')
		addLuaSprite('spikes', false);
	
		makeLuaSprite('ground', 'bgs/WBG/Ground', -1520, 590);
		setProperty('ground.z', -200)
		--setScrollFactor('ground', 0.5, 0.5)
		--updateHitbox('ground')
		addLuaSprite('ground', false);
		setProperty('defaultCamZoom', 0.56)
		zoom = getProperty('defaultCamZoom')

		

		isLava = false
	else 

		--[[
			var bg:FlxSprite = new FlxSprite(-400, -220).loadGraphic(Paths.image('bg_boxn'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.8, 0.8);
			bg.active = false;
			add(bg);

			var bg_r:FlxSprite = new FlxSprite(-810, -380).loadGraphic(Paths.image('bg_boxr'));
			bg_r.antialiasing = true;
			bg_r.scrollFactor.set(1, 1);
			bg_r.active = false;
			add(bg_r);
		]]
		if switchToBoxingRing then 
			makeLuaSprite('boxn', 'bgs/box/bg_boxn', -500, -220);
			setScrollFactor('boxn', 0.8, 0.8)
			setProperty('defaultCamZoom', 0.65)
			zoom = getProperty('defaultCamZoom')
	
			--setProperty('boxn.z', -200)
			addLuaSprite('boxn', false);
			makeLuaSprite('boxr', 'bgs/box/bg_boxr', -970, -380);
			addLuaSprite('boxr', false);
			setProperty('bg_boxr.z', -200)
			scaleObject('boxr', 1.3, 1.3)
			switchToBoxingRing = false
		else 
			--[[
				var sky:BGElement = new BGElement('OBG/sky', -1204, -456, 0.15, 1, 0);
				add(sky);

				var clouds:BGElement = new BGElement('OBG/clouds', -988, -260, 0.25, 1, 1);
				add(clouds);

				var backMount:BGElement = new BGElement('OBG/backmount', -700, -40, 0.4, 1, 2);
				add(backMount);

				var middleMount:BGElement = new BGElement('OBG/middlemount', -240, 200, 0.6, 1, 3);
				add(middleMount);

				var ground:BGElement = new BGElement('OBG/ground', -660, 624, 1, 1, 4);
				add(ground);
			]]
			setProperty('defaultCamZoom', 0.7)
			zoom = getProperty('defaultCamZoom')
			makeLuaSprite('outsky', 'bgs/OBG/sky', -1204, -456);
			setScrollFactor('outsky', 0.15, 0.15)
			addLuaSprite('outsky', false);

			makeLuaSprite('outclouds', 'bgs/OBG/clouds', -988, -260);
			setScrollFactor('outclouds', 0.25, 0.25)
			addLuaSprite('outclouds', false);

			makeLuaSprite('outbackmount', 'bgs/OBG/backmount', -700, -40);
			setScrollFactor('outbackmount', 0.4, 0.4)
			addLuaSprite('outbackmount', false);

			makeLuaSprite('outmiddlemount', 'bgs/OBG/middlemount', -240, 200);
			setScrollFactor('outmiddlemount', 0.6, 0.6)
			addLuaSprite('outmiddlemount', false);

			makeLuaSprite('outground', 'bgs/OBG/ground', -660, 624);
			addLuaSprite('outground', false);
			setProperty('outground.z', -200)
			switchToBoxingRing = true
		end

		--setProperty('bg_boxr.flipX', true)
		isLava = true
	end
end


function onEvent(name, value1, value2)

	if name == 'Change Lava BG' then 
		makeLuaSprite('doorFrame', 'doorframe', 0, 0)
		updateHitbox('doorFrame')
		screenCenter('doorFrame', 'xy')

		addLuaSprite('doorFrame', false)
		setScrollFactor('doorFrame', 0, 0)
		setObjectCamera('doorFrame', 'hud')



		local scaleX = screenWidth/getProperty('doorFrame.frameWidth')
		local scaleY = screenWidth/getProperty('doorFrame.frameHeight')

		setProperty('doorFrame.scale.x', 0)
		setProperty('doorFrame.scale.y', 0)
		setProperty('doorFrame.angle', 90)

		doTweenX('x', 'doorFrame.scale', scaleX, crochet/2000, 'quantInOut')
		doTweenY('y', 'doorFrame.scale', scaleY, crochet/2000, 'quantInOut')

		if isLava then 
			for i = 0, (getPropertyFromClass('PlayState', 'keyAmmount'))-1 do 
				if not middlescroll then 
					noteTweenX(i..'px', i, _G['defaultPlayerStrumX'..i], (crochet/2000)*3, 'cubeInOut')
					noteTweenX(i..'ox', i+getPropertyFromClass('PlayState', 'keyAmmount'), _G['defaultOpponentStrumX'..i], (crochet/2000)*3, 'cubeInOut')
				end

				noteTweenZ(i..'pz', i, -300, crochet/2000, 'cubeInOut')
				noteTweenZ(i..'oz', i+getPropertyFromClass('PlayState', 'keyAmmount'), 300, crochet/2000, 'cubeInOut')
			end
		else 
			for i = 0, (getPropertyFromClass('PlayState', 'keyAmmount'))-1 do 
				if not middlescroll then 
					noteTweenX(i..'px', i+getPropertyFromClass('PlayState', 'keyAmmount'), _G['defaultPlayerStrumX'..i], crochet/1000, 'cubeInOut')
					noteTweenX(i..'ox', i, _G['defaultOpponentStrumX'..i], crochet/1000, 'cubeInOut')
				end

				noteTweenZ(i..'pz', i+getPropertyFromClass('PlayState', 'keyAmmount'), -300, crochet/2000, 'cubeInOut')
				noteTweenZ(i..'oz', i, 300, crochet/2000, 'cubeInOut')
			end
		end

		

		runTimer('doorInFinished', crochet/2000)

		
	end
end
function onTimerCompleted(tag, loops, loopsLeft)

	if tag == 'doorInFinished' then 
		setUpBG(false)
		runTimer('doorOutStart', crochet/2000)
	elseif tag == 'doorOutStart' then 
		doTweenX('x', 'doorFrame.scale', 0, crochet/2000, 'quantInOut')
		doTweenY('y', 'doorFrame.scale', 0, crochet/2000, 'quantInOut')
		runTimer('doorOutFinished', crochet/2000)
		for i = 0, (getPropertyFromClass('PlayState', 'keyAmmount'))-1 do 
			noteTweenZ(i..'pz', i+getPropertyFromClass('PlayState', 'keyAmmount'), 0, crochet/2000, 'cubeInOut')
			noteTweenZ(i..'oz', i, 0, crochet/2000, 'cubeInOut')
		end
	elseif tag == 'doorOutFinished' then 
		removeLuaSprite('doorFrame')
	elseif tag == 'endFadeOut' then 
		startVideo('Rest_In_pipis')
	elseif tag == 'endSong' then 
		endSong()
	elseif tag == 'black' then 
		setProperty('blackScreen.alpha', 1)
	elseif tag == 'playPowerup' then 
		playSound('powerup')
	end
end


local fadedOut = false
local playedVideo = false
local startedCutscene = false
function onEndSong()
	-- Block the first countdown and start a timer of 0.8 seconds to play the dialogue
	if not fadedOut then
        fadeOut()
		fadedOut = true;
		return Function_Stop;        
	end 
	--if not playedVideo then
    --    endCutscene()
	--	playedVideo = true;
	--	return Function_Stop;        
	--end 
	if not startedCutscene then
        endCutscene()
		startedCutscene = true;
		return Function_Stop;        
	end    
	return Function_Continue;
end


function fadeOut()
	doTweenY('blackBarBottom', 'blackBarBottom', getProperty('blackBarBottom.y')+getProperty('blackBarBottom.height'), 1.5, 'quantInOut')
	doTweenY('blackBarTop', 'blackBarTop', getProperty('blackBarTop.y')-getProperty('blackBarTop.height'), 1.5, 'quantInOut')
	setObjectCamera('blackBarBottom', 'other')
	setObjectCamera('blackBarTop', 'other')
	doTweenAlpha('camHUD', 'camHUD', 0, 1.5, 'quantInOut')

	makeLuaSprite('blackScreen', '', 0, 0);
	setScrollFactor('blackScreen', 0, 0)
	makeGraphic('blackScreen', screenWidth, screenHeight, '0xFF000000')
    setObjectCamera('blackScreen', 'other')
	setProperty('blackScreen.alpha', 0)
	addLuaSprite('blackScreen', false)
	doTweenAlpha('blackScreen', 'blackScreen', 1, 2, 'quantInOut')
	setProperty('defaultCamZoom', 0.7)

	setProperty('camFollow.x', getProperty('camFollow.x')+250)
	setProperty('camFollow.y', getProperty('camFollow.y')-100)

	runTimer('endFadeOut', 2.5)
end


function endCutscene()
	--runHaxeCode('game.camGame.flashSprite.scaleX *= -1;')
	setProperty('dad.alpha', 0)
	setProperty('boyfriend.alpha', 0)
	doTweenAlpha('blackScreen', 'blackScreen', 0, 2, 'quantInOut')

	makeLuaSprite('redshag', 'Hes_fucking_dead', 300, 350);
	setProperty('redshag.flipX', true)
	setProperty('redshag.scale.x', 0.8)
	setProperty('redshag.scale.y', 0.8)
	addLuaSprite('redshag', false)


	makeLuaSprite('zeph', 'zephyrus', -500, 700);
	setProperty('zeph.flipX', true)
	addLuaSprite('zeph', false)

	setProperty('camFollow.x', getProperty('camFollow.x')+250)
	setProperty('camFollow.y', getProperty('camFollow.y')+350)


	doTweenZoom('zoom', 'camGame', 0.57, 8, 'quantInOut')

	doTweenX('zephX', 'zeph', getProperty('redshag.x')+850, 5, 'quantInOut')
	doTweenY('zephY', 'zeph', getProperty('redshag.y')+140, 5, 'quantInOut')

	playSound('possess', 0, 'possess')
    soundFadeIn('possess', 1.4, 0, 1)
	setSoundTime('possess', 8200)

	runTimer('black', 5)
	runTimer('playPowerup', 5.5)

	runTimer('endSong', 8)
end


