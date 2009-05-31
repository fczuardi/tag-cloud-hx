/*
# TagCould-hx
#
# A library for creating tag-clouds in haXe.
#
# http://github.com/fczuardi/tag-cloud-hx
# 
# Copyright (c) 2009 The TagCloud-hx Authors.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions 
# are met:
# 
#   * Redistributions of source code must retain the above copyright 
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in 
#     the documentation and/or other materials provided with the 
#     distribution.
#   * Neither the name of the HSBC Brasil S.A., HSBC México S.A.,
#     JWT Brasil S.A. nor the names of its contributors may be used to 
#     endorse or promote products derived from this software without 
#     specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package org.fabricio.tags;

import flash.display.Sprite;
import flash.geom.Point;


// ==== package org.fabricio.tags ====

// = TagCloud =
// A visualization of a tags set as a cloud.
class TagCloud extends Sprite{
  
  // == Defaults ==
  // The default values for various settings
  static inline var DEFAULT_CAPITALIZATION:Capitalization = upper;
  static inline var DEFAULT_SIZE_FN:Float->Float    = function(v:Float):Float{ return  15 + v * .02;}
  static inline var DEFAULT_COLOR_FN:Float->Int     = function(v:Float):Int{ return 0x555555;}
  static inline var DEFAULT_OPACITY_FN:Float->Float = function(v:Float):Float{ return .2+v/180;}
  static inline var DEFAULT_FONT_FN:Float->String   = function(v:Float):String{ return "DejaVuSansCondensedBold";}

  // == Properties ==
  
  // === capitalization:Capitalization ===
  // The text transformation to be applied on the tags of the cloud.
  //
  // Options are:
  // * {{{preserve}}} — Don’t modify the text.
  // * {{{lower}}} — Convert to lowercase.
  // * {{{upper}}} — Convert to uppercase.
  // * {{{capitalized}}} — Only the first letter of each word capitalized.
   
  public var capitalization(getCaps, setCaps):Capitalization;
  private function getCaps():Capitalization{
    return _capitalization;
  }
  private function setCaps(cap:Capitalization){
    _capitalization = cap;
    for (i in _tags){
      i.label = applyCapitalization(i.tagName);
    }
    return _capitalization;
  }
  private function applyCapitalization(s:String):String{
    switch (_capitalization){
      case preserve:
        return s;
      case lower:
        return s.toLowerCase();
      case upper:
        return s.toUpperCase();
      case capitalized:
        return Lambda.list(s.split(' ')).map(capitalize).join(' ');
    }
  }
  private function capitalize(s:String):String { 
    return  s.charAt(0).toUpperCase() + s.toLowerCase().substr(1,s.length);
  }
  
  // === sizeFn ===
  // A function to modify the size of each tag according to it’s value.
  public var sizeFn:Float -> Float;

  // === colorFn ===
  // A function to modify the color of each tag according to it’s value.
  public var colorFn:Float -> Int;
  
  // === opacityFn ===
  // A function to modify the opacity of each tag according to it’s value.
  public var opacityFn:Float -> Float;
  
  // === fontFn ===
  // A function to modify the font of each tag according to it’s value.
  public var fontFn:Float -> String;
  
  // == Methods ==
  
  // === create() ===
  // Generates all the tag objects of the cloud.
  public function create():Void{
    var x:Float = 0;
    var y:Float = 0;

    for (i in _tagList){
      var tag = new Tag({
        text  : applyCapitalization(i.name), 
        size  : sizeFn(i.value), 
        color : colorFn(i.value), 
        font  : fontFn(i.value),
        name  : i.name
      });
      tag.alpha = opacityFn(i.value);
      tag.y = Math.random()*10;
      tag.x = Math.random()*10;
      _tags.push(tag);
/*      tag.x = tag.y = 0;
*/    }
    t = 0;
    tagCount = 0;
    // for every frame, call the loop method
   this.addEventListener(flash.events.Event.ENTER_FRAME,loop);    
  }
  
  
  /*
  
0 - create a helper to check the an aproximated percentage of the tag that is overlaping a given shape
1- sort the tags by size, ascending
2- get the shorter tag and go from the top-left corner to the right until more than x % is over the shape
3- stop and check if the bigger one can have the same percentage
   - repeat until find one that fits, going from the bigger 

  */
  private var t:Int;
  private var tagCount:Int;
  public var shape:Sprite;
  private function loop(e:Dynamic){
    if ((tagCount < _tags.length) && (t++ % 2 == 0) ){
      _tags[tagCount].x = -100 + Math.random()*300;
      _tags[tagCount].y = -20 +Math.random()*40;
      addChild(_tags[tagCount++]);
    }
    for (i in _tags){
      for(j in _tags){
        if(i != j){
          var dx:Float = (j.x+j.width/2) - (i.x+i.width/2);
          var dy:Float = (j.y+j.height/2) - (i.y+i.height/2);
          var d:Float = Math.sqrt(dx*dx +dy*dy);
          var magnetRange = 30+j.height*.5;
          var magnetPower = j.width;
          magnetPower = 10;
          if (d < magnetRange){
            var angle = Math.atan2(dy, dx);
            var inc = magnetPower * (1 - d/magnetRange);
            var incX = inc * Math.cos(angle);
            var incY = inc * Math.sin(angle);
            var localpoint:Point = new Point(i.x-incX, i.y-incY);
            var globalpoint:Point = this.localToGlobal(localpoint);
            var cornersOverShape = 0;
            for (c in 0...5){
              for(l in 0...3){
                if (shape.hitTestPoint(globalpoint.x+(c*1/4)*i.width, globalpoint.y+(l*1/2)*i.height, true)) cornersOverShape++;
              }
            }
            if (cornersOverShape < 7){
              i.x -= incX;
              i.y -= incY;
            }else if (cornersOverShape < 9){
              i.x += incY/3;
              i.y += incX/3;
            }else{
              i.x = -100 + Math.random()*300;
              i.y = -20 +Math.random()*40;
            }
          }
        }
      }
    }
  }
  
  // == Constructor ==
  // Acceps the following optional parameters:
  // * **{{{list}}}** a [[#src/org/fabricio/tags/TagList.hx | Taglist]] object.
  public function new(?list:TagList){
    super();
    _tags = [];
    _tagList = (list == null) ? new TagList() : list;
    
    this.capitalization = DEFAULT_CAPITALIZATION;
    this.sizeFn         = DEFAULT_SIZE_FN;
    this.colorFn        = DEFAULT_COLOR_FN;
    this.opacityFn      = DEFAULT_OPACITY_FN;
    this.fontFn         = DEFAULT_FONT_FN;
  }

  // == Private Vars
  private var _tagList:TagList;
  private var _tags:Array<Tag>;
  private var _capitalization:Capitalization;
  
} // end of the class

// == Custom data types ==

// === Capitalization ===
// The available choices for text capitalization.
enum Capitalization{
  preserve;
  lower;
  upper;
  capitalized;
}
