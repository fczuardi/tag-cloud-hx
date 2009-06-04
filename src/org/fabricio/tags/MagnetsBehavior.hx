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

import flash.geom.Point;
import flash.text.TextField;

// = MagnetsBehavior =
// Tag Cloud Behavior to make each tag behave like a magnet applying a 
// force that influences the other tags near them, normally a repulsion force.
class MagnetsBehavior implements ITagCloudBehavior{
  
  // == Defaults ==
  static inline var DEFAULT_INFLUENCE_FN:Tag->Float->Float = 
  function(t:Tag, d:Float){
    var range = 5 + t.height * .8;
    var power = 5 + t.height * .5;
    if (d < range){
      return power * (1-d/range);
    }else{
      return 0;
    }
  }
  
  // == Properties ==

  // === influenceFn ===
  // The function that sets the influence — in pixels — of a tag 
  // over other object according to the tag attributes and the distance
  // between them.
  public var influenceFn:Tag -> Float -> Float;

  // == Methods ==
  
  // === init(t:Array<Tag>) ===
  // Populate the tag container.
  public function init(t:Array<Tag>){
    _tags = t;
  }
  
  // === step() ===
  // Calculate the influence of all visible tags on each other and then
  // update the position of each one accordingly.
  public function step(){
    var dx:Float;         // distance between 2 tags on the X axis
    var dy:Float;         // distance between 2 tags on the Y axis
    var d:Float;          // distance between 2 tags
    var angle:Float;      // the angle between 2 tags
    var incX:Float;       // the total increment on the X axis
    var incY:Float;       // the total increment on the Y axis
    var inc:Float;        // the size of the increment
    
    for (i in 0..._tags.length){
      // visible tags only
      if (!_tags[i].visible) continue;
      incX = incY = 0;
      for (j in 0..._tags.length){
        // no influence from invisible tags
        if (!_tags[j].visible) continue;
        // a tag does not influence itself
        if (i == j) continue;
        
        dx = (_tags[j].x + _tags[j].width/2 ) - (_tags[i].x + _tags[i].width/2 );
        dy = (_tags[j].y + _tags[j].height/2) - (_tags[i].y + _tags[i].height/2);
        d = Math.sqrt(dx*dx +dy*dy);
        angle = Math.atan2(dy, dx);
        inc = influenceFn(_tags[j], d);
        incX += inc * Math.cos(angle);
        incY += inc * Math.sin(angle);
      }
      _tags[i].x -= (incX);
      _tags[i].y -= (incY);
    }
  }
  
  // == Constructor ==
  public function new(?influence:Tag->Float->Float){
    influenceFn = (influence == null) ? DEFAULT_INFLUENCE_FN : influence;
  }
  
  // == Private Vars ==
  private var _tags:Array<Tag>;
  
} // end of the class
