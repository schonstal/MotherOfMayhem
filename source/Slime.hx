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

class Slime extends FlxSprite
{
  inline static var DASH_SPEED = 600;
  inline static var DASH_DRAG = 2;
  inline static var DASH_TIME = 0.8;

  static var OFFSET_Y = 15;
  static var OFFSET_X = 4;

  public var direction:FlxVector;

  public var started:Bool = false;
  public var dashing:Bool = false;
  var shaking:Bool = false;
  var seeking:Bool = false;
  var dead = false;
  var justHurt = false;
  var ready = true;

  public var shadow:FlxSprite;

  public function new(X:Float=0, Y:Float=0) {
    super();

    health = 3;

    x = X;
    y = Y;
    offset.y = OFFSET_Y + 100;

    loadGraphic("assets/images/areas/" + G.world + "/slime.png", true, 32, 32);

    width = 24;
    height = 12;

    animation.add("fall", [0]);
    animation.add("land", [1, 2, 3, 4], 15, false);
    animation.add("idle", [4, 4, 5, 6, 6, 7], 10, true);
    animation.add("wind-up", [8, 9, 9, 10, 10, 10, 10, 11], 20, true);
    animation.add("dash", [11, 12], 15, false);
    animation.add("return", [8, 4]);
    animation.add("die", [13, 14], 15, false);
    animation.add("dead", [14]);
    animation.add("hit", [15]);
    animation.callback = onAnimate;

    alpha = 0;
    animation.play("fall");

    shadow = new FlxSprite();
    shadow.loadGraphic("assets/images/areas/" + G.world + "/slime_shadow.png");
    shadow.offset.y = -4;
    shadow.offset.x = -1;
    shadow.visible = false;
  }

  public function updateShadow():Void {
    shadow.x = x;
    shadow.y = y - 1;
  }

  public override function update():Void {
    super.update();
    updateShadow();

    if(ready && FlxMath.isDistanceWithin(this, G.player, 40)) {
      ready = false;

      shadow.visible = true;

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
    
    if(!started || dead || justHurt) return;

    if(shaking) {
      offset.x = OFFSET_X + FlxRandom.intRanged(-1,1);
      offset.y = OFFSET_Y + FlxRandom.intRanged(-1,1);
    } else {
      offset.y = OFFSET_Y;
      offset.x = OFFSET_X;
    }

    if(dashing && Math.abs(velocity.x) < 1 && Math.abs(velocity.y) < 1) {
      onDashComplete();
    }

    if (seeking && G.dungeon.collisionTilemap.ray(G.player.getMidpoint(), getMidpoint())) {
      seeking = false;
      startDash();
    }
  }

  public function hit(damage:Int, direction:FlxVector):Void {
    if(damage == 0) damage = G.projectileLevel;

    velocity.x = direction.x * 200;
    velocity.y = direction.y * 200;
    drag.x = 400;
    drag.y = 400;
    animation.play("hit");
    justHurt = true;
    dashing = false;
    FlxG.camera.shake(damage * 0.0075, 0.3);
    health -= damage;
    if(health <= 0) {
      die();
    }

    new FlxTimer().start(0.1, function(t) {
      if(dead) return;
      animation.play("return");
      new FlxTimer().start(FlxRandom.floatRanged(0.25, 1), function(t) { seeking = true; });
      justHurt = false;
    });
  }

  private function die():Void {
    health = 0;
    dead = true;
    animation.play("die");
  }

  private function startDash():Void {
    FlxG.sound.play("assets/sounds/enemy_dash.wav", 0.5);
    direction = new FlxVector(G.player.x - x, G.player.y - y).normalize();

    velocity.x = direction.x * -100;
    velocity.y = direction.y * -100;

    animation.play("wind-up");
  }

  private function dash():Void {
    direction = new FlxVector(G.player.x - x, G.player.y - y).normalize();
    shaking = false;
    dashing = true;

    velocity.x = direction.x * DASH_SPEED;
    velocity.y = direction.y * DASH_SPEED;

    drag.x = Math.abs(direction.x) * DASH_SPEED * DASH_DRAG;
    drag.y = Math.abs(direction.y) * DASH_SPEED * DASH_DRAG;

    animation.play("dash");
  }

  public function cancelDash():Void {
    velocity.x = velocity.y = 0;
  }

  private function onDashComplete():Void {
    dashing = false;
    new FlxTimer().start(FlxRandom.floatRanged(0, 1), function(t) { seeking = true; });
    animation.play("return");
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
    if (name == "die" && frameIndex == 1) {
      animation.play("dead");
    }
  }
}
