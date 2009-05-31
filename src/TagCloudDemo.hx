import org.fabricio.tags.Tag;
import org.fabricio.tags.TagCloud;
import org.fabricio.tags.TagList;
import flash.events.Event;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display.MovieClip;

class SvgTest extends MovieClip{}
// = TagCloudDemo =
// A demo application using the features of the TagCloud-hx library
class TagCloudDemo extends Sprite{

  // == Main ==
  // Uses 2 different sources to build 2 different clouds, one is a local
  // JSON file and the other is a remote JSON file from del.icio.us
  static function main(){
    var localFile:String  = "fake_delicious_tags.json";
    var remoteFile:String = "http://feeds.delicious.com/v2/json/tags/jampa?count=80";
    var listA:TagList     = new TagList();
    var listB:TagList     = new TagList();
    var shape:Sprite;
    // set alignment and scaling of the movie
    _stage.scaleMode = StageScaleMode.NO_SCALE;
    _stage.align = StageAlign.TOP_LEFT;

    shape = _library.attach('antiRhino');
    _root.addChild(shape);
    shape.scaleX = shape.scaleY = 1.5;

    // callbacks
    var onLocalFileLoaded = function (evt:Event):Void{
      trace('Local Data Sucessfully Loaded');
    }
    var onDeliciousFeedLoaded = function (evt:Event):Void{
      trace('Remote Data Sucessfully Loaded');
      var tagcloud = new TagCloud(listB);
      tagcloud.x = 400;
      tagcloud.y = 320;
      tagcloud.shape = shape;
      tagcloud.create();
      _root.addChild(tagcloud);
    }
    listA.addEventListener(Event.COMPLETE, onLocalFileLoaded);
    listB.addEventListener(Event.COMPLETE, onDeliciousFeedLoaded);
    
/*    trace('Load data from a local file');
    listA.dataURL = localFile;
    listA.loadDataURL();
    trace('loading '+listA.dataURL+'…');
*/    
    trace('Load data from the Internet');
    listB.loadDataURL(remoteFile);
    trace('loading '+listB.dataURL+'…');
    
  }
  
  // == Constants & Private Vars ==
  inline static var _library          = flash.Lib;
  inline static var _root:MovieClip   = flash.Lib.current;
  inline static var _stage:Stage      = flash.Lib.current.stage;

} // end of the class