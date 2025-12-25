//hw_showData.pde
//宿題② WebからJSONまたはXMLファイルを探し、そのJSONファイルやXMLファイルを利用して何らかの結果を表示するプログラム
//2025/11/18
//

/*今回持ってきたXMLファイルはYahoo!ニュースのRSSである。「yahooニュース RSS」で検索→おそらく一番上に出てくる「RSS一覧-Yahoo!ニュース」で閲覧可能。
9つのトピックから気になるものをクリックすれば、そのトピック内の今現在出ているYahoo!ニュース新着記事を確認することができる。*/

PFont font;
int S;
XML xml;
void setup()
{
  S = 0;
  size(500, 500);
  font = createFont("Meiryo", 1);
  textFont(font);
}

void draw()
{
  background(255);
  if (S  == 0)
  {
    textSize(36);
    fill(0);
    textAlign(CENTER, CENTER);
    text("気になるトピックをクリック", width/2, 100);
    textSize(18);
    for (int i = 0; i < 9; i++)
    {
      String[] topic = {"主要", "国内", "国際", "経済", "エンタメ", "スポーツ", "IT", "科学", "地域"};
      fill(0, 0, 255);
      textAlign(LEFT, CENTER);
      if (i < 3)
      {
        text("・"+topic[i], 100+100*(i%3), 200+50*1);
      } else if (i < 6)
      {
        text("・"+topic[i], 100+100*(i%3), 200+50*2);
      } else
      {
        text("・"+topic[i], 100+100*(i%3), 200+50*3);
      }
    }
  } else if (S == 1)
  {
    background(255);
    textSize(18);
    XML[] topic = xml.getChild("channel").getChildren("item");
    for (int i = 0; i < topic.length; i++)
    {
      fill(0);
      textAlign(LEFT, CENTER);
      text("・"+topic[i].getChild("title").getContent(), 50, 100+i*50);
    }
    fill(255, 0, 0);
    text("戻る", 25, 35);
  } else if (S == 2)
  {
    background(255);
    textSize(18);


    XML[] topic = xml.getChild("channel").getChildren("item");
    for (int i = 0; i < topic.length; i++)
    {
      fill(0);
      textAlign(LEFT, CENTER);
      text("・"+topic[i].getChild("title").getContent(), 50, 100+i*50);
    }
    fill(255, 0, 0);
    text("戻る", 25, 35);
  } else if (S == 3)
  {
    background(255);
    textSize(18);


    XML[] topic = xml.getChild("channel").getChildren("item");
    for (int i = 0; i < topic.length; i++)
    {
      fill(0);
      textAlign(LEFT, CENTER);
      text("・"+topic[i].getChild("title").getContent(), 50, 100+i*50);
    }
    fill(255, 0, 0);
    text("戻る", 25, 35);
  } else if (S == 4)
  {
    background(255);
    textSize(18);


    XML[] topic = xml.getChild("channel").getChildren("item");
    for (int i = 0; i < topic.length; i++)
    {
      fill(0);
      textAlign(LEFT, CENTER);
      text("・"+topic[i].getChild("title").getContent(), 50, 100+i*50);
    }
    fill(255, 0, 0);
    text("戻る", 25, 35);
  } else if (S == 5)
  {
    background(255);
    textSize(18);


    XML[] topic = xml.getChild("channel").getChildren("item");
    for (int i = 0; i < topic.length; i++)
    {
      fill(0);
      textAlign(LEFT, CENTER);
      text("・"+topic[i].getChild("title").getContent(), 50, 100+i*50);
    }
    fill(255, 0, 0);
    text("戻る", 25, 35);
  } else if (S == 6)
  {
    background(255);
    textSize(18);


    XML[] topic = xml.getChild("channel").getChildren("item");
    for (int i = 0; i < topic.length; i++)
    {
      fill(0);
      textAlign(LEFT, CENTER);
      text("・"+topic[i].getChild("title").getContent(), 50, 100+i*50);
    }
    fill(255, 0, 0);
    text("戻る", 25, 35);
  } else if (S == 7)
  {
    background(255);
    textSize(18);


    XML[] topic = xml.getChild("channel").getChildren("item");
    for (int i = 0; i < topic.length; i++)
    {
      fill(0);
      textAlign(LEFT, CENTER);
      text("・"+topic[i].getChild("title").getContent(), 50, 100+i*50);
    }
    fill(255, 0, 0);
    text("戻る", 25, 35);
  } else if (S == 8)
  {
    background(255);
    textSize(18);


    XML[] topic = xml.getChild("channel").getChildren("item");
    for (int i = 0; i < topic.length; i++)
    {
      fill(0);
      textAlign(LEFT, CENTER);
      text("・"+topic[i].getChild("title").getContent(), 50, 100+i*50);
    }
    fill(255, 0, 0);
    text("戻る", 25, 35);
  } else if (S == 9)
  {
    background(255);
    textSize(18);


    XML[] topic = xml.getChild("channel").getChildren("item");
    for (int i = 0; i < topic.length; i++)
    {
      fill(0);
      textAlign(LEFT, CENTER);
      text("・"+topic[i].getChild("title").getContent(), 50, 100+i*50);
    }
    fill(255, 0, 0);
    text("戻る", 25, 35);
  }
}

void mousePressed()
{
  if (S == 0)
  {
    for (int x = 0; x < 3; x++)
    {
      for (int y = 0; y < 3; y++)
      {
        if (dist(125+100*x, 250+50*y, mouseX, mouseY)<= 25)
        {
          if ( y == 0)
          {
            x += 1;
          } else if (y == 1)
          {
            x += 3;
          } else if (y == 2)
          {
            y += 5;
          }
          S = x + y;
          if ( S == 1)
          {
            xml =
              loadXML("https://news.yahoo.co.jp/rss/topics/top-picks.xml");
          } else if ( S == 2)
          {
            xml =
              loadXML("https://news.yahoo.co.jp/rss/topics/domestic.xml");
          } else if ( S == 3)
          {
            xml =
              loadXML("https://news.yahoo.co.jp/rss/topics/world.xml");
          } else if ( S == 4)
          {
            xml =
              loadXML("https://news.yahoo.co.jp/rss/topics/business.xml");
          } else if ( S == 5)
          {
            xml =
              loadXML("https://news.yahoo.co.jp/rss/topics/entertainment.xml");
          } else if ( S == 6)
          {
            xml =
              loadXML("https://news.yahoo.co.jp/rss/topics/sports.xml");
          } else if ( S == 7)
          {
            xml =
              loadXML("https://news.yahoo.co.jp/rss/topics/it.xml");
          } else if ( S == 8)
          {
            xml =
              loadXML("https://news.yahoo.co.jp/rss/topics/science.xml");
          } else if ( S == 9)
          {
            xml =
              loadXML("https://news.yahoo.co.jp/rss/topics/local.xml");
          }
        }
      }
    }
  } else
  {
    if (dist(25, 35, mouseX, mouseY) <= 30)
    {
      S = 0;
    }
  }
}
