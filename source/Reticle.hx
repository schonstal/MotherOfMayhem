package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxCamera;

import flixel.util.FlxRandom;
import flixel.util.FlxPoint;

import flash.display.BlendMode;

class Reticle extends FlxSprite
{
  var bigSprite:FlxSprite;
  var littleSprite:FlxSprite;
  var usable:Bool = true;
  
  public function new() {
    super();

    loadGraphic("assets/images/reticle.png", false, 16, 16);
    animation.add("default", [0,0,1,2,3,4,4,5,6,7], 10, true);
    animation.play("default");

    blend = BlendMode.ADD;
    activate();
  }

  public function activate():Void {
    usable = true;
  }

  public function deactivate():Void {
    usable = false;
  }

  public override function update():Void {
    super.update();

    if(usable && G.player.stamina > 0) {
      alpha = 0.75;
    } else {
      alpha = 0.25;
    }

    x = FlxG.mouse.x - width/2 + 1;
    y = FlxG.mouse.y - height/2 + 1;
  }
}
