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

import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.display.Sprite;

// ==== package org.fabricio.tags ====

// = Tag =
// A visual tag. An object representing an individual keyword.
class Tag extends Sprite{
  
  // == Constants ==
  // The default values for various settings
  private static inline var DEFAULT_TEXT:String     = '';
  private static inline var DEFAULT_SIZE:Int        = 18;
  private static inline var DEFAULT_COLOR:Int       = 0x333333;
  private static inline var DEFAULT_FONT:String     = "_sans";
  private static inline var DEFAULT_EMBED_FONT:Bool = false;
  
  // == Properties ==
  
  // === tagName:String ===
  // The identifier of the tag.
  public var tagName:String;

  // === label:String ===
  // The displayed text of the tag.
  public var label(getLabel, setLabel):String;
  private function getLabel():String{
    return _label.text;
  }
  private function setLabel(text:String){
    //if the tag does not have an identifier yet, setup it up
    if (tagName == null) {
      tagName = text;
    }
    //update the label
    _label.text = text;
    _label.setTextFormat(_format);
    return _label.text;
  }
  
  // === font:String ===
  // The font to be used on the tag. If you have the font glyphs as part
  // of your movie library it will use that embbeded version instead of 
  // the viewer's one. Embedded fonts are required if you want to use 
  // transparency.
  public var font(getFont,setFont):String;
  private function getFont():String{
    return _format.font;
  }
  private function setFont(font:String){
    var embeddedFonts:Array<Dynamic> = Font.enumerateFonts(false);
    var libraryHasFont = false;
    for (i in embeddedFonts){
      if (i.fontName == font){
        libraryHasFont = true;
        break;
      }
    }
    // if the desired font is in the library turn on embedded
    _label.embedFonts = libraryHasFont;
    _format.font = font;
    _label.setTextFormat(_format);
    return _format.font;
  }
  
  // === fontSize:Int ===
  // The font-size to be used in the tag.
  public var fontSize(getFontSize,setFontSize):Int;
  private function getFontSize():Int{
    return _format.size;
  }
  private function setFontSize(s:Int){
    trace(s);
    _format.size = s;
    _label.setTextFormat(_format);
    return _format.size;
  }
  
  // === fontColor:Int ===
  // The font-color to be used in the tag. Hexadecimal number — ex: {{{0x00FF00}}}.
  public var fontColor(getFontSize,setFontSize):Int;
  private function getFontColor():Int{
    return _format.color;
  }
  private function setFontColor(color:Int){
    _format.color = color;
    _label.setTextFormat(_format);
    return _format.color;
  }
  
  // == Constructor ==
  // Accepts the following optional parameters:
  // * **{{{text_or_config}}}**  – the tag label to be displayed. 
  // Or a config object containing all parameters: text, size, color, font, name.
  // * **{{{size}}}**  – the font size.
  // * **{{{color}}}** – the hexadecimal color — ex: {{{0x00FF00}}}.
  // * **{{{font}}}**  – the name of the font to use.
  // * **{{{name}}}**  – the tagName to be used as an identifier.
  //
  // Usage Examples:
  // {{{
  //   var tagA = new Tag({
  //     text  : "HAXE", 
  //     size  : 30, 
  //     color : 0x003333, 
  //     font  : "DejaVuSansCondensedBold",
  //     name  : "haXe"
  //   });
  //   
  //   var tagB = new Tag('Rules', 30);
  // }}}
  public function new(?text_or_config:Dynamic, ?size:Float, 
                               ?color:Int, ?font:String, ?name:String){
    super();
    _label            = new TextField();
    _format           = new TextFormat();
    _label.autoSize   = TextFieldAutoSize.LEFT;
    _label.embedFonts = DEFAULT_EMBED_FONT;
    var text:String   = null;
    if (Reflect.isObject(text_or_config)){
      text  = Reflect.field(text_or_config, 'text');
      size  = Reflect.field(text_or_config, 'size');
      color = Reflect.field(text_or_config, 'color');
      font  = Reflect.field(text_or_config, 'font');
      name  = Reflect.field(text_or_config, 'name');
    } else {
      text = text_or_config;
    }
    tagName           = name;
    _format.size      = (size == null)  ? DEFAULT_SIZE  : size;
    _format.color     = (color == null) ? DEFAULT_COLOR : color;
    this.font         = (font == null)  ? DEFAULT_FONT  : font;
    this.label        = (text == null)  ? DEFAULT_TEXT  : text;
    this.addChild(_label);
  }
  
  // == Private Vars ==
  private var _label:TextField;
  private var _format:TextFormat;
}