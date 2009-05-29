#
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

package org.fabricio.tags;

import flash.display.Sprite;

// ==== package org.fabricio.tags ====

// = TagCloud =
// A visualization of a tags set as a cloud.
class TagCloud extends Sprite{
  
  // == Constants ==
  // The default values for various settings
  private static inline var DEFAULT_CAPITALIZATION:Capitalization = preserve;

  // == Properties ==
  
  // === capitalization:Capitalization ===
  // The text transformation to be applied on the tags of the cloud.
  //
  // Options are:
  // * {{{preserve}}}
  // * {{{lower}}}
  // * {{{upper}}}
  // * {{{capitalized}}}
   
  public var capitalization(getCaps, setCaps):Capitalization;
  private function getCaps():Capitalization{
    return _config.capitalization;
  }
  private function setCaps(cap:Capitalization){
    _config.capitalization = cap;
    for (i in _tags){
      i.label = applyCapitalization(i.tagName);
    }
    return _config.capitalization;
  }
  private function applyCapitalization(s:String):String{
    switch (_config.capitalization){
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
  
  // == Constructor ==
  // Acceps the following optional parameters:
  // * **{{{list}}}** a [[#src/org/fabricio/tags/TagList.hx | Taglist]] object.
  public function new(?list:TagList){
    super();
    _tags = [];
    _config = {
      capitalization : DEFAULT_CAPITALIZATION
    }
    _tagList = (list == null) ? new TagList() : list;
    if (list != null) {
      create();
    }
  }

  // == Private Helpers ==
  
  // generate all the tag objects of the cloud
  private function create():Void{
    var x:Float = 0;
    var y:Float = 0;
    for (i in _tagList){
      if(i.value>3){
        var tag = new Tag({
          text  : applyCapitalization(i.name), 
          size  : i.value *1.2+4, 
          color : 0x003333, 
          font  : "DejaVuSansCondensedBold",
          name  : i.name
        });
        tag.alpha = 0.8;
        tag.x = x;
        tag.y = y - (tag.height)/2;
        _tags.push(tag);
        addChild(tag);
        x += tag.width;
        if(x>350){
          x = Math.random()*20;
          y += 30;
        }
      }

    }
  }
  
  // == Private Vars
  private var _tagList:TagList;
  private var _tags:Array<Tag>;
  private var _config:TagCloudConfig;
  
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

// === TagCloudConfig ===
// An Object containing cloud-specific configuration.
typedef TagCloudConfig = {
  var capitalization:Capitalization;
}
