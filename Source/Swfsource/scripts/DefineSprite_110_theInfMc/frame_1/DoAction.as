theInfoScren.text = _parent.songdetails;
thehandle._alpha = 0;
thehandle.onPress = function()
{
   this._parent.startDrag();
};
thehandle.onRelease = function()
{
   stopDrag();
};
