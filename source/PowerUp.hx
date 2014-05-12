package;

import flixel.addons.effects.FlxTrail;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;

import flixel.group.FlxSpriteGroup;
import flixel.group.FlxTypedGroup;

import flixel.util.FlxVector;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;
import flixel.util.FlxMath;

import flash.display.BlendMode;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.tweens.misc.VarTween;

class PowerUp extends FlxSprite
{
  public var shadow:FlxSprite;
  public var type:Int = 0; //H, S, W

  var sinAmt:Float = 0;
  var originalOffset:Float;

  public function new(X:Float, Y:Float):Void {
    super(X,Y);
    loadGraphic("assets/images/upgrade.png", true, 25, 27);
    animation.add("0", [0]);
    animation.add("1", [1]);
    animation.add("2", [2]);
    if(FlxRandom.chanceRoll(50)) {
      type = 0;
    } else if (FlxRandom.chanceRoll(50)){
      type = 1;
    } else {
      type = 2;
    }
    animation.play(""+type);

    shadow = new FlxSprite(X,Y-1);
    shadow.loadGraphic("assets/images/upgrade_shadow.png");

    offset.x = (width - shadow.width)/2;
    originalOffset = (height - shadow.height)/2 + 16;
    offset.y = originalOffset;

    width = shadow.width;
    height = shadow.height;

    x += 10;
    y += 20;
  }

  public override function update():Void {
    shadow.x = x;
    shadow.y = y - 1;

    sinAmt += FlxG.elapsed * 2;
    offset.y = originalOffset + Math.sin(sinAmt) * 2;
    super.update();
  }
}
