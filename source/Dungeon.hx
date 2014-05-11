package;

import flixel.group.FlxGroup;

import flixel.util.FlxRandom;
import flixel.util.FlxStringUtil;

import flixel.tile.FlxTilemap;

class Dungeon extends FlxGroup
{
  inline public static var SIZE = 40;

  //We have to add this one separately to layer it on top
  public var wallTopTilemap:FlxTilemap;
  public var wallTilemap:FlxTilemap;
  public var collisionTilemap:FlxTilemap;

  var dungeonTiles:DungeonTiles;
  var isometricWalls:IsometricWalls;
  var isometricTops:IsometricTops;

  var groundTilemap:FlxTilemap;

  public function new() {
    super();
    dungeonTiles = new DungeonTiles(SIZE,SIZE);

    groundTilemap = new FlxTilemap();
    groundTilemap.loadMap(FlxStringUtil.arrayToCSV(flattenArray(dungeonTiles.tiles), SIZE),
                          "assets/images/areas/" + G.world + "/tiles.png", 32, 32, FlxTilemapAutoTiling.OFF);
    groundTilemap.x = (-SIZE/2) * 32;
    groundTilemap.y = (-SIZE/2) * 32;
    add(groundTilemap);

    //Invert the tiles for collision
    collisionTilemap = new FlxTilemap();
    var collisionArray:Array<Int> = flattenArray(dungeonTiles.tiles);
    for (i in 0...collisionArray.length-1) {
      if(collisionArray[i] > 0) {
        collisionArray[i] = 0;
      } else {
        collisionArray[i] = 1;
      }
    }
    collisionTilemap.loadMap(FlxStringUtil.arrayToCSV(collisionArray, SIZE),
                          "assets/images/areas/" + G.world + "/tiles.png", 32, 32, FlxTilemapAutoTiling.OFF);
    collisionTilemap.x = groundTilemap.x;
    collisionTilemap.y = groundTilemap.y;

    isometricWalls = new IsometricWalls(dungeonTiles);
    wallTilemap = new FlxTilemap();
    wallTilemap.loadMap(FlxStringUtil.arrayToCSV(flattenArray(isometricWalls.tiles), SIZE),
                          "assets/images/areas/" + G.world + "/tiles.png", 32, 32, FlxTilemapAutoTiling.OFF);
    wallTilemap.x = groundTilemap.x;
    wallTilemap.y = groundTilemap.y;
    add(wallTilemap);

    isometricTops = new IsometricTops(isometricWalls);
    wallTopTilemap = new FlxTilemap();
    wallTopTilemap.loadMap(FlxStringUtil.arrayToCSV(flattenArray(isometricTops.tiles), SIZE),
                          "assets/images/areas/" + G.world + "/tiles.png", 32, 32, FlxTilemapAutoTiling.OFF);
    wallTopTilemap.x = groundTilemap.x;
    wallTopTilemap.y = groundTilemap.y;
    
    collisionTilemap.visible = false;
    add(collisionTilemap);
  }

  private function flattenArray(array:Array<Array<Int>>):Array<Int> {
    var flattenedArray = new Array<Int>(); 
    for (tileArray in array) {
      for (tile in tileArray) {
        flattenedArray.push(tile);
      }
    }

    return flattenedArray;
  }
}
