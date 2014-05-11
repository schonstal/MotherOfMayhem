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

class StatBar extends FlxTypedGroup<FlxObject>
{
  public var height = 8;

  var barWidth:Int;

  var borderWidth:FlxSprite;
  var borderHeight:FlxSprite;
  var borderShadowWidth:FlxSprite;
  var borderShadowHeight:FlxSprite;
  var background:FlxSprite;
  var bar:FlxSprite;

  var barColor:Int;
  var borderColor:Int;
  var backgroundColor:Int;

  public function new(X:Float=0, Y:Float=0, BarColor:Int = 0xffff00ff, BorderColor:Int = 0xffd4d4d4, BackgroundColor:Int = 0xff000000, BorderShadowColor:Int = 0xff303030):Void {
    super();

    barColor = BarColor;
    borderColor = BorderColor;
    backgroundColor = BackgroundColor;

    borderShadowHeight = new FlxSprite(X, Y+1);
    borderShadowHeight.color = BorderShadowColor;
    borderShadowHeight.loadGraphic("assets/images/pixel.png");
    borderShadowHeight.scrollFactor.x = borderShadowHeight.scrollFactor.y = 0;
    add(borderShadowHeight);

    borderShadowWidth = new FlxSprite(X-1, Y+2);
    borderShadowWidth.loadGraphic("assets/images/pixel.png");
    borderShadowWidth.color = BorderShadowColor;
    borderShadowWidth.scrollFactor.x = borderShadowWidth.scrollFactor.y = 0;
    add(borderShadowWidth);

    borderWidth = new FlxSprite(X-1, Y);
    borderWidth.loadGraphic("assets/images/pixel.png");
    borderWidth.color = BorderColor;
    borderWidth.scrollFactor.x = borderWidth.scrollFactor.y = 0;
    add(borderWidth);

    borderHeight = new FlxSprite(X, Y-1);
    borderHeight.color = BorderColor;
    borderHeight.loadGraphic("assets/images/pixel.png");
    borderHeight.scrollFactor.x = borderHeight.scrollFactor.y = 0;
    add(borderHeight);

    background = new FlxSprite(X, Y);
    background.color = BackgroundColor;
    background.loadGraphic("assets/images/pixel.png");
    background.scrollFactor.x = background.scrollFactor.y = 0;
    add(background);

    bar = new FlxSprite(X, Y);
    bar.color = BarColor;
    bar.loadGraphic("assets/images/pixel.png");
    bar.scrollFactor.x = bar.scrollFactor.y = 0;
    add(bar);
  }

  public function upgradeWidth(Width:Int):Void {
    barWidth = Width;
    borderWidth.scale.x = barWidth + 2;
    borderWidth.scale.y = height;

    borderHeight.scale.x = barWidth;
    borderHeight.scale.y = height + 2;

    borderShadowWidth.scale.x = barWidth + 2;
    borderShadowWidth.scale.y = height;

    borderShadowHeight.scale.x = barWidth;
    borderShadowHeight.scale.y = height + 2;

    background.scale.x = barWidth;
    background.scale.y = height;

    borderShadowWidth.offset.x = -borderShadowWidth.scale.x / 2;
    borderShadowWidth.offset.y = -borderShadowWidth.scale.y / 2;

    borderShadowHeight.offset.x = -borderShadowHeight.scale.x / 2;
    borderShadowHeight.offset.y = -borderShadowHeight.scale.y / 2;

    borderWidth.offset.x = -borderWidth.scale.x / 2;
    borderWidth.offset.y = -borderWidth.scale.y / 2;

    borderHeight.offset.x = -borderHeight.scale.x / 2;
    borderHeight.offset.y = -borderHeight.scale.y / 2;

    background.offset.x = -background.scale.x / 2;
    background.offset.y = -background.scale.y / 2;

    //borderWidth.makeGraphic(Width+2, healthBar ? HEALTH_HEIGHT : STAMINA_HEIGHT, borderColor);
    //borderHeight.makeGraphic(Width, (healthBar ? HEALTH_HEIGHT : STAMINA_HEIGHT) + 2, borderColor);
    //background.makeGraphic(Width, healthBar ? HEALTH_HEIGHT : STAMINA_HEIGHT, backgroundColor);
  }

  // Value from 0-1, percentage.
  public function setBar(Value:Float):Void {
    bar.scale.x = barWidth * Value;
    bar.scale.y = height;

    bar.offset.x = -bar.scale.x / 2;
    bar.offset.y = -bar.scale.y / 2;
    //bar.makeGraphic(Std.int((barWidth-2) * Value), healthBar ? HEALTH_HEIGHT : STAMINA_HEIGHT, barColor);
  }
}
