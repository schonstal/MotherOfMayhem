package;

import flixel.util.FlxSave;
import flixel.group.FlxTypedGroup;
import flixel.FlxObject;
import flixel.util.FlxPoint;

class G
{
  public static var projectiles:FlxTypedGroup<FlxObject>;
  public static var dungeonObjects:FlxTypedGroup<FlxObject>;
  public static var reticle:Reticle;

  public static var level = 0;
}
