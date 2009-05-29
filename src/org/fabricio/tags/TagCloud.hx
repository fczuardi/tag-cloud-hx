package org.fabricio.tags;
/*import org.fabricio.tags.TagList;*/
import flash.display.MovieClip;
// ==== package org.fabricio.tags ====

// = TagCloud =
// A visualization of a tags set as a cloud.
class TagCloud extends MovieClip{
  
  public function new(list:TagList){
    super();
    var x:Float = 0;
    var y:Float = 0;
    var tags:Array<Tag> = [];
    for (i in list){
      if(i.value>3){
        var tag = new Tag(i.name.toUpperCase(), i.value *1.2+4, 0x333333, "DejaVuSansCondensedBold");
        tag.alpha = 0.8;
        tag.x = x;
        tag.y = y - (tag.height)/2;
        this.addChild(tag);
        x += tag.width;
        if(x>350){
          x = Math.random()*20;
          y += 30;
        }
      }
    }
    
  }
}