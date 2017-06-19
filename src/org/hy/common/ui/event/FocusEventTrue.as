package org.hy.common.ui.event
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.FocusEvent;

	
	
	
	
	/**
	 * 同时装载两种信息的文本框的焦点事件
	 *
	 * @author      ZhengWei(HY)
	 * @createDate  2016-11-24
	 * @version     v1.0
	 */
	public class FocusEventTrue extends FocusEvent
	{
		/** 焦点进入事件的标识 */
		public static const FOCUS_IN:String  = "focusInTrue";
		
		/** 焦点离开事件的标识 */
		public static const FOCUS_OUT:String = "focusOutTrue";
		
		
		
		/** 原先的焦点事件 */
		private var focusEvent:FocusEvent;
		
		
		
		public function FocusEventTrue(i_Type:String, i_FocusEvent:FocusEvent)
		{
			super(i_Type ,i_FocusEvent.bubbles ,i_FocusEvent.cancelable);
		}
		
		
		
		override public function get isRelatedObjectInaccessible():Boolean
		{
			return this.focusEvent.isRelatedObjectInaccessible;
		}
		
		override public function set isRelatedObjectInaccessible(value:Boolean):void
		{
			this.focusEvent.isRelatedObjectInaccessible = value;
		}
		
		
		
		override public function get keyCode():uint
		{
			return this.focusEvent.keyCode;
		}
		
		override public function set keyCode(value:uint):void
		{
			this.focusEvent.keyCode = value;
		}
		
		
		
		override public function get relatedObject():InteractiveObject
		{
			return this.focusEvent.relatedObject;
		}
		
		override public function set relatedObject(value:InteractiveObject):void
		{
			this.focusEvent.relatedObject = value;
		}
		
		
		
		override public function get shiftKey():Boolean
		{
			return this.focusEvent.shiftKey;
		}
		
		override public function set shiftKey(value:Boolean):void
		{
			this.focusEvent.shiftKey = value;
		}
		
	}
}