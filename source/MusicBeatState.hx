package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
#if android
import flixel.FlxCamera;
import flixel.input.actions.FlxActionInput;
import ui.FlxVirtualPad;
import ui.Hitbox;
#end

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
	
	#if android
	var _virtualpad:FlxVirtualPad;
	var _hitbox:Hitbox;

	var trackedinputs:Array<FlxActionInput> = [];

	// adding virtualpad to state
	public function addVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
		_virtualpad = new FlxVirtualPad(DPad, Action);
		_virtualpad.alpha = 0.75;
		var padcam = new FlxCamera();
		FlxG.cameras.add(padcam);
		padcam.bgColor.alpha = 0;
		_virtualpad.cameras = [padcam];
		add(_virtualpad);
		controls.setVirtualPad(_virtualpad, DPad, Action);
		trackedinputs = controls.trackedinputs;
		controls.trackedinputs = [];

		#if android
		controls.addAndroidBack();
		#end
	}

	#if android
	public function addHitbox(mania:Int) {
		var curhitbox:HitboxType = DEFAULT;

		switch (mania){
			case 0:
				curhitbox = DEFAULT;
			case 1:
				curhitbox = SIX;
			case 2:
				curhitbox = SEVEN;					
			case 3:
				curhitbox = NINE;	
			case 4:
				curhitbox = THIRTEEN;
			case 5:
				curhitbox = TWENTYSIX;
			case 6:
				curhitbox = SIXTEEN;
			case 7:
				curhitbox = ONE;
			case 8:
				curhitbox = TEN;
			default:
				curhitbox = DEFAULT;
		}

		_hitbox = new Hitbox(curhitbox);

		var camcontrol = new flixel.FlxCamera();
		FlxG.cameras.add(camcontrol);
		camcontrol.bgColor.alpha = 0;
		_hitbox.cameras = [camcontrol];

		_hitbox.visible = false;
		add(_hitbox);
	}
	#end
	
	override function destroy() {
		controls.removeFlxInput(trackedinputs);

		super.destroy();
	}
	#else
	public function addVirtualPad(?DPad, ?Action){};
	#end

	override function create() {
		#if MODS_ALLOWED
		if(!ClientPrefs.imagesPersist) {
			Paths.customImagesLoaded.clear();
		}
		#end
		super.create();

		// Custom made Trans out
		if(!FlxTransitionableState.skipNextTransOut) {
			openSubState(new CustomFadeTransition(1, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor(((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / Conductor.stepCrochet);
	}

	public static function switchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new CustomFadeTransition(0.7, false));
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
