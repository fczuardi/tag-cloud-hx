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
import flash.events.Event;

// ==== package org.fabricio.tags ====

// = TagCloud =
// A visualization of a tags set as a cloud.
class TagCloud extends Sprite{
  
  // == Defaults ==
  // The default values for various settings
  static inline var DEFAULT_CAPITALIZATION:Capitalization = upper;
  static inline var DEFAULT_SIZE_FN:Float->Float->Float    = function(v:Float, r:Float):Float{ return 8 + 20 * r;}
  static inline var DEFAULT_COLOR_FN:Float->Float->Int     = function(v:Float, r:Float):Int{ return 0x000000;}
  static inline var DEFAULT_OPACITY_FN:Float->Float->Float = function(v:Float, r:Float):Float{ return .5 + .3 * r;}
  static inline var DEFAULT_FONT_FN:Float->Float->String   = function(v:Float, r:Float):String{ return "DejaVuSansCondensedBold";}

  // == Properties ==
  
  public var list(getList, setList):TagList;
  private function getList():TagList{
    return _tagList;
  }
  private function setList(l:TagList):TagList{
    _tagList = l;
    return _tagList;
  }
  
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
  // The relative value of the tag is also passed as a second parameter.
  // The relative value is a 0–1 float indicating the relative score of 
  // that tag comparing to the other on the same cloud — 0 being the 
  // lowest valued tag and 1 the highets.
  public var sizeFn:Float -> Float -> Float;

  // === colorFn ===
  // A function to modify the color of each tag according to it’s value.
  // The relative value of the tag is also passed as a second parameter.
  public var colorFn:Float -> Float -> Int;
  
  // === opacityFn ===
  // A function to modify the opacity of each tag according to it’s value.
  // The relative value of the tag is also passed as a second parameter.
  public var opacityFn:Float -> Float -> Float;
  
  // === fontFn ===
  // A function to modify the font of each tag according to it’s value.
  // The relative value of the tag is also passed as a second parameter.
  public var fontFn:Float -> Float -> String;
  
  // === attachBehavior(behavior:Dynamic) ===
  // Apply a behavior to the tag cloud. Multiple behaviors can be attached.
  // A behavior must be a class that implements the ITagCloudBehavior interface.
  public function attachBehavior(behavior:Dynamic){
    var behaviorName = Type.getClassName(Type.getClass(behavior));
    if ((_behaviorNames.length > 0) && (Lambda.has(_behaviorNames, behaviorName))){
      throw "Error: only one behavior of each type allowed."; return;
    }
    _behaviors.push(behavior);
  }

  // === create() ===
  // Generates all the tag objects of the cloud.
  public function create():Void{
    for (i in _tagList){
      var relativeValue = 1 - (_tagList.higherValue - i.value) / (_tagList.higherValue - _tagList.lowerValue);
      var tag = new Tag({
        text  : applyCapitalization(i.name), 
        size  : sizeFn(i.value,relativeValue), 
        color : colorFn(i.value,relativeValue), 
        font  : fontFn(i.value,relativeValue),
        name  : i.name
      });
      tag.alpha = opacityFn(i.value,relativeValue);
      _tags.push(tag);
      addChild(tag);
    }
    for (i in _behaviors){
      i.init(_tags);
    }
    addEventListener(flash.events.Event.ENTER_FRAME, step);
  }
  
  // == Constructor ==
  // Acceps the following optional parameters:
  // * **{{{list}}}** a [[#src/org/fabricio/tags/TagList.hx | Taglist]] object.
  public function new(?list:TagList){
    super();
    _tags = [];
    _behaviors = [];
    _behaviorNames = [];
    _tagList = (list == null) ? new TagList() : list;
    
    this.capitalization = DEFAULT_CAPITALIZATION;
    this.sizeFn         = DEFAULT_SIZE_FN;
    this.colorFn        = DEFAULT_COLOR_FN;
    this.opacityFn      = DEFAULT_OPACITY_FN;
    this.fontFn         = DEFAULT_FONT_FN;
  }

  // == Private Helpers

  private function step(e:Event){
    var allFinished = true;
    for (i in _behaviors){
      i.step();
      if(i.finished != true) allFinished = false;
    }
    if (allFinished) {
//      trace('finished.');
      removeEventListener(flash.events.Event.ENTER_FRAME, step);
    }
  }
  
  private function calculateFps(lastTime:Int):Float{
    var now:Int     = flash.Lib.getTimer();
    var deltaT:Int  = now-lastTime;
    var fps:Float   = 1/(deltaT/1000);
    lastTime = now;
    return fps;
  }

  // == Private Vars
  private var _tagList:TagList;
  private var _tags:Array<Tag>;
  private var _capitalization:Capitalization;
  private var _behaviors:Array<Dynamic>;
  private var _behaviorNames:Array<String>;
  private var lastTime:Int;
  
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
