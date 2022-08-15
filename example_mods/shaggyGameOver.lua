function onCreatePost()
    setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'fnf_loss_shaggy')
	setPropertyFromClass('GameOverSubstate', 'loopSoundName', '')
end
function onUpdatePost(elapsed)
    if inGameOver then 
		setProperty('boyfriend.visible', false)
	end
end
function onGameOverStart()
	runTimer('restart', 1)
end
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'restart' then 
		restartSong()
	end
end