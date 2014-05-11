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

class Player extends FlxSprite
{
  inline static var SPEED = 110;

  inline static var DASH_DURATION = 0.25;
  inline static var DASH_SPEED = 500;
  inline static var IFRAME_DURATION = 0.25;

  inline static var RECOIL_SPEED = -200;
  inline static var RECOIL_DURATION = 0.2;

  inline static var STAMINA_REGEN = 30;

  public var invulnerable:Bool = false;
  public var started:Bool = false;

  public var stamina:Float = 0;
  public var shadow:FlxSprite;

  var staminaTimer:Float = 0;
  var staminaTime:Float = 0.5;

  var dashTween:VarTween;
  var dashScaleTween:VarTween;
  
  var dashing:Bool = false;
  var shooting:Bool = false;
  var justHurt:Bool = false;
  var dead:Bool = false;

  public var completelyDead:Bool = false;

  public function new() {
    super();

    health = G.maxHealth;
    stamina = G.maxStamina;

    loadGraphic("assets/images/player.png", true, 32, 32);
    setFacingFlip(FlxObject.LEFT, false, false);
    setFacingFlip(FlxObject.RIGHT, true, false);

    animation.add("walk", [4,5,6,7,8,9,10,11], 15, true);
    animation.add("walkBackwards", [4,11,10,9,8,7,6,5], 15, true);
    animation.add("idle", [0,1,1,2,3,3], 10);
    animation.add("dash", [12]);
    animation.add("shoot", [12]);
    animation.add("hurt", [13]);
    animation.add("die", [14,14,14,14,15,16,17,18,19,19], 20, false);
    animation.callback = onAnimate;

    width = 22;
    height = 12;
    offset.x = 4;
    offset.y = 20;

    x = 36;
    y = 0;
  }

  public override function update():Void {
    if(dead) {
      if(FlxG.timeScale < 1) {
        FlxG.timeScale += FlxG.elapsed * 2;
      }
      super.update();
      return;
    }

    if(!started) {
      velocity.x = velocity.y = 0;
      animation.play("idle");
      super.update();
      return;
    }

    staminaTimer += FlxG.elapsed;
    if(staminaTimer >= staminaTime) {
      if(stamina <= G.maxStamina) stamina += FlxG.elapsed * STAMINA_REGEN;
      else stamina = G.maxStamina;
      staminaTime = 0.5;
    }

    if(FlxG.keys.justPressed.UP) G.projectileLevel++;

    facing = FlxG.mouse.x < x + width/2 ? FlxObject.LEFT : FlxObject.RIGHT;

    if(!dashing && !justHurt) {
      processMovement();
    } else if(dashing) {
      animation.play("dash");
    }

    if(justHurt && Math.abs(velocity.x) < 1 && Math.abs(velocity.y) < 1) {
      onDashComplete(dashTween);
    }

    super.update();
  }

  public function hit(damage:Int=0, direction:FlxVector):Void {
    velocity.x = direction.x * 100;
    velocity.y = direction.y * 100;
    drag.x = 400;
    drag.y = 400;
    animation.play("hurt");
    justHurt = true;
    invulnerable = true;
    alpha = 0.6;
    G.reticle.deactivate();
    FlxG.camera.shake(damage * 0.0075, 0.3);
    health -= damage;
    if(health <= 0) {
      die();
    }
  }

  private function die():Void {
    health = 0;
    dead = true;
    animation.play("die");
    FlxG.timeScale = 0.1;
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
    if(shooting || justHurt || !useStamina(30)) return;

    G.reticle.deactivate();
    shooting = true;

    FlxG.sound.play("assets/sounds/fire_orb.wav");
    dashing = true;
    var p:Projectile = Projectile.recycled(getMidpoint().x,getMidpoint().y);
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
    if(shooting || justHurt || !useStamina(40)) return;
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
    justHurt = false;
    drag.x = drag.y = 0;
    G.reticle.activate();
    invulnerable = false;
    alpha = 1;
  }

  private function onIframeComplete(callback):Void {
    invulnerable = false;
  }

  private function useStamina(value:Int):Bool {
    if (stamina <= 0) return false;
    stamina -= value;
    staminaTimer = 0;
    if(stamina < 0) {
      stamina = 0;
      staminaTime = 1;
    }
    return true;
  }

  private function onAnimate(name:String, frame:Int, frameIndex:Int):Void {
    if (name == "walk" || name == "walkBackwards") {
      if (frame == 0 || frame == 4) {
        FlxG.sound.play("assets/sounds/footsteps/" + FlxRandom.intRanged(1,2) + ".wav", 0.3);
      }
    }

    if (name == "die" && frame == 8) {
      completelyDead = true;
      visible = false;
    }
  }
}
