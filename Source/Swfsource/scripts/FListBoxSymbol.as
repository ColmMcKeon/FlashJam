function FListBoxClass()
{
   this.itemSymbol = "FListItemSymbol";
   this.init();
   this.permaScrollBar = true;
   var _loc2_ = 0;
   while(_loc2_ < this.labels.length)
   {
      this.addItem(this.labels[_loc2_],this.data[_loc2_]);
      _loc2_ = _loc2_ + 1;
   }
   this.boundingBox_mc.gotoAndStop(1);
   this.width = this._width;
   this.height = this._height;
   this._yscale = this._xscale = 100;
   this.setSize(this.width,this.height);
   if(this.changeHandler.length > 0)
   {
      this.setChangeHandler(this.changeHandler);
   }
}
FListBoxClass.prototype = new FScrollSelectListClass();
Object.registerClass("FListBoxSymbol",FListBoxClass);
FListBoxClass.prototype.getSelectedIndices = function()
{
   var _loc2_ = new Array();
   for(var _loc3_ in this.selected)
   {
      _loc2_.push(this.selected[_loc3_].sIndex);
   }
   return _loc2_.length <= 0 ? undefined : _loc2_;
};
FListBoxClass.prototype.getSelectedItems = function()
{
   var _loc3_ = this.getSelectedIndices();
   var _loc4_ = new Array();
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc4_.push(this.getItemAt(_loc3_[_loc2_]));
      _loc2_ = _loc2_ + 1;
   }
   return _loc4_.length <= 0 ? undefined : _loc4_;
};
FListBoxClass.prototype.getSelectMultiple = function()
{
   return this.selectMultiple;
};
FListBoxClass.prototype.getRowCount = function()
{
   return this.numDisplayed;
};
FListBoxClass.prototype.setSelectedIndices = function(indexArray)
{
   this.clearSelected();
   var _loc2_ = 0;
   while(_loc2_ < indexArray.length)
   {
      this.selectItem(indexArray[_loc2_],true);
      _loc2_ = _loc2_ + 1;
   }
   this.updateControl();
};
FListBoxClass.prototype.setSelectMultiple = function(flag)
{
   this.selectMultiple = flag;
};
FListBoxClass.prototype.setRowCount = function(count)
{
   var _loc2_ = count * (this.itmHgt - 2) + 2;
   this.setSize(this.width,_loc2_);
};
FListBoxClass.prototype.setWidth = function(wdt)
{
   this.setSize(wdt,this.height);
};
FListBoxClass.prototype.setSize = function(w, h)
{
   if(!this.enable)
   {
      return undefined;
   }
   w = Math.max(w,20);
   h = Math.max(h,40);
   this.container_mc.removeMovieClip();
   this.container_mc = this.createEmptyMovieClip("container",3);
   this.measureItmHgt();
   this.numDisplayed = Math.floor(h / (this.itmHgt - 2));
   this.height = this.numDisplayed * (this.itmHgt - 2) + 2;
   super.setSize(w,this.height);
};
FListBoxClass.prototype.removeItemAt = function(index)
{
   this.selectHolder = this.getSelectedIndices();
   return super.removeItemAt(index);
};
FListBoxClass.prototype.selectionHandler = function(itemNum)
{
   var _loc3_;
   var _loc4_;
   var _loc2_;
   var _loc6_;
   if(this.clickFilter)
   {
      _loc3_ = this.topDisplayed + itemNum;
      if(this.getItemAt(_loc3_) == undefined)
      {
         this.changeFlag = false;
         return undefined;
      }
      this.changeFlag = true;
      if(!this.selectMultiple && !Key.isDown(17) || !Key.isDown(16) && !Key.isDown(17))
      {
         this.clearSelected();
         this.selectItem(_loc3_,true);
         this.lastSelected = _loc3_;
         this.container_mc["fListItem" + itemNum + "_mc"].drawItem(this.getItemAt(_loc3_),this.isSelected(_loc3_));
      }
      else if(Key.isDown(16) && this.selectMultiple)
      {
         if(this.lastSelected == -1)
         {
            this.lastSelected = _loc3_;
         }
         _loc4_ = this.lastSelected >= _loc3_ ? -1 : 1;
         this.clearSelected();
         _loc2_ = this.lastSelected;
         while(_loc2_ != _loc3_)
         {
            this.selectItem(_loc2_,true);
            if(_loc2_ >= this.topDisplayed && _loc2_ < this.topDisplayed + this.numDisplayed)
            {
               this.container_mc["fListItem" + (_loc2_ - this.topDisplayed) + "_mc"].drawItem(this.getItemAt(_loc2_),this.isSelected(_loc2_));
            }
            _loc2_ += _loc4_;
         }
         this.selectItem(_loc3_,true);
         this.container_mc["fListItem" + (_loc3_ - this.topDisplayed) + "_mc"].drawItem(this.getItemAt(_loc3_),this.isSelected(_loc3_));
      }
      else if(key.isDown(17))
      {
         _loc6_ = this.isSelected(_loc3_);
         if(!this.selectMultiple)
         {
            this.clearSelected();
         }
         if(!(!this.selectMultiple && _loc6_))
         {
            this.selectItem(_loc3_,!_loc6_);
            this.container_mc["fListItem" + itemNum + "_mc"].drawItem(this.getItemAt(this.topDisplayed + itemNum),this.isSelected(this.topDisplayed + itemNum));
         }
         this.lastSelected = _loc3_;
      }
   }
   else
   {
      this.clickFilter = true;
   }
};
FListBoxClass.prototype.moveSelBy = function(itemNum)
{
   super.moveSelBy(itemNum);
   this.releaseHandler();
};
