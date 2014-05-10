package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.util.FlxPoint;

class CameraManager extends FlxObject
{
  private var objectToFollow:FlxObject;

  public function new(Follow:FlxObject) {
    super();
    objectToFollow = Follow;
    FlxG.camera.follow(this, FlxCameraFollowStyle.LOCKON, new FlxPoint(-objectToFollow.width/2,-objectToFollow.height/2), 0);
  }

  public override function update():Void {
    x = (FlxG.mouse.x + objectToFollow.x*3)/4;
    y = (FlxG.mouse.y + objectToFollow.y*3)/4;
  }
}
