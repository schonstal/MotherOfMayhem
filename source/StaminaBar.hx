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
  inline static var FLICKER_TIME = 0.1;
  var flickerTimer:Float = 0;

  var on:Bool = false;

  public function new():Void {
    super(10, 21, 0xff4e98d6, 0xffd4d4d4, 0xff2e3441);

    height = 4;
    upgradeWidth(60);
    setBar(1);
  }

  override public function update():Void {
    super.update();
    setBar(G.player.stamina / G.maxStamina);

    if(G.player.stamina <= 0) {
      flickerTimer += FlxG.elapsed;
      if (flickerTimer >= FLICKER_TIME) {
        background.color = borderWidth.color = borderHeight.color = (on ? borderColor : backgroundColor);
        on = !on;
//        background.color = (background.color == backgroundColor ? borderColor : backgroundColor);
        flickerTimer = 0;
      }
    } else {
      on = false;
      borderWidth.color = borderHeight.color = borderColor;
      background.color = backgroundColor;
      flickerTimer = FLICKER_TIME;
    }
  }
}
