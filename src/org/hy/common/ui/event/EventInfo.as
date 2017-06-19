package org.hy.common.ui.event
{
	
	/**
	 * 保存事件入参的基本信息。
	 * 
	 *   如addEventListener(...)方法的入参
	 * 
	 * @author      ZhengWei(HY)
	 * @createDate  2016-11-23
	 * @version     V1.0
	 */
	public class EventInfo
	{
		
		public var type:String;
		
		public var listener:Function;
		
		public var useCapture:Boolean;
		
		public var priority:int=0;
		
		public var useWeakReference:Boolean;
		
		
		
		public function EventInfo(i_Type:String, i_Listener:Function, i_UseCapture:Boolean=false, i_Priority:int=0, i_UseWeakReference:Boolean=false)
		{
			this.type             = i_Type;
			this.listener         = i_Listener;
			this.useCapture       = i_UseCapture;
			this.priority         = i_Priority;
			this.useWeakReference = i_UseWeakReference; 
		}
		
	}
}