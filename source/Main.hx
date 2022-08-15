package;

import lime.app.Application;
import haxe.EntryPoint;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import openfl.display.Window;
import flixel.graphics.FlxGraphic;
import openfl.system.Capabilities;

import openfl.geom.Matrix;

//crash handler stuff
#if CRASH_HANDLER
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

using StringTools;


class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;
	public static var game:FlxGame;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
	
		ClientPrefs.loadDefaultKeys();
		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		addChild(game);
	
		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		//Lib.application.windows[0].borderless = true;
		
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}
		#end





		

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "PsychEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end



	//the funny

	public static function clearExtraWindows()
	{
		#if desktop
		if (Lib.application.windows.length == 1)
			return;


		while (Lib.application.windows.length > 1)
		{
			Lib.application.windows[Lib.application.windows.length-1].close();
		}

		#end
	}

	//buggy piece of shit
	//using the code for another mod and it works perfectly fine, can open as many windows as i want without causing a black screen (tested 100+ windows lmao),
	//for some reason loading an image can make the game run out of memory (i think thats what the issue is anyway, because sprites sometimes go black, and im guessing the camera goes black?????)
	public static function createFunnyPopup(num:Int = 1)
	{
		//var originallyFullscreen = FlxG.fullscreen;
		
		#if desktop
		game.focusLostFramerate = ClientPrefs.framerate;
		//trace(num);
		var graphicBitmap = Paths.image('PopUps/popup'+num).bitmap.clone();//BitmapData.fromFile('mods/images/PopUps/popup'+num+'.png');
		FlxG.autoPause = false;
		var resWidth = Capabilities.screenResolutionX;
		var resHeight = Capabilities.screenResolutionY;
		var scaleStuff = 1;
		//https://stackoverflow.com/questions/16273440/haxe-nme-resizing-a-bitmap
		//var resizedBitmap = new BitmapData(graphicBitmap.width, graphicBitmap.height, true);
		//var matrix:Matrix = new Matrix();
		//matrix.scale(scaleStuff, scaleStuff);
		//resizedBitmap.draw(graphicBitmap, matrix);



		var windowWidth = Std.int(graphicBitmap.width);
		var windowHeight = Std.int(graphicBitmap.height);
		var windowX = FlxG.random.int(0, Std.int(resWidth-windowWidth));
		var windowY = FlxG.random.int(0, Std.int(resHeight-windowHeight));
		var newWindow = Lib.application.createWindow({x: windowX, y: windowY, resizable: false, width: windowWidth, height: windowHeight, borderless: false, alwaysOnTop: true});
		newWindow.x = windowX;
		newWindow.y = windowY;


		Lib.application.windows[0].focus();
		//@:privateAccess
		//game.onFocus(null);

		if(ClientPrefs.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = ClientPrefs.framerate;
			FlxG.drawFramerate = ClientPrefs.framerate;
		} else {
			FlxG.drawFramerate = ClientPrefs.framerate;
			FlxG.updateFramerate = ClientPrefs.framerate;
		}
		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;
		FlxG.fullscreen = false; //sorry cant force fullscreen back
		//Lib.application.windows[0].fullscreen = originallyFullscreen;

		
		var popup = new FunnyPopup(graphicBitmap);
		newWindow.stage.addChild(popup);


		//storedBitmaps.push(resizedBitmap);
		//storedBitmaps.push(graphicBitmap);

		#end

	}


	public static function reFocusWindow() //i noticed that if you unfocus and refocus it fixes the camera angle cutting off the screen, need to figure out how to unfocus first
	{
		Lib.application.windows[0].focus();
	}
}

class FunnyPopup extends Sprite
{
	public var screen:Bitmap;
	public function new(bitData:BitmapData)
	{
		super();
		//cacheAsBitmap = false;
		screen = new Bitmap(bitData, true);
		//screen.cacheAsBitmap = false;
		addChild(screen);

	}
}
