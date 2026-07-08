function LoadXmlData()
{
   my_lb.removeAll();
   ListOfSongs.splice(0);
   Mp3XML.onLoad = function(success)
   {
      if(success)
      {
         clearInterval(pollingxml);
         errorScrn1.removeMovieClip();
         child = Mp3XML.firstChild.childNodes;
         i = 0;
         while(i < child.length)
         {
            my_lb.addItem(String(child[i].firstChild.nodeValue));
            ListOfSongs.push(String(child[i].firstChild.nodeValue));
            i++;
         }
         my_lb.setSelectedIndex(0);
         lastItem = my_lb.getLength();
      }
      else if(ErrorFlag != "on")
      {
         attachMovie("errorScrn","errorScrn1",12);
         errorScrn1._x = 39;
         errorScrn1._y = 31;
         errorScrn1.EerScren.text = "Place your mp3\'s in the mp3 folder and click here.";
         ErrorFlag = "on";
      }
   };
   Mp3XML.load("mp3/music.xml");
}
function firstlist()
{
   errorScrn1.EerScren.text = "Please wait..";
   fscommand("exec","MP3manager.exe");
   pollingxml = setInterval(function()
   {
      LoadXmlData();
   }
   ,2000);
}
function playSong()
{
   MP3Sound.loadSound("mp3/" + my_lb.getSelectedItem().label,false);
   MP3Sound.setVolume(_root.MP3Vol);
   SongListNum = my_lb.getSelectedIndex();
   _root.nameofSong = my_lb.getItemAt(SongListNum).label;
   my_lb.setSelectedIndex(SongListNum);
   my_lb.setScrollPosition(SongListNum);
   SetSlider();
   this.createEmptyMovieClip("temp5",7);
   temp5.onEnterFrame = function()
   {
      bytesLoaded = MP3Sound.getBytesLoaded();
      bytesTotal = MP3Sound.getBytesTotal();
      percentLoaded = Math.round(100 * bytesLoaded / bytesTotal);
      if(percentLoaded > 1)
      {
         loadinInf = Number(percentLoaded) + "%";
      }
      else
      {
         loadinInf = 0;
      }
      if(bytesLoaded == bytesTotal && MP3Sound.duration > 0)
      {
         MP3Sound.start();
         unloadMovie(this);
      }
   };
}
function stopSong()
{
   stopAllSounds();
   delete temp22.onEnterFrame;
}
function playNextSong()
{
   if(SongPlayMode == "Random")
   {
      endRandNum = lastItem;
      RandNum = random(endRandNum);
      RandNum = Math.ceil(RandNum);
      SongListNum = RandNum;
   }
   else
   {
      SongListNum += 1;
   }
   if(SongListNum > lastItem - 1)
   {
      SongListNum = 0;
   }
   SetSlider();
   _root.nameofSong = my_lb.getItemAt(SongListNum).label;
   my_lb.setSelectedIndex(SongListNum);
   my_lb.setScrollPosition(SongListNum);
   ticker();
   MP3Sound.loadSound("mp3/" + _root.nameofSong,true);
   MP3Sound.setVolume(_root.MP3Vol);
   this.createEmptyMovieClip("temp5",7);
   temp5.onEnterFrame = function()
   {
      bytesLoaded = MP3Sound.getBytesLoaded();
      bytesTotal = MP3Sound.getBytesTotal();
      percentLoaded = Math.round(100 * bytesLoaded / bytesTotal);
      if(percentLoaded > 1)
      {
         loadinInf = Number(percentLoaded) + "%";
      }
      else
      {
         loadinInf = 0;
      }
      if(bytesLoaded == bytesTotal && MP3Sound.duration > 0)
      {
         MP3Sound.start();
         SoundLoaded = 1;
         unloadMovie(this);
      }
   };
}
function ToggleMode()
{
   if(SongPlayMode == "Random")
   {
      SongPlayMode = "Next";
      _root.roundSym._visible = false;
      _root.arrrSym._visible = true;
   }
   else
   {
      SongPlayMode = "Random";
      _root.roundSym._visible = true;
      _root.arrrSym._visible = false;
   }
   btnInf.text = ">" + SongPlayMode;
}
function SetSlider()
{
   if(volFlag != "yes")
   {
      volumeSlider_MC.volINf = MP3Sound.getVolume();
      volumeSlider_MC.theSlider._x = Math.ceil(volumeSlider_MC.volINf / 100 * 82);
      volFlag = "yes";
   }
}
function HowLoud()
{
   trace(MP3Sound.getVolume());
}
function ticker()
{
   if(MP3Sound.ID3.TIT2 == undefined)
   {
      tickerText = my_lb.getSelectedItem().label;
   }
   else
   {
      tickerText = MP3Sound.ID3.TIT2 + "   ::   " + MP3Sound.ID3.artist;
   }
   firstChar = 0;
   lineLength = 50;
   var _loc1_ = 0;
   while(_loc1_ < lineLength)
   {
      tickerText = " " + tickerText;
      _loc1_ = _loc1_ + 1;
   }
   ViewTic(tickerText);
}
function ViewTic(Mp3name)
{
   this.createEmptyMovieClip("temp22",22);
   temp22.onEnterFrame = function()
   {
      nowPlay.text = Mp3name.substr(firstChar,lineLength);
      firstChar++;
      if(firstChar > tickerText.length)
      {
         firstChar = 0;
      }
   };
}
function gettheSongA()
{
   Apart = "";
   LeftCount = _root.SongFind.length;
   i = 0;
   while(i < _root.SongFind.length)
   {
      Apart += String(String(SongFind[i]));
      i++;
   }
   gettheSongB(Apart);
}
function gettheSongB(fileA)
{
   i = 0;
   while(i < _root.ListOfSongs.length)
   {
      theSongNAme = String(_root.ListOfSongs[i]);
      Bpart = String(_root.theSongNAme.substr(0,LeftCount));
      Bpart = Bpart.toUpperCase();
      if(fileA == Bpart)
      {
         my_lb.setSelectedIndex(i);
         my_lb.setScrollPosition(i);
         break;
      }
      i++;
   }
}
function ClockTimer()
{
   nowtime = getTimer();
   futuretime = nowtime + 2000;
   this.createEmptyMovieClip("temp12",this.getNextHighestDepth());
   temp12.onEnterFrame = function()
   {
      nowtime = getTimer();
      if(nowtime >= futuretime)
      {
         SongFind.splice(0,SongFind.length);
         delete temp12.onEnterFrame;
      }
   };
}
function ToolTip(theitemname, thexpos, theypos)
{
   this.createEmptyMovieClip("theToolTipMc2",this.getNextHighestDepth());
   theToolTipMc2.createTextField("tootipText",_root.theToolTipMc2.getNextHighestDepth(),6,3,100,50);
   theToolTipMc2.Tip_fmt = new TextFormat();
   theToolTipMc2.Tip_fmt.font = "_sans";
   theToolTipMc2.tootipText.multiline = false;
   theToolTipMc2.tootipText.selectable = false;
   theToolTipMc2.tootipText.autoSize = true;
   theToolTipMc2.tootipText.text = theitemname;
   theToolTipMc2.tootipText.setTextFormat(theToolTipMc2.Tip_fmt);
   BoxWidth = Number(theToolTipMc2.tootipText.textWidth + 12);
   theToolTipMc2._x = -300;
   theToolTipMc2._y = 35;
   theToolTipMc2.beginFill(16776960);
   theToolTipMc2.moveTo(5,5);
   theToolTipMc2.lineTo(BoxWidth,5);
   theToolTipMc2.lineTo(BoxWidth,20);
   theToolTipMc2.lineTo(5,20);
   theToolTipMc2.lineTo(5,5);
   theToolTipMc2.endFill();
   theToolTipMc2.lineStyle(1,0,100);
   theToolTipMc2.moveTo(5,5);
   theToolTipMc2.lineTo(BoxWidth,5);
   theToolTipMc2.lineTo(BoxWidth,20);
   theToolTipMc2.lineTo(5,20);
   theToolTipMc2.lineTo(5,5);
   MoveFromCue(thexpos,theypos);
}
function MoveFromCue(thexpos, theypos)
{
   thenowtime = getTimer();
   thefuturetime = thenowtime + 3000;
   this.createEmptyMovieClip("CueMc",143);
   CueMc.onEnterFrame = function()
   {
      thenowtime = getTimer();
      if(thenowtime >= thefuturetime)
      {
         theToolTipMc2._x = thexpos;
         theToolTipMc2._y = theypos;
         CueMc.removeMovieClip();
      }
   };
}
function Cancel()
{
   CueMc.removeMovieClip();
   theToolTipMc2.removeMovieClip();
}
this._lockroot = true;
volumeSlider_MC.volINf = 0;
songdetails = "No Tag Data";
Mp3XML = new XML();
NewXmldoc();
incNum = 0;
ListOfSongs = new Array();
_root.roundSym._visible = false;
SongPlayMode = "Next";
MP3Sound = new Sound();
TickerSong = "No Tag Data";
MP3Vol = Number(100);
Mp3XML.ignoreWhite = true;
LoadXmlData();
MP3Sound.onID3 = function()
{
   songdetails = "";
   for(var _loc1_ in MP3Sound.ID3)
   {
      songdetails += _loc1_ + " : " + MP3Sound.ID3[_loc1_] + "\n";
   }
   ticker();
};
MP3Sound.onSoundComplete = function()
{
   playNextSong();
};
SongFind = new Array();
my_lb.setStyleProperty("background",12770484);
Selection.setFocus(my_lb);
ReturnCall = new Object();
ReturnCall.onKeyDown = function()
{
   Selection.setFocus(my_lb);
   if(key.getCode() == 32)
   {
      playSong();
   }
   else if(key.getCode() == 39)
   {
      playNextSong();
   }
   else if(key.getCode() == 37)
   {
      ToggleMode();
   }
   else if(key.getCode() == 17)
   {
      stopSong();
   }
   else if(key.getCode() != 38)
   {
      if(key.getCode() != 40)
      {
         foo = String.fromCharCode(Key.getCode());
         SongFind.push(foo);
         gettheSongA();
         ClockTimer();
      }
   }
};
Key.addListener(ReturnCall);
var receiveConn = new LocalConnection();
connectSuccess = receiveConn.connect("channelA");
receiveConn.MessageSend = function(Mess_string)
{
   LoadXmlData();
};
