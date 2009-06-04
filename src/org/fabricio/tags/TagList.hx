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
  
  // == Constructor ==
  public function new(){
    _loader = new URLLoader();
    _request = new URLRequest();
    _dispatcher = new EventDispatcher(this);
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
  
  // == Private Vars ==
  
  // Internal variables used to get data from the web
  private var _loader:URLLoader;
  private var _request:URLRequest;
  
  // The list of words and their frequencies
  private var _tagList:Array<Dynamic>;

  // The object containing tag names as keys and their values as values.
  private var _tagHashTable:Dynamic;
  
} // end of the class


// == Custom data types ==

// === EventBind ===
// A listener function + event name couple.
typedef EventBind = {
    var event : String;
    var listener : Event -> Void;
}
