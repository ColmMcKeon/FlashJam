theSlider.onPress = function()
{
   theSlider.startDrag(false,0,-4,82,-4);
   this.onEnterFrame = function()
   {
      Result = theSlider._x / 82 * 100;
      Result = Math.ceil(Result);
      _parent.MP3Sound.setVolume(Result);
      _root.MP3Vol = Result;
   };
};
theSlider.onRelease = function()
{
   theSlider.stopDrag();
   delete this.onEnterFrame;
};
theSlider.onRollOver = function()
{
   _root.ToolTip("Volume",158,93);
};
theSlider.onRollOut = function()
{
   _root.Cancel();
};
