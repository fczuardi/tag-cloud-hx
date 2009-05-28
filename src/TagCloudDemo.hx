import org.fabricio.tags.TagList;

// = TagCloudDemo =
// A demo application using the features of the TagCloud-hx library
class TagCloudDemo{
  
  static function main(){
    var list = new TagList();
    list.loadDataURL("http://feeds.delicious.com/v2/json/tags/fabricio?count=50");
  }
}