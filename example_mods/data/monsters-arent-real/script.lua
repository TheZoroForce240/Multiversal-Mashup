function onCreatePost()
    setProperty('defaultCamZoom', 1)
    setProperty('camGame.zoom', 1)

    setProperty('dad.scrollFactor.x', 0)
    setProperty('dad.scrollFactor.y', 0)
    setGraphicSize('dad', 1280)
    screenCenter('dad', 'xy')

    setProperty('boyfriend.scrollFactor.x', 0)
    setProperty('boyfriend.scrollFactor.y', 0)
    setGraphicSize('boyfriend', 1280)
    screenCenter('boyfriend', 'xy')

    addLuaScript('shaggyGameOver')


    makeAnimatedLuaSprite('intro', 'bgs/mar/intro', 0, 0)
    addAnimationByPrefix('intro', 'playIntro', 'intro idle', 24, false)
    playAnim('intro', 'playIntro')

    setProperty('intro.active', false)

    setProperty('intro.scrollFactor.x', 0)
    setProperty('intro.scrollFactor.y', 0)
    screenCenter('intro', 'xy')
    setGraphicSize('intro', 1280, 720)
    screenCenter('intro', 'xy')

    addLuaSprite('intro', true)

    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
    setProperty('healthBar.visible', false)
    setProperty('healthBarBG.visible', false)

    setPropertyFromClass('PlayState', 'chartingMode', false) --for achivement
    setProperty('gf.visible', false)
    
end
function onUpdate(elapsed)
    setProperty('dad.visible', not mustHitSection)
    setProperty('boyfriend.visible', mustHitSection)
end

function onStepHit()
    if curStep == 5 then 
        playAnim('intro', 'playIntro')
        setProperty('intro.active', true)
        setProperty('intro.scrollFactor.x', 0)
        setProperty('intro.scrollFactor.y', 0)
        screenCenter('intro', 'xy')
        setGraphicSize('intro', 1280, 720)
        screenCenter('intro', 'xy')
    elseif curStep == 192 then 
        removeLuaSprite('intro')
        

        
    elseif curStep == 2432 then 
        cameraFlash('camGame', '0xFFFF0000', 0.3, true)
        if difficulty ~= 0 then 
            maniaChange(6)
        end
        

    elseif curStep == 2944 then 
        doTweenAlpha('game', 'camGame', 0, stepCrochet/250, 'linear')
    end
end


function maniaChange(keyNum) --ayo softcoded mania changes
    luaDebugMode = true
    addHaxeLibrary('Note')
    addHaxeLibrary('SwagSong', 'Song')
    addHaxeLibrary('SwagSection', 'Section')
    addHaxeLibrary('Math')
    addHaxeLibrary('Std')
    addHaxeLibrary('FlxMath', 'flixel.math')

    --trying new mania change system which reloads the chart and strums
    runHaxeCode([[
        game.KillNotes();
        //game.unspawnNotes = [];
        var ogMania = PlayState.mania;
        PlayState.keyAmmount = ]]..keyNum..[[;
        var mania = Note.keyAmmo.indexOf(]]..keyNum..[[);
        PlayState.mania = mania;
        PlayState.SONG.mania = mania;
        Note.mania = mania;
        Note.swagWidth = Note.noteWidths[mania];
        //game.notes.clear();
        //gen here
        

        for (section in PlayState.SONG.notes) //reload dat shit
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime = songNotes[0];
                if (daStrumTime >= Conductor.songPosition) //only load notes after current song pos
                {
                    var daNoteData = Std.int(songNotes[1] % PlayState.keyAmmount);

                    var gottaHitNote = section.mustHitSection;
    
                    if (songNotes[1] > PlayState.keyAmmount-1)
                    {
                        gottaHitNote = !section.mustHitSection;
                    }
    
                    var oldNote = null;
                    if (game.unspawnNotes.length > 0)
                        oldNote = game.unspawnNotes[Std.int(game.unspawnNotes.length - 1)];
                    else
                        oldNote = null;
    
                    var swagNote = new Note(daStrumTime, daNoteData, oldNote);
                    swagNote.mustPress = gottaHitNote;
                    swagNote.sustainLength = songNotes[2];
                    //swagNote.gfNote = (section.gfSection && (songNotes[1]<PlayState.keyAmmount));
                    swagNote.noteType = songNotes[3];
    
                    swagNote.scrollFactor.set();
    
                    var susLength = swagNote.sustainLength;
    
                    susLength = susLength / Conductor.stepCrochet;
                    game.unspawnNotes.push(swagNote);
    
                    
    
                    var floorSus = Math.floor(susLength);
                    if(floorSus > 0) {
                        for (susNote in 0...floorSus+1)
                        {
                            oldNote = game.unspawnNotes[Std.int(game.unspawnNotes.length - 1)];
    
                            var sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(game.songSpeed, 2)), daNoteData, oldNote, true);
                            sustainNote.mustPress = gottaHitNote;
                            //sustainNote.gfNote = (section.gfSection && (songNotes[1]<PlayState.keyAmmount));
                            sustainNote.noteType = swagNote.noteType;
                            sustainNote.scrollFactor.set();
                            //swagNote.tail.push(sustainNote);
                            //sustainNote.parent = swagNote;
                            game.unspawnNotes.push(sustainNote);
    
                        }
                    }
                }
				
                

			}
		}

		game.unspawnNotes.sort(game.sortByShit);

        

        //
        game.playerStrums.clear();
        game.opponentStrums.clear();
        game.strumLineNotes.clear();
        game.renderedStrumLineNotes.clear();
        game.generateStaticArrows(0);
        game.generateStaticArrows(1);
        for (i in 0...game.playerStrums.length) {
            game.setOnLuas('defaultPlayerStrumX' + i, game.playerStrums.members[i].x);
            game.setOnLuas('defaultPlayerStrumY' + i, game.playerStrums.members[i].y);
        }
        for (i in 0...game.opponentStrums.length) {
            game.setOnLuas('defaultOpponentStrumX' + i, game.opponentStrums.members[i].x);
            game.setOnLuas('defaultOpponentStrumY' + i, game.opponentStrums.members[i].y);
        }
        //setupBinds();
        //game.clearNotesBefore(Conductor.songPosition);

        game.keysArray = [
            ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left6k')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up6k')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right6k')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left6k2')),
            ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down6k')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right6k2'))
        ];


        PlayState.SONG.mania = ogMania;
        

    ]])
end