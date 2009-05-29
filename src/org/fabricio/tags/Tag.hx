package org.fabricio.tags;

import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.display.MovieClip;

// ==== package org.fabricio.tags ====

// = Tag =
// A visual tag. An object representing an individual keyword.
class Tag extends MovieClip{
  
  // == Constants ==
  // The default values for various settings
  private static inline var DEFAULT_TEXT:String     = '';
  private static inline var DEFAULT_SIZE:Int        = 18;
  private static inline var DEFAULT_COLOR:Int       = 0x333333;
  private static inline var DEFAULT_FONT:String     = "DejaVuSansCondensedBold";
  private static inline var DEFAULT_EMBED_FONT:Bool = false;
  
  // == Properties ==
  
  // === text:String ===
  // The label of the tag.
  public var text(getLabel, setLabel):String;
  private function getLabel():String{
    return _label.text;
  }
  private function setLabel(text:String){
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
  // * **{{{text}}}**  – the tag label to be displayed.
  // * **{{{size}}}**  – the font size.
  // * **{{{color}}}** – the hexadecimal color — ex: {{{0x00FF00}}}.
  // * **{{{font}}}**  – the name of the font to use.
  public function new(?text:String, ?size:Float, ?color:Int, ?font:String){
    super();
    _label            = new TextField();
    _format           = new TextFormat();
    _label.autoSize   = TextFieldAutoSize.LEFT;
    _label.embedFonts = DEFAULT_EMBED_FONT;
    
    _label.text       = (text == null)  ? DEFAULT_TEXT  : text;
    _format.size      = (size == null)  ? DEFAULT_SIZE  : size;
    _format.color     = (color == null) ? DEFAULT_COLOR : color;
    this.font      = (font == null)  ? DEFAULT_FONT  : font;
    _label.setTextFormat(_format);
    this.addChild(_label);
  }
  
  // == Private Vars ==
  private var _label:TextField;
  private var _format:TextFormat;
}