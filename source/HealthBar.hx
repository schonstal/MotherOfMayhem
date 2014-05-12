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

class HealthBar extends StatBar
{
  public function new():Void {
    super(10, 10, 0xffe54558, 0xffd4d4d4, 0xff442b35);

    height = 6;
    setBar(1);
  }

  override public function update():Void {
    super.update();
    upgradeWidth(G.maxHealth * 15);
    setBar(G.player.health / G.maxHealth);
  }

}
