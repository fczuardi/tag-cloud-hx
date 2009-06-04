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

// ==== package org.fabricio.tags ====

// = TextBlockBehavior =
// Tag Cloud behavior to position the tags sequentially on an area with 
// fixed width. It will place the tags one after the other left to right,
// top to bottom.
//
// Apply this behavior to get “words on a paragraph” look on your tag cloud.
//
// The height of each line will be the height of the tallest tag on that line.
class TextBlockBehavior {
  
  // == Defaults ==
  // The default value for the available settings.
  private static inline var DEFAULT_WIDTH:Float = 400;
  private static inline var DEFAULT_HORIZONTAL_ALIGN:TextAlignment = left;
  
  // == Methods ==
  
  // === init(tags:Array<Tag>) ==
  // Distribute all **{{{tags}}}** as a text block, respecting the 
  // width and following the text-alignment specified on the constructor.
  public function init(tags:Array<Tag>){
    var x:Int                           = 0;
    var y:Int                           = 0;
    var lineHeights:Array<Float>        = [];
    var lineWidthRemainers:Array<Float> = [];
    var lineEnders:Array<Int>           = [];
    var lineHeight:Float                = 0;
    
    // distribute horizontally
    lineEnders.push(-1);
    for (i in 0...tags.length){
      if (x + tags[i].width > _width) {
        lineEnders.push(i-1);
        lineHeights.push(lineHeight);
        lineWidthRemainers.push(_width - x);
        lineHeight = 0;
        x = 0;
      }
      tags[i].x = x;
      x += Math.ceil(tags[i].width);
      lineHeight = Math.max(tags[i].height,lineHeight);
    }
    lineWidthRemainers.push(_width - x);
    
    // distribute vertically and align
    var h:Float = 0;
    var lineStarter:Int;
    var lineEnder:Int;
    for (line in 0...lineEnders.length){
      lineStarter = lineEnders[line]+1;
      lineEnder = (lineEnders[line+1] > 0) ?  (lineEnders[line+1]+1) : 
                                              (tags.length);
    for (i in lineStarter...lineEnder){
        tags[i].y = Math.round(h - tags[i].height/2);
        switch(_horizontalAlign){
          case right:
            tags[i].x += Math.floor(lineWidthRemainers[line]);
          case center:
            tags[i].x += Math.round(lineWidthRemainers[line]/2);
          case justify:
            if (i > lineStarter){
              tags[i].x += Math.round( (i-lineStarter) *
                    lineWidthRemainers[line]/(lineEnder-lineStarter-1) );
            }
          case left:
            continue;
        }
      }
      h += (!Math.isNaN(lineHeights[line+1])) ? 
                        (lineHeights[line]/2 + lineHeights[line+1]/2) :
                        (lineHeights[line]);
    }
  }
  
  // === step() ===
  // This behavior does not have a step, the placement of the tags is done
  // only once at the beginning.
  public function step(){ return; }

  // == Constructor ==
  // Acceps the following optional parameters:
  // * **{{{width}}}**: The maximum width to use for the lines of the tagcloud.
  // * **{{{horizontalAlign}}}**: The horizontal text alignment to use.
  public function new(?width:Float, ?horizontalAlign:TextAlignment){
    _width            = (width == null) ? DEFAULT_WIDTH : width;
    _horizontalAlign  = (horizontalAlign == null) ? 
                                              DEFAULT_HORIZONTAL_ALIGN :
                                              horizontalAlign;
  }
  
  // == Private Vars ==
  private var _width:Float;
  private var _horizontalAlign:TextAlignment;
  
}// end of the class

// == Custom data types ==

// === TextAlignment ===
// The available text-alignment options for a tag cloud using this behavior.
enum TextAlignment{
  left;
  right;
  center;
  justify;
}