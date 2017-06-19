package org.hy.common.ui.event
{
	import flash.events.Event;
	
	
	
	
	
	/**
	 * 复选的下拉列表框的事件
	 *
	 * @author      ZhengWei(HY)
	 * @createDate  2015-12-08
	 * @version     v1.0
	 */
	public class ComboBoxCheckEvent extends Event
	{
		public static const $E_ChangeData:String   = "changedata";
		
		
		/** 选项索引号 */
		private var _itemIndex:int;
		
		/** 选项值 */
		private var _itemData:Object;
		
		
		
		public function ComboBoxCheckEvent(i_ItemIndex:int ,i_ItemData:Object ,i_Type:String = $E_ChangeData)
		{
			super(i_Type);
			
			this._itemIndex = i_ItemIndex;
			this._itemData  = i_ItemData;
		}
		
		
		
		public function get itemData():Object
		{
			return this._itemData;
		}
		
		
		
		public function get itemIndex():int
		{
			return this._itemIndex;
		}
		
	}
}