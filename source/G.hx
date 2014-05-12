package;

import flixel.util.FlxSave;
import flixel.group.FlxTypedGroup;
import flixel.FlxObject;
import flixel.util.FlxPoint;

class G
{
  public static var projectiles:FlxTypedGroup<FlxObject>;
  public static var dungeonObjects:FlxTypedGroup<FlxObject>;
  public static var dungeon:Dungeon;
  public static var reticle:Reticle;
  public static var slimeLocations:Array<FlxPoint>;
  public static var powerUpLocations:Array<FlxPoint>;
  public static var exitLocation:FlxPoint;

  public static var projectileLevel = 1;
  public static var maxHealth = 6;
  public static var maxStamina = 100;

  public static var player:Player;

  public static var level = 1;
  public static var world = 1;

  public static function init() {
    projectileLevel = 1;
    maxHealth = 6;
    maxStamina = 100;
    level = 1;
    world = 1;
  }

  public static function resetLocations():Void {
    G.slimeLocations = new Array<FlxPoint>();
    G.powerUpLocations = new Array<FlxPoint>();
  }
}
