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

  public static var projectileLevel = 1;

  public static var player:Player;

  public static var level = 1;
  public static var world = 1;
}
