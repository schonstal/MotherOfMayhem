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

  private var projectiles:FlxTypedGroup<FlxObject>;

  override public function create():Void {
    super.create();
    Projectile.init();

    FlxG.camera.flash(0x181d23, 1);
    FlxG.mouse.visible = false;
    FlxG.debugger.drawDebug = true;
    FlxG.debugger.visible = true;

    G.dungeon = new Dungeon();
    add(G.dungeon);
    
    G.reticle = new Reticle();
    G.dungeonObjects = new FlxTypedGroup<FlxObject>();
    G.projectiles = new FlxTypedGroup<FlxObject>();

    G.player = new Player();
    G.dungeonObjects.add(G.player);
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

    for(i in 0...2) {
    for(j in 0...2) {
    var slime = new Slime(i*32,j*32);
    enemies.add(slime);
    G.dungeonObjects.add(slime);
    }
    }
    
    var healthBar = new HealthBar();
    add(healthBar);

    var staminaBar = new StaminaBar();
    add(staminaBar);
  }

  override public function update():Void {
    super.update();
    FlxG.collide(G.player, G.dungeon.collisionTilemap, function(a,b):Void { G.player.cancelDash(); });
    FlxG.collide(enemies, G.dungeon.collisionTilemap);

    FlxG.overlap(enemies, G.player, function(enemy, player):Void {
      if(Std.is(enemy, Slime)) {
        if(!G.player.invulnerable && enemy.dashing) {
          FlxG.collide(cast(enemy, Slime), G.player);
          player.hit(1, enemy.direction);
        }
      }
    });

    FlxG.collide(G.projectiles, G.dungeon.wallTilemap, function(a,b):Void {
      if(Std.is(a, ProjectileSprite)) a.onCollide();
    });

    G.dungeonObjects.sort(FlxSort.byY, FlxSort.ASCENDING);
  }
}
