package org.hy.common.ui.event
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	
	
	
	/**
	 * 图片按钮触发的事件
	 *
	 * @author      ZhengWei(HY)
	 * @createDate  2015-07-24
	 * @version     v1.0
	 */
	public class ButtonImageEvent extends Event
	{
		public static const $E_ClickOn:String = "clickOn";
		
		
		
		private var _mouseEvent:MouseEvent;
		
		
		
		public function ButtonImageEvent(i_MouseEvent:MouseEvent ,i_Type:String = $E_ClickOn)
		{
			super(i_Type);
			
			this._mouseEvent = i_MouseEvent;
		}
		
		
		
		public function get mouseEvent():MouseEvent
		{
			return this._mouseEvent;
		}
		
	}
	
}