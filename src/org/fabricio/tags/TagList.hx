package org.fabricio.tags;

import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.Error;
import hxjson2.JSONDecoder;
// ==== package org.fabricio.tags ====

// = TagList =
// Class that represents a list of tags and the number of times they have been used.
class TagList implements IEventDispatcher{
  
  // == Properties ==
  
  // === length:Int ===
  // The size of the list. The number of different tags in the list — read-only.
  public var length(getListLength, null):Int;
  private function getListLength():Int{
    return _tagList.length;
  }

  // === dataURL ===
  // The URL of the data source that was used or that will be used to populate the tag list.
  public var dataURL:String;
    

  // == Methods ==
  
  // === iterator() ===
  // TagList objects are iterable, you can run through all tags from the
  // list using a “for i in” loop, for example:
  //
  // {{{ for (i in your_taglist) { trace(i.name+' '+i.value); } }}}
  public function iterator():Iterator<Dynamic>{
    return _tagList.iterator();
  }
  
  // === loadDataURL(?url:String):Bool ===
  // Reset the tag list if not empty, and load the JSON formatted list 
  // data from **{{{url}}}**, returns {{{false}}} if the URL is invalid.
  //
  // Example of valid JSON formatted tag-list URL:\\
  // [[http://feeds.delicious.com/v2/json/tags/fabricio?count=50]]
  public function loadDataURL(?url:String):Bool{
    dataURL = url = (url == null) ? dataURL : url;
    var listeners:Array<EventBind> = [
      {event:Event.COMPLETE, listener: JSONLoadComplete}
    ];
    return requestURL(url, listeners);
  }
  
  // onComplete callback for loadDataURL
  private function JSONLoadComplete(evt:Event):Void{
    var json_ob = new JSONDecoder(_loader.data, true).getValue();
    _tagList = [];
    _tagHashTable = json_ob;
    for(i in Reflect.fields(json_ob)){
      _tagList.push({name:i,value:Reflect.field(json_ob,i)});
    }
    dispatchEvent(evt);
  }

  // == Private Helpers ==
  
  // === requestURL(url:String, listeners:Array<EventBind>):Bool ===
  // Makes a request to **{{{url}}}** and add **{{{listeners}}}** to it.\\
  // Returns {{{false}}} if the URL is invalid.
  private function requestURL(url:String, 
                              listeners:Array<EventBind>):Bool{
    //try to terminate the loading just in case
    try{
      _loader.close();
    } catch (e:Error){
      // do nothing this is expected
    }
    _request.url = url;
    for(i in 0...listeners.length){
      _loader.addEventListener(listeners[i].event,listeners[i].listener);
    }
    try {
      _loader.load(_request);
      return true;
    } catch (error:Error) {
      return false;
    }
  }
  
  // == IEventDispatcher Implementation ==
  private var _dispatcher:EventDispatcher;
  public function dispatchEvent(e:Event):Bool{
    return _dispatcher.dispatchEvent(e);
  }
  public function hasEventListener(t:String):Bool{
    return _dispatcher.hasEventListener(t);
  }
  public function addEventListener(t:String, l:Dynamic->Void,
                          ?u:Bool=false, ?p:Int=0, ?w:Bool=false):Void{
    _dispatcher.addEventListener(t, l, u, p, w);
  }
  public function removeEventListener(t:String, 
                                    l:Dynamic->Void, u:Bool=false):Void{
    _dispatcher.removeEventListener(t, l, u);
  }
  public function willTrigger(t:String):Bool {
    return _dispatcher.willTrigger(t);
  }
  
  // == Private Vars ==
  
  // Internal variables used to get data from the web
  private var _loader:URLLoader;
  private var _request:URLRequest;
  
  // The list of words and their frequencies
  private var _tagList:Array<Dynamic>;

  // The object containing tag names as keys and their values as values.
  private var _tagHashTable:Dynamic;
  
  // == Constructor ==
  public function new(){
    _loader = new URLLoader();
    _request = new URLRequest();
    _dispatcher = new EventDispatcher(this);
  }
  
} // end of the class


// == Custom data types ==

// === EventBind ===
// A listener function + event name couple.
typedef EventBind = {
    var event : String;
    var listener : Event -> Void;
}