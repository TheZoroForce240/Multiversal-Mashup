--have fun understanding this lol

local sh_r = 600

local gf_launched = false;

local godCutEnd = false;
local godMoveBf = true;
local godMoveGf = false;
local godMoveSh = false;

local bfControlY = 0

--for intro
local movePurp = false 
local moveRed = false 
local moveBlue = false

local defaultZoom = 0.65

--floating debris
local debrisData = {
    {300, -800, 'norm', 0.4, 1, 0, 1},
    {600, -300, 'tiny', 0.4, 1.5, 0, 1},
    {-150, -400, 'spike', 0.4, 1.1, 0, 1},
    {-750, -850, 'small', 0.4, 1.5, 0, 1},
    {-300, -1700, 'norm', 0.75, 1, 0, 1},
    {-1000, -1750, 'rect', 0.75, 2, 0, 1},
    {-600, -1100, 'tiny', 0.75, 1.5, 0, 1},
    {900, -1850, 'spike', 0.75, 1.2, 0, 1},
    {1500, -1300, 'small', 0.75, 1.5, 0, 1},
    {-600, -800, 'spike', 0.75, 1.3, 0, 1},
    {-1000, -900, 'small', 0.75, 1.7, 0, 1},
	{-1000, -900, 'small', 0.75, 1.7, 0, 1}
};
--debris from cutscene explosion
local debrisShit = {
    {-300, -120, 'ceil', 1, 1, -4, -40},
    {0, -120, 'ceil', 1, 1, -4, -51},
    {200, -120, 'ceil', 1, 1, -4, 40}
};
local vsp = {-20,-20,-20}

local introSkipped = false

function onCountdownTick(tick)
	if tick == 1 then 
		moveRed = true
	elseif tick == 2 then 
		moveBlue = true
	elseif tick == 3 then 
		movePurp = true
		doTweenX('x', 'doorFrame.scale', 0, crochet/1000, 'quantInOut')
		doTweenY('y', 'doorFrame.scale', 0, crochet/1000, 'quantInOut')
	end
end

function onSongStart()
	if songName == "What I wanna know is where's the caveman" then 
		setProperty('songLength', 160000)
	end
end

function onCountdownStarted()
	introSkipped = true
	setProperty('iconP2.alpha', 1)
	doTweenAlpha('icon', 'iconP2', 1, (crochet/1000)*5, 'cubeInOut')
	removeLuaText('skipText')
	makeLuaSprite('doorFrame', 'doorframe', -1800, -2500)
    updateHitbox('doorFrame')
    setProperty('doorFrame.scale.x', 0)
	setProperty('doorFrame.scale.y', 0)
    addLuaSprite('doorFrame', false)
	doTweenX('x', 'doorFrame.scale', 1.5, crochet/1000, 'quantInOut') --the funny door tween
	doTweenY('y', 'doorFrame.scale', 1.5, crochet/1000, 'quantInOut')
	if (getPropertyFromClass('PlayState', 'god')) then 
		setProperty('doorFrame.y', -4500)
	end


	setFPS(framerate)
    if (not getPropertyFromClass('ClientPrefs', 'extraStrums')) then
        return --no strums lol
    end
    runHaxeCode('game.generateStaticArrows(2);') --make extra strums
    runHaxeCode('game.generateStaticArrows(3);')
    runHaxeCode('game.generateStaticArrows(4);')
    runHaxeCode('game.generateStaticArrows(5);')
    runHaxeCode('game.generateStaticArrows(6);')
    if difficulty == 0 then 
        for i = 8,27 do --4k
            runHaxeCode('game.strumLineNotes.members['..i..'].cameras = [game.camGame];') --set cam
            runHaxeCode('game.strumLineNotes.members['..i..'].scrollFactor.x = 1;')
            runHaxeCode('game.strumLineNotes.members['..i..'].scrollFactor.y = 1;')
            runHaxeCode('game.strumLineNotes.members['..i..'].downScroll = false;') --force upscroll
            if (opponentPlay and downscroll) then 
                runHaxeCode('game.strumLineNotes.members['..i..'].downScroll = true;') --allow downscroll if opponent play
            end
        end
    else 
        for i = 18,62 do --9k
            runHaxeCode('game.strumLineNotes.members['..i..'].cameras = [game.camGame];')
            runHaxeCode('game.strumLineNotes.members['..i..'].scrollFactor.x = 1;')
            runHaxeCode('game.strumLineNotes.members['..i..'].scrollFactor.y = 1;')
            runHaxeCode('game.strumLineNotes.members['..i..'].downScroll = false;')
            if (opponentPlay and downscroll) then 
                runHaxeCode('game.strumLineNotes.members['..i..'].downScroll = true;')
            end
        end
    end

    if (getPropertyFromClass('ClientPrefs', 'extraStrums')) then
        if difficulty == 0 then --hide regular opponent strums if using extra strums
            for i = 0,3 do
                setPropertyFromGroup('opponentStrums', i , 'visible', false)
            end
        else 
            for i = 0,8 do
                setPropertyFromGroup('opponentStrums', i , 'visible', false)
            end  
        end

    end
end



function onTweenCompleted(tag)
	if tag == 'popup' then 
		--removeLuaSprite()
	end
end

