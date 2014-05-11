package;

import flixel.group.FlxTypedGroup;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;

import flixel.util.FlxRandom;
import flixel.util.FlxStringUtil;
import flixel.util.FlxVector;
import flixel.util.FlxTimer;

import flixel.tile.FlxTilemap;

class StaminaBar extends StatBar
{
  public function new():Void {
    super(10, 21, 0xff4e98d6, 0xffd4d4d4, 0xff2e3441);

    height = 4;
    upgradeWidth(60);
    setBar(1);
  }

  override public function update():Void {
    super.update();
    setBar(G.player.stamina / G.maxStamina);
  }
}
