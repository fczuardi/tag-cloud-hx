package org.fabricio.tags;

import flash.display.MovieClip;
import flash.geom.Point;

// ==== package org.fabricio.tags ====

class InsideBoundaryBehavior {
  private var _next:Int;
  private var _discardedTags:Array<String>;
  public var finished:Bool;
  public function init(tags:Array<Tag>){
    _tags = tags;
    _next = 0;
    for (i in _tags){
      i.visible = false;
    }
    _lastX = 0;
    _lastY = 0;
    _discardedTags = [];
    _tags[0].parent.x = _shape.x;
    _tags[0].parent.y = _shape.y;
  }
  public function step(){
    if (_next >= _tags.length) return;
    var position:Point;
    position = findAvailableSpot(_tags[_next]);
    if (position != null){
      _tags[_next].x = position.x;
      _tags[_next].y = position.y;
    } else {
      _discardedTags.push(_tags[_next].tagName);
    }
    _next++;
    if (_next >= _tags.length) {
      finished = true;
    }
  }
  private function findAvailableSpot(tag):Point{
    var overTag:Bool;
    var overShape:Bool;
    var x:Float = _lastX;
    var y:Float = _lastY;
    var firstScan:Bool = true;
    while(true){
      overTag = false;
      overShape = (tagOverShapePercentage(tag, x, y, _shape) > 0.2);
      if (!overShape){
        for (i in _tags){
          if (overTag = (tagOverTagPercentage(tag, x, y, i) > 0.01)) break;
        }
      }
      if (overShape || overTag){
        x += 5;
        if (x + tag.width > _shape.width){
          x = 0;
          y += 5;
        }
        if (y + tag.height >= _shape.height) {
          if(firstScan){
            x = 0;
            y = 0;
            firstScan = false;
          } else {
            return null;
          }
        }
      } else {
        tag.visible = true;
        _lastX = x;
        _lastY = y;
        return new Point(x,y);
      }
    }
    return null;
  }
  private var _lastX:Float;
  private var _lastY:Float;
  private function tagOverTagPercentage(tagA:Tag, x:Float, y:Float, tagB:Dynamic):Float{
    if ((tagA == tagB) ||
        (tagB.visible == false) ||
        (x > tagB.x+tagB.width) ||
        (x+tagA.width < tagB.x) ||
        (y > tagB.y+tagB.height) ||
        (y+tagA.height < tagB.y) ||
        (tagB.textHeight == Math.NaN)
                ) return 0;
    // divide the tag in a 5x3 grid and test all the 15 points against the shape
    var columns = 7;
    var rows = 5;
    var topMarginA = (tagA.height - tagA.textHeight)/2;
    var topMarginB = (tagB.height - tagB.textHeight)/2;
    var pointsOverShape = 0;
    for (c in 1...(columns-1)){
      for(r in 1...(rows-1)){
        var tx = x + (c / (columns)) * tagA.width;
        var ty = y + topMarginA + (r / (rows)) * tagA.textHeight;
        if ((tx > tagB.x) && (tx < tagB.x + tagB.width) && (ty > tagB.y) && (ty < tagB.y + tagB.height-5)) {
          pointsOverShape++;
        }
      }
    }
    return pointsOverShape/((columns-2)*(rows-2));
  }

  private function tagOverShapePercentage(t:Tag, x:Float, y:Float, shape:Dynamic):Float{
    // divide the tag in a 5x3 grid and test all the 15 points against the shape
    var columns = 7;
    var rows = 5;
    var topMargin = (t.height - t.textHeight)/2;
    var localpoint:Point = new Point(x, y+topMargin);
    var globalpoint:Point = t.parent.localToGlobal(localpoint);
    var pointsOverShape = 0;
    for (c in 1...(columns-1)){
      for(r in 1...(rows-1)){
        if ( _shape.hitTestPoint(
                            globalpoint.x + (c / (columns)) * t.width,
                            globalpoint.y + (r / (rows)) * t.textHeight,
                            true) ||  (globalpoint.x > shape.x + shape.width)) {
          pointsOverShape++;
        }
      }
    }
    return pointsOverShape/((columns-2)*(rows-2));
  }
  
  public function new(shape){
    _shape = shape;
    finished = false;
  }


  private var _shape:MovieClip;
  private var _tags:Array<Tag>;
}