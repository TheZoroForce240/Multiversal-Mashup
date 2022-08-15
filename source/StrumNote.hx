package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumNote extends FlxPerspectiveSprite
{
	private var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;
	
	private var player:Int;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public var defaultX:Float = 0;
	public var defaultY:Float = 0;
	public var curID:Int = 0;
	public var curMania:Int = 0;

	public static var dirArray:Array<Dynamic> = [
        ['LEFT0', 'DOWN0', 'UP0', 'RIGHT0'],
        ['LEFT0', 'UP0', 'RIGHT0', 'LEFT0', 'DOWN0', 'RIGHT0'],
        ['LEFT0', 'DOWN0', 'UP0', 'RIGHT0', 'SPACE', 'LEFT0', 'DOWN0', 'UP0', 'RIGHT0'],
        ['LEFT0', 'DOWN0', 'SPACE', 'UP0', 'RIGHT0'],
        ['LEFT0', 'UP0', 'RIGHT0', 'SPACE', 'LEFT0', 'DOWN0', 'RIGHT0'],
        ['LEFT0', 'DOWN0', 'UP0', 'RIGHT0', 'LEFT0', 'DOWN0', 'UP0', 'RIGHT0'],
        ['SPACE'],
        ['LEFT0', 'RIGHT0'],
        ['LEFT0', 'SPACE', 'RIGHT0'],
		['LEFT0', 'DOWN0', 'UP0', 'RIGHT0', 'SPACE','SPACE', 'LEFT0', 'DOWN0', 'UP0', 'RIGHT0'],
		['LEFTSHARP', 'UPSHARP', 'RIGHTSHARP', 'LEFT0', 'UP0', 'RIGHT0', 'LEFT0', 'DOWN0', 'RIGHT0', 'LEFTSHARP', 'DOWNSHARP', 'RIGHTSHARP']
    ];
	public static var colorFromData:Array<Array<Int>> = [
		[0,1,2,3],
		[0,2,3,6,1,9],
		[0,1,2,3,4,6,7,8,9],
		[0,1,4,2,3],
		[0,2,3,4,6,1,9],
		[0,1,2,3,6,7,8,9],
		[4],
		[0,3],
		[0,4,3],
		[0,1,2,3,4,5,6,7,8,9],
		[0,2,3,0,2,3,6,1,7,6,1,7]
	];
	public static var maniaSwitchPositions:Array<Dynamic> = [
        [0, 1, 2, 3, "alpha0", "alpha0", "alpha0", "alpha0", "alpha0","alpha0"],
        [0, 4, 1, 2, "alpha0","alpha0",3,"alpha0", "alpha0", 5],
        [0, 1, 2, 3, 4, "alpha0", 5, 6, 7, 8],
        [0, 1, 3, 4, 2, "alpha0", "alpha0","alpha0", "alpha0", "alpha0"],
        [0, 5, 1, 2, 3,"alpha0", 4, "alpha0", "alpha0", 6],
        [0, 1, 2, 3, "alpha0", "alpha0", 4, 5, 6, 7],
        ["alpha0", "alpha0", "alpha0", "alpha0", 0, "alpha0","alpha0", "alpha0", "alpha0", "alpha0"],
        [0, "alpha0", "alpha0", 1, "alpha0", "alpha0","alpha0", "alpha0", "alpha0", "alpha0"],
        [0, "alpha0", "alpha0", 2, 1, "alpha0","alpha0", "alpha0", "alpha0", "alpha0"],
		[0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    ];

	public function new(x:Float, y:Float, leData:Int, player:Int) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		curMania = Note.mania;
		super(x, y);

		var skin:String = 'NOTE_assets';
		if(PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) skin = PlayState.SONG.arrowSkin;
		texture = skin; //Load texture and anims

		scrollFactor.set();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		if(PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + texture));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + texture), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purple', [4]);
			switch (Math.abs(noteData))
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture);
			//animation.addByPrefix('green', 'arrowUP');
			//animation.addByPrefix('blue', 'arrowDOWN');
			//animation.addByPrefix('purple', 'arrowLEFT');
			//animation.addByPrefix('red', 'arrowRIGHT');

			antialiasing = ClientPrefs.globalAntialiasing;
			setGraphicSize(Std.int(width * Note.noteScales[PlayState.mania]));

			animation.addByPrefix('static', 'arrow' + dirArray[Note.mania][noteData]);
			animation.addByPrefix('pressed', Note.frameN[Note.mania][noteData] + ' press', 24, false);
			animation.addByPrefix('confirm', Note.frameN[Note.mania][noteData] + ' confirm', 24, false);
		}
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		x -= Note.posRest[Note.mania];
		ID = noteData;
		curID = noteData;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		if(animation.curAnim != null){ //my bad i was upset
			if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
				centerOrigin();
		}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
		if(animation.curAnim == null || animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		} else {
			colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

			if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
				centerOrigin();
			}
		}
	}


	public function moveKeyPositions(spr:FlxSprite, newMania:Int, playe:Int, quickChange:Bool = true, showStartAnim:Bool = false):Void 
		{
			var whereNoteGo:Float = ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X;
	
			if (playe > 1)
				whereNoteGo = PlayState.STRUM_X;
			
			spr.visible = true;
			curMania = newMania;
	
			//curScaleX = scale.x;
			//curScaleY = scale.y;
	
			whereNoteGo += 50;
			if (playe < 2)
				whereNoteGo += ((FlxG.width / 2) * playe);
			else 
			{
				whereNoteGo += ((FlxG.width / 2) * (playe - 2));
			}
			whereNoteGo -= Note.posRest[newMania];
			//whereNoteGo += xOffset;
			
			if (maniaSwitchPositions[newMania][spr.ID] == "alpha0")
			{
				spr.visible = false;
			}            
			else
			{
				var multi:Float = 1;
	
	
				whereNoteGo += Note.noteWidths[newMania] * maniaSwitchPositions[newMania][spr.ID] * multi;
				
				var targetAlpha:Float = 1;
				if (playe < 1 && ClientPrefs.middleScroll) targetAlpha = 0.35;
	
				if(ClientPrefs.middleScroll && playe == 0)
					{
						whereNoteGo += 310;
						if(maniaSwitchPositions[newMania][spr.ID] >= Note.keyAmmo[newMania] / 2) { //Up and Right
							whereNoteGo += FlxG.width / 2 + 25;
						}
					}
	
				curID = maniaSwitchPositions[newMania][spr.ID];
				if (!quickChange)
				{
					if (showStartAnim)
					{
						spr.x = whereNoteGo;
						spr.y -= 10;
						var strumY = 50;
						if (ClientPrefs.downScroll)
							strumY = FlxG.height - 150;
						
						FlxTween.tween(this, {alpha: targetAlpha, y: strumY}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * ((curID * 4) / Note.keyAmmo[newMania]))});
					}
					else
						FlxTween.tween(this, {alpha: targetAlpha, x:whereNoteGo}, 1, {ease: FlxEase.circOut, startDelay: 0.01 + (0.2 * ((curID * 4) / Note.keyAmmo[newMania]))});
				}
				else 
				{
					spr.alpha = targetAlpha;
					spr.x = whereNoteGo;
				}
					
			}
				
	
	
			defaultX = whereNoteGo;
		}
}
