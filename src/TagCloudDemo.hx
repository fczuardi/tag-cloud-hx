import org.fabricio.tags.TagList;
import flash.events.Event;

// = TagCloudDemo =
// A demo application using the features of the TagCloud-hx library
class TagCloudDemo{
  
  static function main(){
    var listA:TagList = new TagList();
    var listB:TagList = new TagList();
    var onLocalFileLoaded = function (evt:Event):Void{
      trace('Local Data Sucessfully Loaded');
      trace('listA.length = '+listA.length);
      for (i in listA){
//        trace(i.name+' '+i.value);
      }
    }    
    trace('Load data from a local file');
    listA.addEventListener(Event.COMPLETE, onLocalFileLoaded);
    listA.dataURL = "fake_delicious_tags.json";
    listA.loadDataURL();
    trace('loading '+listA.dataURL+'…');

    var onDeliciousFeedLoaded = function (evt:Event):Void{
      trace('Remote Data Sucessfully Loaded');
      trace('listB.length = '+listB.length);
    }    
    trace('Load data from the Internet');
    listB.addEventListener(Event.COMPLETE, onDeliciousFeedLoaded);
    listB.loadDataURL("http://feeds.delicious.com/v2/json/tags/fabricio?count=50");
    trace('loading '+listB.dataURL+'…');
    
  }
}