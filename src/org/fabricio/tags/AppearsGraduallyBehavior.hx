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

// = AppearsGraduallyBehavior =
// Tag Cloud Behavior to make the tags appear one by one instead of all at once.
class AppearsGraduallyBehavior implements ITagCloudBehavior {

  // == Defaults ==
  // The default value for the available settings.
  private static inline var DEFAULT_INTERVAL:Int = 200; // miliseconds
  
  // == Methods ==
  
  // === init(tags:Array<Tag>) ===
  // Hide all tags. Create the sequence order in which the tags will appear.
  public function init(tags:Array<Tag>):Void{
    _tags = tags;
    _displaySequence = [];
    for (i in _tags){
      i.visible = false;
    }
    switch (_order){
      case normal:
        createRegularSequence();
      case random:
        createRandomSequence();
    }
  }
  
  // === step() ===
  // Check the elapsed time since the last step and if it is bigger than
  // the interval show the next tag of the queue.
  public function step(){
    if (_visibleTagsCounter >= _tags.length) return;
    var now:Int = flash.Lib.getTimer();
    var deltaT:Int = now-_lastTimeStamp;
    if (deltaT > _interval) {
      _tags[_displaySequence[_visibleTagsCounter++]].visible = true;
      _lastTimeStamp = now;
    }
  }
  
  // == Constructor ==
  // Acceps the following optional parameters:
  // * **{{{interval}}}**: The time in milliseconds between each tag appearance.
  // * **{{{order}}}**: The order to displays the tags, {{{normal}}} or {{{random}}}.
  public function new(?interval:Int, ?order:AppearanceOrder){
    _order = (order == null) ? normal : order;
    _interval = (interval == null) ? DEFAULT_INTERVAL : interval; // 1 sec
  }
  
  // == Private Helpers ==
  
  // Populate an Array with numbers in sequency.
  private function createRegularSequence(){
    for (i in 0..._tags.length) _displaySequence.push(i);
  }
  
  // Populate an Array with shufled indexes.
  private function createRandomSequence(){
    createRegularSequence();
    for (i in 0..._displaySequence.length) {
      var randIndex = Math.round(Math.random()*_displaySequence.length);
      var tempValue = _displaySequence[i];
      _displaySequence[i] = _displaySequence[randIndex];
      _displaySequence[randIndex] = tempValue;
    }
  }
  
  // == Private Vars ==
  private var _interval:Int;
  private var _order:AppearanceOrder;
  private var _tags:Array<Tag>;
  private var _visibleTagsCounter:Int;
  private var _lastTimeStamp:Int;
  private var _displaySequence:Array<Int>;
  
} // end of the class

// == Custom data types ==
enum AppearanceOrder{
  normal;
  random;
}