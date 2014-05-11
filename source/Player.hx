package;

import flixel.addons.effects.FlxTrail;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;

import flixel.group.FlxSpriteGroup;
import flixel.group.FlxTypedGroup;

import flixel.util.FlxVector;
import flixel.util.FlxRandom;

import flash.display.BlendMode;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.tweens.misc.VarTween;

class Player extends FlxSprite
{
  inline static var SPEED = 130;

  inline static var DASH_DURATION = 0.25;
  inline static var DASH_SPEED = 500;
  inline static var IFRAME_DURATION = 0.25;

  inline static var RECOIL_SPEED = -200;
  inline static var RECOIL_DURATION = 0.2;

  public var invulnerable:Bool = true;
  public var started:Bool = false;

  var dashTween:VarTween;
  var dashScaleTween:VarTween;
  
  var dashing:Bool = false;
  var shooting:Bool = false;

  public function new() {
    super();

    loadGraphic("assets/images/player.png", true, 32, 32);
    setFacingFlip(FlxObject.LEFT, false, false);
    setFacingFlip(FlxObject.RIGHT, true, false);

    animation.add("walk", [4,5,6,7,8,9,10,11], 15, true);
    animation.add("walkBackwards", [4,11,10,9,8,7,6,5], 15, true);
    animation.add("idle", [0,1,1,2,3,3], 10);
    animation.add("dash", [12]);
    animation.add("shoot", [12]);
    animation.callback = onAnimate;

    width = 22;
    height = 12;
    offset.x = 4;
    offset.y = 20;

    x = 36;
    y = 0;
  }

  public override function update():Void {
    if(!started) {
      velocity.x = velocity.y = 0;
      animation.play("idle");
      super.update();
      return;
    }

    if(FlxG.keys.justPressed.UP) G.projectileLevel++;

    facing = FlxG.mouse.x < x + width/2 ? FlxObject.LEFT : FlxObject.RIGHT;

    if(!dashing) {
      processMovement();
    } else {
      animation.play("dash");
    }

    super.update();
  }

  private function processMovement():Void {
    var direction:FlxVector = new FlxVector(0,0);

    if(FlxG.keys.pressed.W) {
      direction.y = -1;
    }
    if(FlxG.keys.pressed.S) {
      direction.y = 1;
    }
    if(FlxG.keys.pressed.A) {
      direction.x = -1;
    }
    if(FlxG.keys.pressed.D) {
      direction.x = 1;
    }

    if(direction.length > 0) {
      velocity.x = direction.normalize().x * SPEED * (shooting ? 0.5 : 1);
      velocity.y = direction.normalize().y * SPEED * (shooting ? 0.5 : 1);
      if((velocity.x < 0 && facing == FlxObject.RIGHT) || (velocity.x > 0 && facing == FlxObject.LEFT)) {
        animation.play("walkBackwards");
      } else {
        animation.play("walk");
      }
    } else {
      velocity.x = velocity.y = 0;
      animation.play("idle");
    }

    if(FlxG.keys.justPressed.SPACE && (direction.x != 0 || direction.y != 0)) {
      startDash(direction.normalize());
    }

    if(FlxG.mouse.justPressed) {
      shootProjectile();
    }

  }

  private function shootProjectile():Void {
    if(shooting) return;

    G.reticle.deactivate();
    shooting = true;

    FlxG.sound.play("assets/sounds/fire_orb.wav");
    dashing = true;
    var p:Projectile = Projectile.recycled(x,y);
    G.dungeonObjects.add(p);

    velocity.x = p.direction.x * RECOIL_SPEED;
    velocity.y = p.direction.y * RECOIL_SPEED;

    scale.x = 1.2;
    scale.y = 0.8;

    drag.x = Math.abs(p.direction.x) * RECOIL_SPEED * -6;
    drag.y = Math.abs(p.direction.y) * RECOIL_SPEED * -6;
    animation.play("shoot");

    dashScaleTween = FlxTween.tween(scale, {
      x: 1,
      y: 1
    }, RECOIL_DURATION, { ease: FlxEase.quintOut, complete: onDashComplete });
  }

  private function startDash(direction:FlxVector):Void {
    if(shooting) return;
    FlxG.sound.play("assets/sounds/dash.wav", 0.3);

    velocity.x = direction.x * DASH_SPEED;
    velocity.y = direction.y * DASH_SPEED;
    //velocity.x = direction.x * DASH_SPEED;
    //velocity.y = direction.y * DASH_SPEED;
    dashing = true;
    invulnerable = true;
    scale.x = 1.5;
    scale.y = 0.5;
    alpha = 0.6;
    drag.x = Math.abs(direction.x) * DASH_SPEED * 4;
    drag.y = Math.abs(direction.y) * DASH_SPEED * 4;
    G.reticle.deactivate();

    dashScaleTween = FlxTween.tween(scale, {
        x: 1,
        y: 1
      }, DASH_DURATION, { ease: FlxEase.quintOut, complete: onDashComplete });

    FlxTween.tween(this, { alpha: 1 }, IFRAME_DURATION, { ease: FlxEase.quartIn, complete: onIframeComplete });
  }

  public function cancelDash():Void {
    velocity.x = velocity.y = 0;
  }

  private function onDashComplete(callback):Void {
    dashing = false;
    shooting = false;
    drag.x = drag.y = 0;
    G.reticle.activate();
  }

  private function onIframeComplete(callback):Void {
    invulnerable = false;
  }

  private function onAnimate(name:String, frame:Int, frameIndex:Int):Void {
    if (name == "walk" || name == "walkBackwards") {
      if (frame == 0 || frame == 4) {
        FlxG.sound.play("assets/sounds/footsteps/" + FlxRandom.intRanged(1,2) + ".wav", 0.3);
      }
    }
  }
}
