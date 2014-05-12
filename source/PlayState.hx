package;

import flixel.addons.effects.FlxWaveSprite;
import flixel.addons.effects.FlxGlitchSprite;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.group.FlxTypedGroup;

import flixel.text.FlxText;

import flixel.util.FlxRandom;
import flixel.util.FlxPoint;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.util.FlxVector;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;

import flash.display.BlendMode;
import flash.geom.Point;
import flash.filters.ColorMatrixFilter;

class PlayState extends FlxState
{
  private var cameraManager:CameraManager;
  private var water:FlxSprite;

  private var dungeon:Dungeon;
  private var enemies:FlxTypedGroup<FlxObject>;
  private var deadEnemies:FlxTypedGroup<FlxObject>;
  private var powerUps:FlxTypedGroup<FlxObject>;

  private var projectiles:FlxTypedGroup<FlxObject>;

  private var deathOverlay:FlxSprite;
  private var deathText:FlxText;
  private var deathMessageText:FlxText;

  private var dead:Bool = false;
  private var exitSprite:FlxSprite;
  private var exiting:Bool = false;

  private var exitSpriteCollider:FlxObject;

  override public function create():Void {
    super.create();
    Projectile.init();
    G.resetLocations();

    FlxG.camera.flash(0x181d23, 1);
    FlxG.mouse.visible = false;
    FlxG.debugger.drawDebug = true;
    FlxG.debugger.visible = true;

    G.dungeon = new Dungeon();
    add(G.dungeon);
    
    G.reticle = new Reticle();
    G.dungeonObjects = new FlxTypedGroup<FlxObject>();
    G.projectiles = new FlxTypedGroup<FlxObject>();

    exitSprite = new FlxSprite(G.exitLocation.x, G.exitLocation.y);
    exitSprite.loadGraphic("assets/images/areas/" + (G.level < 3 ? 1 : 2) + "/exit.png");
    add(exitSprite);

    //FUCK OFFSETS
    exitSpriteCollider = new FlxObject(exitSprite.x + 43, exitSprite.y + 43);
    exitSpriteCollider.width = exitSpriteCollider.height = 10;
    add(exitSpriteCollider);

    G.player = new Player();
    G.dungeonObjects.add(G.player);
    G.dungeonObjects.add(G.player.shadow);
    add(G.dungeonObjects);

    add(G.dungeon.wallTopTilemap);

    cameraManager = new CameraManager(G.player);
    add(cameraManager);

    G.player.started = true;

    add(G.reticle);

    FlxG.worldBounds.width = FlxG.worldBounds.height = Dungeon.SIZE * 32;
    FlxG.worldBounds.x = G.dungeon.wallTilemap.x;
    FlxG.worldBounds.y = G.dungeon.wallTilemap.y;

    FlxG.camera.pixelPerfectRender = false;

    enemies = new FlxTypedGroup<FlxObject>();
    deadEnemies = new FlxTypedGroup<FlxObject>();

    for(location in G.slimeLocations) {
      if((location.x > 1 || location.x < -1) && (location.y > 1 || location.y < -1)) {
        var slime = new Slime(location.x*32,location.y*32);
        enemies.add(slime);
        G.dungeonObjects.add(slime);
        G.dungeonObjects.add(slime.shadow);
      }
    }

    powerUps = new FlxTypedGroup<FlxObject>();
    for(location in G.powerUpLocations) {
      if((location.x > 1 || location.x < -1) && (location.y > 1 || location.y < -1)) {
        var powerUp = new PowerUp(location.x*32,location.y*32);
        powerUps.add(powerUp);
        G.dungeonObjects.add(powerUp);
        G.dungeonObjects.add(powerUp.shadow);
      }
    }
    
    var healthBar = new HealthBar();
    add(healthBar);

    var staminaBar = new StaminaBar();
    add(staminaBar);

    deathOverlay = new FlxSprite();
    deathOverlay.loadGraphic("assets/images/game_over.png");
    deathOverlay.scrollFactor.x = deathOverlay.scrollFactor.y = 0;
    deathOverlay.alpha = 0;
    add(deathOverlay);

    FlxG.sound.playMusic("assets/music/areas/" + G.world + "/a.wav");
  }

  override public function update():Void {
    super.update();
    FlxG.collide(G.player, G.dungeon.collisionTilemap, function(a,b):Void { G.player.cancelDash(); });
    FlxG.collide(enemies, G.dungeon.collisionTilemap);
    FlxG.collide(deadEnemies, G.dungeon.collisionTilemap);

    FlxG.overlap(enemies, G.player, function(enemy, player):Void {
      if(Std.is(enemy, Slime)) {
        if(!G.player.invulnerable && enemy.dashing) {
          FlxG.collide(cast(enemy, Slime), G.player);
          player.hit(G.world, enemy.direction);
        }
      }
    });

    FlxG.collide(G.projectiles, G.dungeon.wallTilemap, function(a,b):Void {
      if(Std.is(a, ProjectileSprite)) a.onCollide();
    });

    FlxG.overlap(G.projectiles, enemies, function(projectile, enemy):Void {
      if(Std.is(enemy, Slime)) {
        if(!enemy.started) return;

        if(Std.is(projectile, ProjectileSprite)) {
          projectile.onCollide();

          var direction:FlxVector = new FlxVector(projectile.velocity.x, projectile.velocity.y);

          enemy.hit(G.projectileLevel, direction.normalize());
          if(enemy.dead) {
            enemies.remove(cast(enemy, FlxObject));
            deadEnemies.add(cast(enemy, Slime));
          }
        }
      }
    });

    FlxG.overlap(powerUps, G.player, function(powerup, player):Void {
      if(!Std.is(powerup, PowerUp)) return;
      powerup.exists = false;
      FlxG.camera.flash(0x22ffffff, 0.3);
      if(powerup.type == 0) {
        G.maxHealth += 1;
        G.player.health = G.maxHealth;
      }
      if(powerup.type == 1) {
        G.maxStamina += 30;
      }
      if(powerup.type == 2) {
        G.projectileLevel += 1;
      }
      powerup.shadow.visible = false;
      powerUps.remove(cast(powerup, FlxObject));
    });

    FlxG.overlap(exitSpriteCollider, G.player, function(c,p):Void {
      G.level += 1;
      if(G.level == 4) G.world++;
      FlxG.switchState(new PlayState());
    });

    G.dungeonObjects.sort(FlxSort.byY, FlxSort.ASCENDING);

    if(G.player.completelyDead) {
      if(!dead) {
        dead = true;
        new FlxTimer(0.5, function(t) {
          FlxTween.tween(deathOverlay, { alpha: 1 }, 1, { ease: FlxEase.quadIn });
        });
      }
      if(FlxG.mouse.justPressed) {
        G.init();
        FlxG.switchState(new PlayState());
      }
    }
  }
}