function onCreatePost()
	setProperty('iconP2.alpha', 0)

	if opponentPlay then 
		addLuaScript('shaggyGameOver')
	end

	if (getPropertyFromClass('PlayState', 'god')) then 
		for i = 0, 8 do 
			precacheImage('PopUps/popup'..i+1)
		end
	end

	--Iterate over all notes
    --luaDebugMode = true
    
	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an Instakill Note
		if string.find(getPropertyFromGroup('unspawnNotes', i, 'noteType'), 'extraStrum') then

            if (getPropertyFromClass('ClientPrefs', 'extraStrums') and not getPropertyFromGroup('unspawnNotes', i, 'mustPress')) then
                runHaxeCode('game.unspawnNotes['..i..'].cameras = [game.camGame];') --set cam
                local n = getPropertyFromGroup('unspawnNotes', i, 'noteType')
				--note data adjusts
                if difficulty == 0 then --4k
                    if n == 'extraStrum1' then
                        setPropertyFromGroup('unspawnNotes', i, 'noteData', getPropertyFromGroup('unspawnNotes', i, 'noteData')+4)
                    elseif n == 'extraStrum2' then
                        setPropertyFromGroup('unspawnNotes', i, 'noteData', getPropertyFromGroup('unspawnNotes', i, 'noteData')+8)
                    elseif n == 'extraStrum3' then
                        setPropertyFromGroup('unspawnNotes', i, 'noteData', getPropertyFromGroup('unspawnNotes', i, 'noteData')+12)
                    elseif n == 'extraStrum4' then
                        setPropertyFromGroup('unspawnNotes', i, 'noteData', getPropertyFromGroup('unspawnNotes', i, 'noteData')+16)
                    elseif n == 'extraStrum5' then
                        setPropertyFromGroup('unspawnNotes', i, 'noteData', getPropertyFromGroup('unspawnNotes', i, 'noteData')+20)
                    end
                else --9k
                    if n == 'extraStrum1' then
                        setPropertyFromGroup('unspawnNotes', i, 'noteData', getPropertyFromGroup('unspawnNotes', i, 'noteData')+9)
                    elseif n == 'extraStrum2' then
                        setPropertyFromGroup('unspawnNotes', i, 'noteData', getPropertyFromGroup('unspawnNotes', i, 'noteData')+18)
                    elseif n == 'extraStrum3' then
                        setPropertyFromGroup('unspawnNotes', i, 'noteData', getPropertyFromGroup('unspawnNotes', i, 'noteData')+27)
                    elseif n == 'extraStrum4' then
                        setPropertyFromGroup('unspawnNotes', i, 'noteData', getPropertyFromGroup('unspawnNotes', i, 'noteData')+36)
                    elseif n == 'extraStrum5' then
                        setPropertyFromGroup('unspawnNotes', i, 'noteData', getPropertyFromGroup('unspawnNotes', i, 'noteData')+45)
                    end
                end
                
                setPropertyFromGroup('unspawnNotes', i, 'copyX', false) --doing positioning myself
                setPropertyFromGroup('unspawnNotes', i, 'copyY', false)
                
                setPropertyFromGroup('unspawnNotes', i, 'hitByOpponent', true) --stops being hit normally
                setPropertyFromGroup('unspawnNotes', i, 'scrollFactor.x', 1)
                setPropertyFromGroup('unspawnNotes', i, 'scrollFactor.y', 1)
                setPropertyFromGroup('unspawnNotes', i, 'flipY', false) --for upscroll
                setPropertyFromGroup('unspawnNotes', i, 'x', 10000) --hide offscreen lol
                setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true) --stop dad anims
            elseif not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
                setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true)     
            end

		end
	end

	local purpName = 'purple'
	local blueName = 'blue'
	local redName = 'red'


	if songName == "What I wanna know is where's the caveman" then 
		purpName = 'purple-real'
		blueName = 'blue-real'
		redName = 'red-real'

	end
	


	--make characters
    runHaxeCode('game.variables["purple"] = new Character(0,0, "'..purpName..'");')
    runHaxeCode('game.variables["blue"] = new Character(0,0, "'..blueName..'");')
    runHaxeCode('game.variables["red"] = new Character(0,0, "'..redName..'");')
    runHaxeCode('game.variables["tricky"] = new Character(0,0, "tricky");')

	--remove bf from group and move onto dadgroup for the funny z layering
    runHaxeCode('game.boyfriendGroup.remove(game.boyfriend);')
    runHaxeCode('game.boyfriend.x += 670;') --offset because on dadgroup
    runHaxeCode('game.dadGroup.add(game.boyfriend);') 

	--add characters to group
    runHaxeCode('game.dadGroup.add(game.variables["purple"]);')
    runHaxeCode('game.dadGroup.add(game.variables["red"]);')
    runHaxeCode('game.dadGroup.add(game.variables["blue"]);')
    runHaxeCode('game.dadGroup.add(game.variables["tricky"]);')

    if (not getPropertyFromClass('ClientPrefs', 'performanceMode')) then 
		--make trails
		--using custom perspective trail to work with z axis and also fixes sped up animations
        runHaxeCode('game.variables["greenT"] = new FlxPerspectiveTrail(game.dad, null, 5, 7, 0.3, 0.001);')
        runHaxeCode('game.variables["purpleT"] = new FlxPerspectiveTrail(game.variables["purple"], null, 5, 7, 0.3, 0.001);')
        runHaxeCode('game.variables["blueT"] = new FlxPerspectiveTrail(game.variables["blue"], null, 5, 7, 0.3, 0.001);')
        runHaxeCode('game.variables["redT"] = new FlxPerspectiveTrail(game.variables["red"], null, 5, 7, 0.3, 0.001);')
        runHaxeCode('game.trailGroup.add(game.variables["greenT"]);')
        runHaxeCode('game.trailGroup.add(game.variables["purpleT"]);')
        runHaxeCode('game.trailGroup.add(game.variables["blueT"]);')
        runHaxeCode('game.trailGroup.add(game.variables["redT"]);')
    end

    setProperty('iconP2.y', getProperty('iconP2.y') - 50) --offset icon lol
end

function onCreate()
	
	--make bg and sthi
	makeAnimatedLuaSprite('sky', 'bgs/god_bg', -950, -850);
	addAnimationByPrefix('sky', 'idle', "blue bg", 30)
	objectPlayAnimation('sky','idle');
	--manual setgraphicsize because psych forces an updatehitbox fuck you (now is optional but psych didnt have that when i made this lol)
	local width = math.floor(getProperty('sky.width') * 4.5)	
	setProperty('sky.scale.x', width/getProperty('sky.frameWidth'))
	setProperty('sky.scale.y', width/getProperty('sky.frameWidth'))
	setScrollFactor('sky', 0, 0)
	screenCenter('sky')
	addLuaSprite('sky', false);

	makeAnimatedLuaSprite('bgthing', 'bgs/god_bg', -950, -850);
	addAnimationByPrefix('bgthing', 'idle', "abg", 30)
	objectPlayAnimation('bgthing','idle');
	local width = math.floor(getProperty('bgthing.width') * 0.85)	
	setProperty('bgthing.scale.x', width/getProperty('bgthing.frameWidth'))
	setProperty('bgthing.scale.y', width/getProperty('bgthing.frameWidth'))
	setScrollFactor('bgthing', 0.1, 0.1)
	addLuaSprite('bgthing', false);



	makeAnimatedLuaSprite('bgcloud', 'bgs/god_bg', -850, -1250);
	addAnimationByPrefix('bgcloud', 'idle', "cloud_smol", 30)
	objectPlayAnimation('bgcloud','idle');
	setScrollFactor('bgcloud', 0.3, 0.3)
	addLuaSprite('bgcloud', false);

	makeAnimatedLuaSprite('bgcloud2', 'bgs/god_bg', -1050, -3000);
	addAnimationByPrefix('bgcloud2', 'idle', "cloud_smol", 30)
	objectPlayAnimation('bgcloud2','idle');
	setScrollFactor('bgcloud2', 0.45, 0.45)
	addLuaSprite('bgcloud2', false);

	--do mansion debris shit here

	for i = 0,#debrisData-1 do 
		local deb = 'debris'..i
		makeAnimatedLuaSprite(deb, 'bgs/god_bg', debrisData[i+1][1], debrisData[i+1][2]);
		addAnimationByPrefix(deb, 'idle', 'deb_'..debrisData[i+1][3], 30)
		objectPlayAnimation(deb,'idle');
		--debris.frameWidth * (debrisData[i][3] / 0.75)
		local width = math.floor(getProperty(deb..'.frameWidth') * (debrisData[i+1][4]/0.75))	
		setProperty(deb..'.scale.x', width/getProperty(deb..'.frameWidth'))
		setProperty(deb..'.scale.y', width/getProperty(deb..'.frameWidth'))
		setScrollFactor(deb, debrisData[i+1][4], debrisData[i+1][4])
		addLuaSprite(deb, false);
		updateHitbox(deb)
	end



	makeAnimatedLuaSprite('fgcloud', 'bgs/god_bg', -1150, -2900);
	addAnimationByPrefix('fgcloud', 'idle', "cloud_big", 30)
	objectPlayAnimation('fgcloud','idle');
	setScrollFactor('fgcloud', 0.9, 0.9)
	addLuaSprite('fgcloud', false);

	makeAnimatedLuaSprite('fgcloud2', 'bgs/god_bg', -1350, -5000);
	addAnimationByPrefix('fgcloud2', 'idle', "cloud_big", 30)
	objectPlayAnimation('fgcloud2','idle');
	setScrollFactor('fgcloud', 0.75, 0.75)
	addLuaSprite('fgcloud2', false);


	makeLuaSprite('bg', 'bgs/bg_lemon', -400, -160);
	local width = math.floor(getProperty('bg.width') * 1.5)	
	setProperty('bg.scale.x', width/getProperty('bg.frameWidth'))
	setProperty('bg.scale.y', width/getProperty('bg.frameWidth'))
	setScrollFactor('bg', 0.95, 0.95)
	addLuaSprite('bg', false);


	makeAnimatedLuaSprite('techo', 'bgs/god_bg', 0, 450);
	addAnimationByPrefix('techo', 'idle', "broken_techo", 30)
	objectPlayAnimation('techo','idle');
	local width = math.floor(getProperty('techo.width') * 1.5)	
	setProperty('techo.scale.x', width/getProperty('techo.frameWidth'))
	setProperty('techo.scale.y', width/getProperty('techo.frameWidth'))
	setScrollFactor('techo', 0.95, 0.95)
	addLuaSprite('techo', false);


	makeAnimatedLuaSprite('gf_rock', 'bgs/god_bg', 20, 20);
	addAnimationByPrefix('gf_rock', 'idle', "gf_rock", 30)
	objectPlayAnimation('gf_rock','idle');
	setScrollFactor('gf_rock', 0.8, 0.8)
	addLuaSprite('gf_rock', false);


	makeAnimatedLuaSprite('rock', 'bgs/god_bg', 20, 20);
	addAnimationByPrefix('rock', 'idle', "rock", 30)
	objectPlayAnimation('rock','idle');
	setScrollFactor('rock', 1,1)
	setProperty('rock.z', -0.001) --place below bf
	addLuaSprite('rock', false);
	--for funny z layering
	runHaxeCode('game.remove(game.modchartSprites["rock"]);')
	runHaxeCode('game.dadGroup.add(game.modchartSprites["rock"]);')

	makeAnimatedLuaSprite('trock', 'bgs/god_bg', 20, 20);
	addAnimationByPrefix('trock', 'idle', "rock", 30)
	objectPlayAnimation('trock','idle');
	setScrollFactor('trock', 1,1)
	addLuaSprite('trock', false);


	if seenCutscene then 
		godCutEnd = true;
		godMoveGf = true;
		godMoveSh = true;
	else 
		makeLuaText('skipText', 'Press SPACE to Skip', 0, 0, 698)
		setTextSize('skipText', 20)
		addLuaText('skipText')
	end

	if opponentPlay then 
		defaultZoom = 0.39 --so you can see
	end

