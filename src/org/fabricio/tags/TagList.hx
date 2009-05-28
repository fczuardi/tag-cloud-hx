package org.fabricio.tags;

import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.Event;
import flash.Error;
import hxjson2.JSONDecoder;
// ==== package org.fabricio.tags ====

// = TagList =
// Class that represents a list of tags and their frequencies
class TagList {
  
  // == Methods ==
  
  // === loadDataURL(url:String, fmt:ListFormat):Bool ===
  // Reset the tag list if not empty, and load the list data from 
  // **{{{url}}}**, returns {{{false}}} if the URL is invalid.
  // The format parameter **{{{fmt}}}** is optional and defaults to {{{ListFormat.json}}}.
  public function loadDataURL(url:String, ?fmt:ListFormat):Bool{
    fmt = (fmt == null) ? ListFormat.json : fmt;
    switch(fmt){
      case json: return loadJSONDataURL(url);
      case rss: return loadRSSDataURL(url);
    }
  }
  
  // === loadJSONDataURL(url:String):Bool ===
  // Same as {{{TagList.loadDataURL()}}}, but requires **{{{url}}}** 
  // to be JSON formatted.
  //
  // Example of valid JSON formatted tag-list URL:\\
  // [[http://feeds.delicious.com/v2/json/tags/fabricio?count=50]]
  public function loadJSONDataURL(url:String):Bool{
    var listeners:Array<EventBind> = [
      {event:Event.COMPLETE, listener: JSONLoadComplete}
    ];
    return requestURL(url, listeners);
  }

  // onComplete callback for loadJSONDataURL
  private function JSONLoadComplete(evt:Event):Void{
    trace("completeHandler");
    var json_ob = new JSONDecoder(_loader.data, true).getValue();
    _frequency_table = json_ob.tags;
    trace("_frequency_table.Felicidade " + _frequency_table.Felicidade);
  }

  // === loadRSSDataURL(url:String):Bool ===
  // Same as {{{TagList.loadDataURL()}}}, but requires **{{{url}}}** to be 
  // RSS formatted.
  //
  // Example of valid JSON formatted tag-list URL:\\
  // [[http://feeds.delicious.com/v2/rss/tags/fabricio?count=50]]
  public function loadRSSDataURL(url:String):Bool{
    var listeners:Array<EventBind> = [
      {event:Event.COMPLETE, listener: RSSLoadComplete}
    ];
    return requestURL(url, listeners);
  }

  // onComplete callback for loadRSSDataURL
  private function RSSLoadComplete(evt:Event):Void{
    trace("completeHandler RSS TBD - Not implemented yet");
  }

  // == Private Helpers ==
  
  // === requestURL(url:String, listeners:Array<EventBind>):Bool ===
  // Makes a request to **{{{url}}}** and add **{{{listeners}}}** to it.\\
  // Returns {{{false}}} if the URL is invalid.
  private function requestURL(url:String, listeners:Array<EventBind>):Bool{
    _loader.close();
    _request.url = url;
    for(i in Reflect.fields(listeners)){
      _loader.addEventListener(i, Reflect.field(listeners,i));
    }
    try {
      _loader.load(_request);
      return true;
    } catch (error:Error) {
      return false;
    }
  }
  
  // == Constants & Private Vars ==
  
  // Internal variables used to get data from the web
  private var _loader:URLLoader;
  private var _request:URLRequest;
  
  // The list of words and their frequencies
  private var _frequency_table:Dynamic;
  
  // == Constructor ==
  public function new(){
    _loader = new URLLoader();
    _request = new URLRequest();
  }
  
} // end of the class


// == Custom data types ==

// === ListFormat ===
// The available formats a TagList object can load data from.
enum ListFormat{
  json;
  rss;
}

// === EventBind ===
// A listener function + event name couple.
typedef EventBind = {
    var event : String;
    var listener : Event -> Void;
}