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

import flash.display.BlendMode;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.tweens.misc.VarTween;

class Slime extends FlxSprite
{
  inline static var DASH_SPEED = 1000;
  inline static var DASH_TIME = 0.6;

  inline static var OFFSET_Y = 0;
  inline static var OFFSET_X = 0;

  var shaking:Bool = false;
  var dashing:Bool = false;
  var seeking:Bool = false;
  var started:Bool = false;

  public function new(X:Float=0, Y:Float=0) {
    super();

    x = X;
    y = Y;

    offset.y = OFFSET_Y + 100;

    loadGraphic("assets/images/areas/" + G.world + "/slime.png", true, 32, 32);

    animation.add("fall", [0]);
    animation.add("land", [1, 2, 3, 4], 15, false);
    animation.add("idle", [4, 4, 5, 6, 6, 7], 10, true);
    animation.add("wind-up", [8, 9, 9, 10, 10, 10, 10, 11], 20, true);
    animation.add("dash", [11, 12], 15, false);
    animation.add("return", [8, 4]);
    animation.add("die", [13, 14], 15, false);
    animation.add("hit", [15]);
    animation.callback = onAnimate;
    
    animation.play("fall");
    alpha = 0;
    FlxTween.tween(this, {
      alpha: 1,
    }, 0.75, { ease: FlxEase.quadIn, complete: function(t) { 
      animation.play("land");
      started = true;
    }});
    
    FlxTween.tween(offset, {
      y: OFFSET_Y,
    }, 0.75, { ease: FlxEase.quadIn });
  }

  public override function update():Void {
    super.update();
    if(!started) return;

    if(shaking) {
      offset.x = FlxRandom.intRanged(-1,1);
      offset.y = FlxRandom.intRanged(-1,1);
    } else {
      offset.y = OFFSET_Y;
      offset.x = OFFSET_X;
    }

    if(dashing == true && Math.abs(velocity.x) < 1 && Math.abs(velocity.y) < 1) {
      onDashComplete();
    }

    if (seeking) {
      seeking = false;
      new FlxTimer().start(FlxRandom.floatRanged(2, 5), function(t) { startDash(); });
    }
  }

  private function startDash():Void {
    var direction = new FlxVector(G.player.x - x, G.player.y - y).normalize();

    velocity.x = direction.x * -100;
    velocity.y = direction.y * -100;

    animation.play("wind-up");
  }

  private function dash():Void {
    var direction = new FlxVector(G.player.x - x, G.player.y - y).normalize();
    shaking = false;
    dashing = true;

    velocity.x = direction.x * DASH_SPEED;
    velocity.y = direction.y * DASH_SPEED;

    drag.x = Math.abs(direction.x) * DASH_SPEED * 4;
    drag.y = Math.abs(direction.y) * DASH_SPEED * 4;

    animation.play("dash");
  }

  public function cancelDash():Void {
    velocity.x = velocity.y = 0;
  }

  private function onDashComplete():Void {
    dashing = false;
    animation.play("return");
    new FlxTimer().start(FlxRandom.floatRanged(0, 1), function(t) { startDash(); });
  }

  private function onAnimate(name:String, frame:Int, frameIndex:Int):Void {
    if (name == "wind-up") {
      if (frameIndex == 9) shaking = true;
      if (frameIndex == 11) dash();
    }

    if (name == "return" && frameIndex == 4) animation.play("idle");
    if (name == "land" && frameIndex == 3) {
      seeking = true;
      animation.play("idle");
    }
  }
}