end

local time = 0

--camera stuff
local lastShagHit = 1
local camcooldown = 0

local singAnims = {'singLEFT', 'singDOWN', 'singUP', 'singRIGHT', 'singUP', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'}
--sing cam moving shit
local singDirectionThing = {
	{-45, 0},
	{0, 45},
	{0, -45},
	{45, 0},
	{0, -45},
	{-45, 0},
	{0, 45},
	{0, -45},
	{45, 0}
}
local currentSingDir = {0,0}
local currentSingDirBF = {0,0}

function goodNoteHit(id, d, t, sus)
	currentSingDirBF = singDirectionThing[d+1]
end


--funny lerp for smooooth stuffs
local lerpedsh_r = 600

function lerp(a, b, ratio)
	return a + ratio * (b - a);
end

--tricky is seperate to not interupt the shags
local trickyCooldown = 0



function onUpdate(elapsed)


	local rotRate = curStep * 0.25;
	local rotRateSh = curStep / 9.5;
	local rotRateGf = curStep / 9.5 / 4;
	local derp = 12;
	local redsh_xpos = -630;
    local yellowsh_xpos = -480;
    local purplesh_xpos = -480;




	
	--cooldown stuffs
	if camcooldown <= 0 then 
		camcooldown = 0
	else 
		camcooldown = camcooldown - elapsed 
	end

	if trickyCooldown <= 0 then 
		trickyCooldown = 0
	else 
		trickyCooldown = trickyCooldown - elapsed 
	end


	--12 - kaio - 40 - fast
	--52 - eater
	--56 - blast


	

	setProperty('cameraSpeed', 2)
	if not getProperty('startedCountdown') then --during cutscene
		setProperty('camFollow.x', getProperty('boyfriend.x')-300);
		setProperty('camFollow.y', getProperty('boyfriend.y')-40);
		derp = 20;
	elseif not getProperty('endingSong') then 
		if (mustHitSection and not opponentPlay) or curStep >= 2880 then --bf cam
			cameraSetTarget('bf')
			if not opponentPlay then 
				setProperty('defaultCamZoom', 0.65)
			end		
			if curStep >= 2880 then 
				setProperty('defaultCamZoom', 0.4)
			end

			if trickyCooldown > 0 then --move to tricky
				
				runHaxeCode('game.camFollow.x += 700;')
				if (getPropertyFromClass('PlayState', 'god')) then 
					runHaxeCode('game.camFollow.x += 300;')
				end
				setProperty('defaultCamZoom', 0.6)
			end
			runHaxeCode('game.camFollow.x += '..currentSingDirBF[1]..';')
			runHaxeCode('game.camFollow.y += '..currentSingDirBF[2]..';')

		else --shaggy cam
			
			if lastShagHit == 1 then 
				cameraSetTarget('dad')
				runHaxeCode('game.defaultCamZoom = '..defaultZoom..' / game.dad.getZScale();') --the funny match zoom to z axis
				runHaxeCode('game.camFollow.x += '..currentSingDir[1]..';')
				runHaxeCode('game.camFollow.y += '..currentSingDir[2]..';')
			elseif lastShagHit == 2 then 
				runHaxeCode('game.camFollow.set(game.variables["blue"].getMidpoint().x + 150, game.variables["blue"].getMidpoint().y - 100);')
				runHaxeCode('game.camFollow.x += game.variables["blue"].cameraPosition[0] + game.opponentCameraOffset[0] + '..currentSingDir[1]..';')
				runHaxeCode('game.camFollow.y += game.variables["blue"].cameraPosition[1] + game.opponentCameraOffset[1] + '..currentSingDir[2]..';')
				runHaxeCode('game.defaultCamZoom = '..defaultZoom..' / game.variables["blue"].getZScale();')
			elseif lastShagHit == 3 then 
				runHaxeCode('game.camFollow.set(game.variables["red"].getMidpoint().x + 150, game.variables["red"].getMidpoint().y - 100);')
				runHaxeCode('game.camFollow.x += game.variables["red"].cameraPosition[0] + game.opponentCameraOffset[0] + '..currentSingDir[1]..';')
				runHaxeCode('game.camFollow.y += game.variables["red"].cameraPosition[1] + game.opponentCameraOffset[1] + '..currentSingDir[2]..';')
				runHaxeCode('game.defaultCamZoom = '..defaultZoom..' / game.variables["red"].getZScale();')
			elseif lastShagHit == 4 then 
				runHaxeCode('game.camFollow.set(game.variables["purple"].getMidpoint().x + 150, game.variables["purple"].getMidpoint().y - 100);')
				runHaxeCode('game.camFollow.x += game.variables["purple"].cameraPosition[0] + game.opponentCameraOffset[0] + '..currentSingDir[1]..';')
				runHaxeCode('game.camFollow.y += game.variables["purple"].cameraPosition[1] + game.opponentCameraOffset[1] + '..currentSingDir[2]..';')
				runHaxeCode('game.defaultCamZoom = '..defaultZoom..' / game.variables["purple"].getZScale();')
			end
		end
		--runHaxeCode('game.defaultCamZoom = 0.3;')


	end
	--why did i copy this
	if not getProperty('startedCountdown') then
		setProperty('camFollow.x', getProperty('boyfriend.x')-300);
		setProperty('camFollow.y', getProperty('boyfriend.y')-40);
	end
	if not introSkipped then 
		if keyboardJustPressed('SPACE') then --le cutscene skip
			introSkipped = true
			cancelTimer('snap')
			cancelTimer('introEnd')
			cancelTimer('fly')
			cancelTimer('hit')
			cancelTimer('scared')
			cancelTimer('shkUp')
			cancelTimer('shk')
			cancelTimer('godP1')
			cancelTimer('godP2')
			cancelTimer('godP3')
			cancelTimer('godP4')
			if not godCutEnd then 
				runTimer('quickEnd', 0.001)
			end
			godCutEnd = true;
			godMoveGf = true;
			godMoveSh = true;

			startCountdown()
		end

	end
	if (godCutEnd) and not getProperty('endingSong') then
	
		--[[if (!maskCreated)
		{
			if (isStoryMode && !FlxG.save.data.p_maskGot[1])
			{
				maskObj = new MASKcoll(2, 330, 660, 0);
				maskCollGroup.add(maskObj);
			}
			maskCreated = true;
		}]]--

		if songName == 'GODSPEED' then --events for godspeed remaster
			if (curStep < 191)then
				sh_r = 60;
			elseif ((curStep >= 896 and curStep <= 1024) or (curStep >= 2880) or (curStep >= 1536 and curStep <= 1792))then
				sh_r = sh_r + (60 - sh_r) / 32;
			else
				sh_r = 600;
				rotRateSh = rotRateSh*1.15;
				if (getPropertyFromClass('PlayState', 'god')) then 
					sh_r = 900
					setProperty('cameraSpeed', 3)
				end
			end
	
			if ((curBeat >= 32 and curBeat < 48) or (curBeat >= 124 * 4 and curBeat < 140 * 4)) then
			
				--[[if (boyfriend.animation.curAnim.name.startsWith('idle'))
				
					boyfriend.playAnim('scared', true);
				end]]--
			end
	
			if ((curStep >= 1024 and curStep <= 1536)) then
				rotRateSh = rotRateSh*1.25;
				sh_r = 700;
				if (getPropertyFromClass('PlayState', 'god')) then 
					sh_r = 1700
				end
				
			elseif ((curStep >= 1280 and curStep <= 1536)) then
				rotRateSh = rotRateSh*1.1;
			end
			if (curStep >= 2336 and curStep <= 2816) then
				rotRateSh = rotRateSh* 0.8;
				sh_r = 1000;
				if (getPropertyFromClass('PlayState', 'god')) then 
					sh_r = 2500
				end
			end
			if (curStep >= 2880) then
				--sh_r = 12000
				rotRateSh = rotRateSh*0.1;
			end
		elseif songName == "What I wanna know is where's the caveman" then 
			if (curStep < 127)then
				sh_r = 60;
			elseif ((curStep >= 1280 and curStep <= 1340) or (curStep >= 1856))then
				sh_r = sh_r + (60 - sh_r) / 32;
			else
				sh_r = 500;
			end		
		else  --events for godspeed old
			if (curStep < 255)then
				sh_r = 60;
			elseif ((curStep >= 1200 and curStep <= 1500) or (curStep >= 2880))then
				sh_r = sh_r + (60 - sh_r) / 32;
			else
				sh_r = 600;
				if (getPropertyFromClass('PlayState', 'god')) then 
					sh_r = 900
					setProperty('cameraSpeed', 3)
				end
			end
	
			if ((curBeat >= 32 and curBeat < 48) or (curBeat >= 124 * 4 and curBeat < 140 * 4)) then
			
				--[[if (boyfriend.animation.curAnim.name.startsWith('idle'))
				
					boyfriend.playAnim('scared', true);
				end]]--
			end
	
			if ((curBeat >= 248 and curBeat <= 280) or (curBeat >= 375 and curBeat <= 471) or (curBeat >= 560 and curBeat <= 592)) then
				rotRateSh = rotRateSh*1.25;
				sh_r = 700;
				if (getPropertyFromClass('PlayState', 'god')) then 
					sh_r = 1700
				end
				
			elseif ((curBeat >= 471 and curBeat <= 479) or (curBeat >= 592)) then
				rotRateSh = rotRateSh*1.1;
			elseif (curBeat >= 479 and curBeat <= 560) then
				rotRateSh = rotRateSh* 1.1;
				sh_r = 1000;
				if (getPropertyFromClass('PlayState', 'god')) then 
					sh_r = 2500
				end
			elseif (curBeat < 66 * 4) then
				rotRateSh = rotRateSh*1.1;
			elseif (curBeat < 132 * 4) then
				rotRateSh = rotRateSh*1.1;
			end
		end


		if (curStep >= 2880) and songName == 'GODSPEED' then --the zoom out thing at the end
			lerpedsh_r = lerpedsh_r + 1600 * elapsed
		else 
			lerpedsh_r = lerp(lerpedsh_r, sh_r, elapsed*2)
		end
		


		

		--the funny calcs
		local bf_toy = -2000 + math.sin(rotRate) * 20 + bfControlY;

		local sh_toy = -2450 + -math.sin(rotRateSh * 2) * lerpedsh_r * 0.45;
		local sh_tox = -330 -math.cos(rotRateSh) * lerpedsh_r;
		local sh_toz = -math.cos(rotRateSh*1.5) * lerpedsh_r * 0.3;

		local redsh_toy = -2450 - -math.sin(rotRateSh * 2) * lerpedsh_r * 0.75;
		local redsh_tox = redsh_xpos - -math.cos(rotRateSh) * lerpedsh_r;
		local redsh_toz = math.cos(rotRateSh*1.5) * lerpedsh_r * 0.3;

		local yellowsh_toy = -2950 + -math.cos(rotRateSh) * lerpedsh_r;
		local yellowsh_tox = yellowsh_xpos -math.sin(rotRateSh * 2) * lerpedsh_r * 0.25;
		local yellowsh_toz = math.sin(rotRateSh*1.5) * lerpedsh_r * 0.3;

		local purplesh_toy = -1950 - -math.cos(rotRateSh) * lerpedsh_r;
		local purplesh_tox = purplesh_xpos - -math.sin(rotRateSh * 2) * lerpedsh_r * 0.55;
		local purplesh_toz = -math.sin(rotRateSh*1.5) * lerpedsh_r * 0.3;
		

		local gf_tox = 100 + math.sin(rotRateGf) * 200;
		local gf_toy = -2000 -math.sin(rotRateGf) * 80;


		if (getPropertyFromClass('PlayState', 'god')) then 
			bf_toy = bf_toy - 2000
			sh_toy = sh_toy - 2000
			redsh_toy = redsh_toy - 2000
			yellowsh_toy = yellowsh_toy - 2000
			purplesh_toy = purplesh_toy - 2000
			--move em up for god mode so they have more space to fly around crazy
			
		end

		if (godMoveBf) then
		
			setProperty('boyfriend.y', getProperty('boyfriend.y') + (bf_toy-getProperty('boyfriend.y'))/derp);
			--boyfriend.y += (bf_toy - boyfriend.y) / derp;
			setProperty('rock.x', getProperty('boyfriend.x') - 200);
			setProperty('rock.y', getProperty('boyfriend.y') + 200);
			setProperty('rock.alpha', 1)


			runHaxeCode('game.variables["tricky"].x = 2750;')
			runHaxeCode('game.variables["tricky"].y = -2500;')
			runHaxeCode('game.variables["tricky"].z = -1000;')
			if not (getPropertyFromClass('PlayState', 'god')) then 
				runHaxeCode('game.variables["tricky"].flipX = true;')
			else 
				runHaxeCode('game.variables["tricky"].y += -400;')
			end
			setProperty('trock.x', 2750 - 650)
			setProperty('trock.y', -2330)
			setProperty('trock.z', -1000)

			if (getPropertyFromClass('PlayState', 'god')) then 
				runHaxeCode('game.variables["tricky"].y -= 2000;') --move up
				setProperty('trock.y', -2330-2000) --reposition for hellclown
				setProperty('trock.x', 2750 - 650 + 250)
			end

			--[[if (true)//(!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection) then
			
				if (FlxG.keys.pressed.UP and bfControlY > 0) then
				
					bfControlY --;
				end
				if (FlxG.keys.pressed.DOWN and bfControlY < 2290) then				
					bfControlY ++;
					if (bfControlY >= 400) then
						alterRoute = 1;
					end
				end
			end]]--
		end

		if (godMoveSh) then

			--shag positioning

			setProperty('dad.x', getProperty('dad.x') + (sh_tox-getProperty('dad.x'))/12);
			setProperty('dad.y', getProperty('dad.y') + (sh_toy-getProperty('dad.y'))/12);


			runHaxeCode('game.variables["red"].x += ('..redsh_tox..'-game.variables["red"].x)/12;')
			runHaxeCode('game.variables["red"].y += ('..redsh_toy..'-game.variables["red"].y)/12;')
			

			runHaxeCode('game.variables["purple"].x += ('..purplesh_tox..'-game.variables["purple"].x)/12;')
			runHaxeCode('game.variables["purple"].y += ('..purplesh_toy..'-game.variables["purple"].y)/12;')
			

			runHaxeCode('game.variables["blue"].x += ('..yellowsh_tox..'-game.variables["blue"].x)/12;')
			runHaxeCode('game.variables["blue"].y += ('..yellowsh_toy..'-game.variables["blue"].y)/12;')
			

			if (not getPropertyFromClass('ClientPrefs', 'performanceMode')) then --looks cool as shit but has its performance issues
				setProperty('dad.z', getProperty('dad.z') + (sh_toz-getProperty('dad.z'))/12);
				runHaxeCode('game.variables["red"].z += ('..redsh_toz..'-game.variables["red"].z)/12;')
				runHaxeCode('game.variables["purple"].z += ('..purplesh_toz..'-game.variables["purple"].z)/12;')
				runHaxeCode('game.variables["blue"].z += ('..yellowsh_toz..'-game.variables["blue"].z)/12;')
			end
			
		end

		if (godMoveGf) then
	
			--gf positioning
			setProperty('gf.x', getProperty('gf.x') + (gf_tox-getProperty('gf.x'))/derp);
			setProperty('gf.y', getProperty('gf.y') + (gf_toy-getProperty('gf.y'))/derp);

			setProperty('gf_rock.x', getProperty('gf.x') +80);
			setProperty('gf_rock.y', getProperty('gf.y') + 530);
			setProperty('gf_rock.alpha', 1)
			if (not gf_launched) then
			
				--gf.scrollFactor.set(0.8, 0.8);
				--gf.setGraphicSize(Std.int(gf.width * 0.8));

				setProperty('gf.scrollFactor.x', 0.8)
				setProperty('gf.scrollFactor.y', 0.8)
				local width = math.floor(getProperty('gf.width') * 0.8)	
				setProperty('gf.scale.x', width/getProperty('gf.frameWidth'))
				setProperty('gf.scale.y', width/getProperty('gf.frameWidth'))

				gf_launched = true;
			end
		end
	end
	if (not godCutEnd or not godMoveBf) and not getProperty('endingSong') then
		setProperty('rock.alpha', 0);
		setProperty('trock.x', 5000);

		runHaxeCode('game.variables["tricky"].x += -5000;') --hide tricky
	elseif opponentPlay and not getProperty('endingSong') then 
		runHaxeCode('game.variables["tricky"].x -= 1100;') --move tricky closer on opponent play
		setProperty('trock.x', getProperty('trock.x') - 1100)
	
	end



	--for start countdown, hide offscreen until set to true
	if not movePurp then 
		runHaxeCode('game.variables["purple"].x -= 500;')
		runHaxeCode('game.variables["purple"].y -= 200;')
	end
	if not moveRed then 
		runHaxeCode('game.variables["red"].x -= 500')
	end
	if not moveBlue then 
		runHaxeCode('game.variables["blue"].x -= 500')
		runHaxeCode('game.variables["purple"].y += 200;')
	end

	--hide gf rock
	if (not godMoveGf) then
		setProperty('gf_rock.alpha', 0);
	end
	time = time + (120 * elapsed); --for debris



    if godCutEnd and not getProperty('startedCountdown') then 
        for i = 0,3 do 
			--debugPrint('hi')
            local deba = 'debrisExplosion'..i
			
            local hsp = tonumber(debrisShit[i+1][7])/2
			--debugPrint('hi')
            vsp[i+1] = tonumber(vsp[i+1]) + 0.15

			
            setProperty(deba..'.x', getProperty(deba..'.x') + tonumber(hsp));
            setProperty(deba..'.y', getProperty(deba..'.y') + tonumber(vsp[i+1]));
            setProperty(deba..'.angle', getProperty(deba..'.angle') - (tonumber(hsp)/2));
			
        end
    end

	for i = 0,#debrisData-1 do 
		local deb = 'debris'..i

		--debris.x = debrisData[i][0];
		--debris.y = debrisData[i][1] + Math.sin((time + debrisData[i][5]) /50 * debrisData[i][4]) * 50 * debrisData[i][6];
		setProperty(deb..'.x', debrisData[i+1][1]);

		setProperty(deb..'.y', debrisData[i+1][2] + math.sin((time + debrisData[i+1][6]) /50 * debrisData[i+1][5]) * 50 * debrisData[i+1][7]);
	end

	if (getPropertyFromClass('ClientPrefs', 'extraStrums')) then 


		--strum positioning--

		if difficulty == 0 and getProperty('startedCountdown') then --for 4k
			for i = 0,7 do 
				if opponentPlay then 
					setPropertyFromGroup('playerStrums', i, 'alpha', 0.2) --lower strum alpha when opponent play
				end
			end
			for i = 8,11 do 
				runHaxeCode('game.strumLineNotes.members['..i..'].x = game.dad.x + (112*('..i..'%4)) - 75;')
				runHaxeCode('game.strumLineNotes.members['..i..'].y = game.dad.y - 90;');
				runHaxeCode('game.strumLineNotes.members['..i..'].z = game.dad.z;');
			end
			for i = 12,15 do 
				runHaxeCode('game.strumLineNotes.members['..i..'].x = game.variables["blue"].x + (112*('..i..'%4)) - 75;')
				runHaxeCode('game.strumLineNotes.members['..i..'].y = game.variables["blue"].y - 90;');
				runHaxeCode('game.strumLineNotes.members['..i..'].z = game.variables["blue"].z;');
			end
			for i = 16,19 do 
				runHaxeCode('game.strumLineNotes.members['..i..'].x = game.variables["red"].x + (112*('..i..'%4)) - 75;')
				runHaxeCode('game.strumLineNotes.members['..i..'].y = game.variables["red"].y - 90;');
				runHaxeCode('game.strumLineNotes.members['..i..'].z = game.variables["red"].z;');
			end
			for i = 20,23 do 
				runHaxeCode('game.strumLineNotes.members['..i..'].x = game.variables["purple"].x + (112*('..i..'%4)) - 75;')
				runHaxeCode('game.strumLineNotes.members['..i..'].y = game.variables["purple"].y - 90;');
				runHaxeCode('game.strumLineNotes.members['..i..'].z = game.variables["purple"].z;');
			end
		
			for i = 24,27 do 
				runHaxeCode('game.strumLineNotes.members['..i..'].x = game.variables["tricky"].x + (112*('..i..'%4)) + 160;')
				runHaxeCode('game.strumLineNotes.members['..i..'].y = game.variables["tricky"].y;');
				runHaxeCode('game.strumLineNotes.members['..i..'].z = game.variables["tricky"].z;');
			end

			for i = 8,27 do 
				if middlescroll and not opponentPlay then 
					runHaxeCode('game.strumLineNotes.members['..i..'].alpha = 0.35;') --lower alpha when middlescroll
				end
				if (opponentPlay and downscroll) then 
					runHaxeCode('game.strumLineNotes.members['..i..'].y += 750;'); --if downscroll and opponent play
				end
			end

		elseif getProperty('startedCountdown') then --for 9k
			for i = 0,17 do 
				setPropertyFromGroup('playerStrums', i, 'y', _G['defaultPlayerStrumY'..i])
				setPropertyFromGroup('playerStrums', i, 'z', 0)
				if opponentPlay then 
					setPropertyFromGroup('playerStrums', i, 'alpha', 0.2)
				end
			end
			for i = 18,26 do 
				runHaxeCode('game.strumLineNotes.members['..i..'].x = game.dad.x + (66.5*('..i..'%9)) - 75;')
				runHaxeCode('game.strumLineNotes.members['..i..'].y = game.dad.y - 90;');
				runHaxeCode('game.strumLineNotes.members['..i..'].z = game.dad.z;');

			end
			for i = 27,35 do 
				runHaxeCode('game.strumLineNotes.members['..i..'].x = game.variables["blue"].x + (66.5*('..i..'%9)) - 75;')
				runHaxeCode('game.strumLineNotes.members['..i..'].y = game.variables["blue"].y - 90;');
				runHaxeCode('game.strumLineNotes.members['..i..'].z = game.variables["blue"].z;');
			end
			for i = 36,44 do 
				runHaxeCode('game.strumLineNotes.members['..i..'].x = game.variables["red"].x + (66.5*('..i..'%9)) - 75;')
				runHaxeCode('game.strumLineNotes.members['..i..'].y = game.variables["red"].y - 90;');
				runHaxeCode('game.strumLineNotes.members['..i..'].z = game.variables["red"].z;');
			end
			for i = 45,53 do 
				runHaxeCode('game.strumLineNotes.members['..i..'].x = game.variables["purple"].x + (66.5*('..i..'%9)) - 75;')
				runHaxeCode('game.strumLineNotes.members['..i..'].y = game.variables["purple"].y - 90;');
				runHaxeCode('game.strumLineNotes.members['..i..'].z = game.variables["purple"].z;');
			end
		
			for i = 54,62 do 
				runHaxeCode('game.strumLineNotes.members['..i..'].x = game.variables["tricky"].x + (66.5*('..i..'%9)) + 160;')
				runHaxeCode('game.strumLineNotes.members['..i..'].y = game.variables["tricky"].y;');
				runHaxeCode('game.strumLineNotes.members['..i..'].z = game.variables["tricky"].z;');
			end

			for i = 18,62 do 
				if middlescroll and not opponentPlay then 
					runHaxeCode('game.strumLineNotes.members['..i..'].alpha = 0.35;')
				end
				if (opponentPlay and downscroll) then 
					runHaxeCode('game.strumLineNotes.members['..i..'].y += 750;');
				end
			end

			if (getPropertyFromClass('PlayState', 'god')) then 
				for i = 0,62 do
					--arrow movement on godmode
					setPropertyFromGroup('strumLineNotes', i, 'z', getPropertyFromGroup('strumLineNotes', i, 'z') + (lerpedsh_r/35) * math.sin(i+getSongPosition()*0.001))
					setPropertyFromGroup('strumLineNotes', i, 'y', getPropertyFromGroup('strumLineNotes', i, 'y') + (lerpedsh_r/80) * math.cos(i+getSongPosition()*0.001))
				end
			end
		end


		local noteCount = getProperty('notes.length');
		local fakeCrochet = (60 / bpm) * 1000



		local keyCount = 4;
		local arrowSize = 112
		if difficulty ~= 0 then 
			keyCount = 9
			arrowSize = 66.5
		end

		for i = 0, noteCount-1 do
			
			if string.find(getPropertyFromGroup('notes', i, 'noteType'), 'extraStrum') and not getPropertyFromGroup('notes', i, 'mustPress') then
				local noteData = math.abs(getPropertyFromGroup('notes', i, 'noteData'));
				local isSustainNote = getPropertyFromGroup('notes', i, 'isSustainNote');
				local n = getPropertyFromGroup('notes', i, 'noteType')
				local isSusEnd = string.find(string.lower(getPropertyFromGroup('notes', i, 'animation.curAnim.name')), 'end')
	
				--local yOffset = 50 - getPropertyFromGroup('strumLineNotes', noteData+4, 'y')
				local curPos = (getSongPosition()-getPropertyFromGroup('notes', i, 'strumTime')) * getProperty('songSpeed')

	
				
				if (opponentPlay and downscroll) then 
					local notePosY = 0
					if isSustainNote then --fix downscroll sustains, just psych engine code put into lua
						setPropertyFromGroup('notes', i, 'flipY', true)
		
						
						if isSusEnd then
							notePosY = notePosY + 10.5 * (fakeCrochet / 400) * 1.5 * scrollSpeed + (46 * (scrollSpeed - 1));
							notePosY = notePosY - (46 * (1 - (fakeCrochet / 600)) * scrollSpeed);
							notePosY = notePosY - 19;
						end
						notePosY = notePosY + ((arrowSize) / 2) - (60.5 * (scrollSpeed - 1));
						notePosY = notePosY + 27.5 * ((bpm / 100) - 1) * (scrollSpeed - 1);						
					end
					setPropertyFromGroup('notes', i, 'y', getPropertyFromGroup('strumLineNotes', noteData+keyCount, 'y') + (curPos*0.45) + notePosY);
				else 
					setPropertyFromGroup('notes', i, 'y', getPropertyFromGroup('strumLineNotes', noteData+keyCount, 'y') - (curPos*0.45)); --match y val properly
					setPropertyFromGroup('notes', i, 'flipY', false)
				end
				setPropertyFromGroup('notes', i, 'z', getPropertyFromGroup('strumLineNotes', noteData+keyCount, 'z'))

				if middlescroll then 
					setPropertyFromGroup('notes', i, 'alpha', 0.35)
				end
	
				setPropertyFromGroup('notes', i, 'x', getPropertyFromGroup('strumLineNotes', noteData+keyCount, 'x'))
				runHaxeCode('game.notes.members['..i..'].x += game.notes.members['..i..'].offsetX / game.notes.members['..i..'].getScaleRatioX();')
				if getPropertyFromGroup('notes', i, 'wasGoodHit') and not getPropertyFromGroup('notes', i, 'noteWasHit') and not getPropertyFromGroup('notes', i, 'ignoreNote') and not opponentPlay then 
					--hit the note lol
					setPropertyFromGroup('notes', i, 'noteWasHit', true)
					
					local time = 0.15
					if isSusEnd then  
						time = time + 0.15
					end
					if songName ~= 'GODSPEED' then 
						setProperty('vocals.volume', 1)
					end
					
					setProperty('camZooming', true)
					runHaxeCode('game.StrumPlayAnim(true, '..(noteData+keyCount)..', '..time..');') --play strum anim
					if not isSustainNote then --remove note
						runHaxeCode('game.notes.members['..i..'].kill();')
						runHaxeCode('game.notes.remove(game.notes.members['..i..'], true);')
						--runHaxeCode('game.notes.members['..i..'].destroy();')
					end
	
					shagNoteHit(noteData, n)
				end
			end
			
		end

	else 		
		if getProperty('startedCountdown') and getPropertyFromClass('PlayState', 'god') then --for 9k	
			for i = 0,17 do 
				setPropertyFromGroup('strumLineNotes', i, 'y', _G['defaultPlayerStrumY'..(0)])
				setPropertyFromGroup('strumLineNotes', i, 'z', 0)

				setPropertyFromGroup('strumLineNotes', i, 'z', getPropertyFromGroup('strumLineNotes', i, 'z') + (lerpedsh_r/35) * math.sin(i+getSongPosition()*0.001))
				setPropertyFromGroup('strumLineNotes', i, 'y', getPropertyFromGroup('strumLineNotes', i, 'y') + (lerpedsh_r/80) * math.cos(i+getSongPosition()*0.001))
			end
		end

	end





	
end
local lastPopup = 0

function onEvent(name, value1, value2)

	if name == 'moveshag' then 
		godMoveSh = true
	elseif name == 'movegf' then 
		godMoveGf = true
	elseif name == 'cutend' then 
		godCutEnd = true
	elseif name == 'stopShit' then
		godCutEnd = false
	elseif name == 'CreateRandomPopup' then
		if getPropertyFromClass('ClientPrefs', 'popups') then
			triggerEvent('CreateWindowPopup', ''..getRandomInt(1, 9)) --real popups, hardcoded shit because its literally spawning another window
		end
	elseif name == 'CreateRandomPopupHUD' then
		--hud popups
		
		if getPropertyFromClass('ClientPrefs', 'popups') then
			--triggerEvent('CreateRandomPopup')
			local popupname = 'popup'..lastPopup
			makeLuaSprite(popupname, 'PopUps/popup'..getRandomInt(1, 9))
			setObjectCamera(popupname, 'hud')
			addLuaSprite(popupname, true)
			local scale = getRandomFloat(0.45, 0.8)
			setProperty(popupname..'.scale.x', scale*0.75)
			setProperty(popupname..'.scale.y', scale*0.75)
			setProperty(popupname..'.alpha', 0)
			updateHitbox(popupname)
			setProperty(popupname..'.x', getRandomInt(getPropertyFromGroup('playerStrums', 0, 'x')-(getProperty(popupname..'.width')/2), getPropertyFromGroup('playerStrums', 8, 'x')+(getProperty(popupname..'.width')/2)))
			setProperty(popupname..'.y', getRandomInt(0, screenHeight-getProperty(popupname..'.height')))

			doTweenX(popupname..'x', popupname..'.scale', scale, 0.1, 'cubeInOut') --the funny tween
			doTweenY(popupname..'y',  popupname..'.scale', scale, 0.1, 'cubeInOut')
			doTweenAlpha(popupname..'a',  popupname, 1, 0.1, 'cubeInOut')
			lastPopup = lastPopup + 1
		end
	elseif name == 'ClearPopupsHUD' then
		
		if getPropertyFromClass('ClientPrefs', 'popups') then --remove all hud popups
			--triggerEvent('ClearWindows')
			for i = 0, lastPopup do 
				removeLuaSprite('popup'..(i))
			end
			lastPopup = 0
		end
	end
end

function onBeatHit()

	--play idle
	runHaxeCode('if (game.curBeat % game.variables["blue"].danceEveryNumBeats == 0 && game.variables["blue"].animation.curAnim != null && game.variables["blue"].animation.curAnim.name == "idle" && !game.variables["blue"].stunned) { game.variables["blue"].dance(); game.variables["blue"].color = 0x00FFFFFF; }')
	runHaxeCode('if (game.curBeat % game.variables["red"].danceEveryNumBeats == 0 && game.variables["red"].animation.curAnim != null && game.variables["red"].animation.curAnim.name == "idle" && !game.variables["red"].stunned) { game.variables["red"].dance(); game.variables["red"].color = 0x00FFFFFF; }')
	runHaxeCode('if (game.curBeat % game.variables["purple"].danceEveryNumBeats == 0 && game.variables["purple"].animation.curAnim != null && game.variables["purple"].animation.curAnim.name == "idle" && !game.variables["purple"].stunned) { game.variables["purple"].dance(); game.variables["purple"].color = 0x00FFFFFF; }')
	runHaxeCode('if (game.curBeat % game.variables["tricky"].danceEveryNumBeats == 0 && game.variables["tricky"].animation.curAnim != null && game.variables["tricky"].animation.curAnim.name == "idle" && !game.variables["tricky"].stunned) { game.variables["tricky"].dance(); game.variables["tricky"].color = 0x00FFFFFF; }')

	--reset miss color on opponent play
	runHaxeCode('if (game.curBeat % game.dad.danceEveryNumBeats == 0 && game.dad.animation.curAnim != null && game.dad.animation.curAnim.name == "idle" && !game.dad.stunned) { game.dad.color = 0x00FFFFFF; }') 

	if curBeat % 16 == 0 then 
		camcooldown = 0 --reset cooldown every section
	end

	if curBeat == 564 then 
		if (getPropertyFromClass('PlayState', 'god')) and not middlescroll and getPropertyFromClass('ClientPrefs', 'extraStrums') then 
			for i = 0,8 do
				noteTweenX(i, i+9, _G['defaultPlayerStrumX'..i]-320, crochet/250, 'cubeInOut') --middlescroll thing on god mode
			end
		end
	end
	--runHaxeCode('if (game.curBeat % game.variables["blue"].danceEveryNumBeats == 0 && game.variables["blue"].animation.curAnim != null && !game.variables["blue"].animation.curAnim.name.startsWith("sing") && !game.variables["blue"].stunned) game.variables["blue"].dance(); ')
	--runHaxeCode('if (game.curBeat % game.variables["red"].danceEveryNumBeats == 0 && game.variables["red"].animation.curAnim != null && !game.variables["red"].animation.curAnim.name.startsWith("sing") && !game.variables["red"].stunned) game.variables["red"].dance(); ')
	--runHaxeCode('if (game.curBeat % game.variables["purple"].danceEveryNumBeats == 0 && game.variables["purple"].animation.curAnim != null && !game.variables["purple"].animation.curAnim.name.startsWith("sing") && !game.variables["purple"].stunned) game.variables["purple"].dance(); ')
end

function opponentNoteHit(id, noteData, ntype, sus)

	--for opponent play or no extra strums
	shagNoteHit(noteData, ntype)

	--strum anim for opponent play

	local keyCount = 4;
	if difficulty ~= 0 then 
		keyCount = 9
	end
	
	if opponentPlay and getPropertyFromClass('ClientPrefs', 'extraStrums') then 
		local isSusEnd = string.find(string.lower(getPropertyFromGroup('notes', id, 'animation.curAnim.name')), 'end')
		local time = 0.15
		if isSusEnd then  
			time = time + 0.15
		end
		runHaxeCode('game.StrumPlayAnim(true, '..(noteData+keyCount)..', '..time..');')
	end


end

function shagNoteHit(noteData, ntype)
	local keyCount = 4;
	if difficulty ~= 0 then 
		keyCount = 9
	end
	setProperty('camZooming', true)

	currentSingDir = singDirectionThing[(noteData%keyCount)+1]

	if ntype == 'extraStrum1' then
		if camcooldown <= 0 then 
			lastShagHit = 1
		end
		runHaxeCode('game.dad.playAnim("'..singAnims[(noteData%keyCount)+1]..'", true);')
		runHaxeCode('game.dad.holdTimer = 0;')
		runHaxeCode('game.dad.color = 0x00FFFFFF;')

	elseif ntype == 'extraStrum2' then
		if camcooldown <= 0 then 
			lastShagHit = 2
		end
		runHaxeCode('game.variables["blue"].playAnim("'..singAnims[(noteData%keyCount)+1]..'", true);')
		runHaxeCode('game.variables["blue"].holdTimer = 0;')
		runHaxeCode('game.variables["blue"].color = 0x00FFFFFF;')
	elseif ntype == 'extraStrum3' then
		if camcooldown <= 0 then 
			lastShagHit = 3
		end
		runHaxeCode('game.variables["red"].playAnim("'..singAnims[(noteData%keyCount)+1]..'", true);')
		runHaxeCode('game.variables["red"].holdTimer = 0;')
		runHaxeCode('game.variables["red"].color = 0x00FFFFFF;')
	elseif ntype == 'extraStrum4' then
		if camcooldown <= 0 then 
			lastShagHit = 4
		end
		runHaxeCode('game.variables["purple"].playAnim("'..singAnims[(noteData%keyCount)+1]..'", true);')
		runHaxeCode('game.variables["purple"].holdTimer = 0;')
		runHaxeCode('game.variables["purple"].color = 0x00FFFFFF;')
	elseif ntype == 'extraStrum5' then
		trickyCooldown = 0.3
		
		runHaxeCode('game.variables["tricky"].playAnim("'..singAnims[(noteData%keyCount)+1]..'", true);')
		runHaxeCode('game.variables["tricky"].holdTimer = 0;')
		runHaxeCode('game.variables["tricky"].color = 0x00FFFFFF;')
	end
	
	if camcooldown <= 0 and ntype ~= 'extraStrum5' then 
		camcooldown = 0.25
	end

	if (getPropertyFromClass('PlayState', 'god')) then 
		cameraShake('game', 0.01, 0.01)
		cameraShake('hud', 0.01, 0.01)
		setProperty('chrom.strength', getProperty('chrom.strength')+0.0015)
	end
end

function noteMiss(id, noteData, ntype, sus)

	local keyCount = 4;
	if difficulty ~= 0 then 
		keyCount = 9
	end

	if opponentPlay then --for setting miss color
		if ntype == 'extraStrum1' then
			if camcooldown <= 0 then 
				lastShagHit = 1
			end
			runHaxeCode('game.dad.playAnim("'..singAnims[(noteData%keyCount)+1]..'", true);')
			runHaxeCode('game.dad.color = 0x00565694;')
	
		elseif ntype == 'extraStrum2' then
			if camcooldown <= 0 then 
				lastShagHit = 2
			end
			runHaxeCode('game.variables["blue"].playAnim("'..singAnims[(noteData%keyCount)+1]..'", true);')
			runHaxeCode('game.variables["blue"].color = 0x00565694;')
		elseif ntype == 'extraStrum3' then
			if camcooldown <= 0 then 
				lastShagHit = 3
			end
			runHaxeCode('game.variables["red"].playAnim("'..singAnims[(noteData%keyCount)+1]..'", true);')
			runHaxeCode('game.variables["red"].color = 0x00565694;')
		elseif ntype == 'extraStrum4' then
			if camcooldown <= 0 then 
				lastShagHit = 4
			end
			runHaxeCode('game.variables["purple"].playAnim("'..singAnims[(noteData%keyCount)+1]..'", true);')
			runHaxeCode('game.variables["purple"].color = 0x00565694;')
		elseif ntype == 'extraStrum5' then
			trickyCooldown = 0.3
			
			runHaxeCode('game.variables["tricky"].playAnim("'..singAnims[(noteData%keyCount)+1]..'", true);')
			runHaxeCode('game.variables["tricky"].color = 0x00565694;')
		end
	end
end



--cutscene shit--

local allowCountdown = false
function onStartCountdown()
	-- Block the first countdown and start a timer of 0.8 seconds to play the dialogue
	if not allowCountdown and not seenCutscene then
        godIntro()
        setPropertyFromClass('PlayState', 'seenCutscene', true)
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
        if not godCutEnd then 
            runTimer('shkUp', 0.002, 1)
        end
    elseif tag == 'godP1' then 
        runTimer('godP2', 0.85, 1)
        characterPlayAnim('dad','snap', true)
    elseif tag == 'godP2' then 
        playSound('snap')
        playSound('undSnap')
		setProperty('chrom.strength', getProperty('chrom.strength')+0.005)
        sShake = 10;
        runTimer('godP3', 1.5, 1)
        runTimer('snap', 0.06, 1)
    elseif tag == 'godP3' then 
        runTimer('shkUp', 0.002, 1)
        runTimer('godP4', 1, 1)
    elseif tag == 'godP4' or tag =='quickEnd' then 

        --spawn debris
		setProperty('chrom.strength', getProperty('chrom.strength')+0.02)

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
        if tag ~= 'quickEnd' then 
            runTimer('hit', 0.4, 1)
            runTimer('scared', 1, 1)
            runTimer('fly', 2, 1)
        end

        --cutend
        triggerEvent('cutend')
    elseif tag == 'hit' then 
        --movegf
        characterPlayAnim('bf','hurt', true)
        setProperty('boyfriend.specialAnim', true)
        triggerEvent('movegf')
    elseif tag == 'scared' then 
        if (getPropertyFromClass('PlayState', 'god')) then 
            characterPlayAnim('bf','scared', true)
            setProperty('boyfriend.specialAnim', true)
        end
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
    end
end
