theslider2.onPress = function()
{
   theslider2.startDrag(false,0,-4.1,52,-4.1);
   this.onEnterFrame = function()
   {
      PanResult = theslider2._x / 52 * 100;
      PanResult = Math.ceil(PanResult);
      if(PanResult < 49)
      {
         PanResult = PanResult / 49 * 100 - 100;
      }
      else if(PanResult > 51)
      {
         PanResult = PanResult / 49 * 100 - 100;
      }
      else
      {
         PanResult = 0;
      }
      _parent.MP3Sound.setPan(PanResult);
      panINf = _parent.MP3Sound.getPan();
   };
};
theslider2.onRelease = function()
{
   theslider2.stopDrag();
   delete this.onEnterFrame;
};
panINf = 0;
theslider2.onRollOver = function()
{
   _root.ToolTip("Balance",172,48);
};
theslider2.onRollOut = function()
{
   _root.Cancel();
};
