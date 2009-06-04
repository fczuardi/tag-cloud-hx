/*

  var localpoint:Point = new Point(_tags[i].x-incX, _tags[i].y-incY);
  var globalpoint:Point = this.localToGlobal(localpoint);
  var cornersOverShape = 0;
  for (c in 0...5){
    for(l in 0...3){
      if (shape.hitTestPoint(globalpoint.x+(c*1/4)*_tags[i].width, globalpoint.y+(l*1/2)*_tags[i].height, true)) cornersOverShape++;
    }
  }
  if (cornersOverShape < 7){
    _tags[i].x -= Math.round(incX);
    _tags[i].y -= Math.round(incY);
  }else if (cornersOverShape < 9){
    _tags[i].x += Math.round(incY/4);
    _tags[i].y += Math.round(incX/4);
  }else{
    _tags[i].x = -100 + Math.round(Math.random()*300);
    _tags[i].y = -20 + Math.round(Math.random()*40);
  }
}

*/