package org.hy.common.ui.event
{
	import flash.events.Event;
	
	import org.hy.common.ui.TextInput;
	
	
	
	
	
	/**
	 * 有新、旧值对比不同显示提示信息的文本框的事件
	 * 
	 * 并且，当有提示信息时，文本框的外观有明显的变化。如在左上角出现一个红的三角形。
	 * 
	 * 注意：不允许在此事件中触发提示信息的修改，否则会引发递归事件的错误
	 *
	 * @author      ZhengWei(HY)
	 * @createDate  2015-12-09
	 * @version     v1.0
	 */
	public class TextInputEvent extends Event
	{
		public static const $E_ChangeData:String      = "changedata";
		
		
		private var _text:TextInput;
		
		/**
		 * 编程代码引用的改变: false
		 * 用户操作引用的改变: true
		 */
		private var _isCustomerChange:Boolean;
		
				
		
		public function TextInputEvent(i_Text:TextInput ,i_IsCustomerChange:Boolean ,i_Type:String = $E_ChangeData)
		{
			super(i_Type);
			
			this._text             = i_Text;
			this._isCustomerChange = i_IsCustomerChange;
		}
		
		

		public function get text():TextInput
		{
			return _text;
		}

		
		
		public function get isCustomerChange():Boolean
		{
			return _isCustomerChange;
		}
		
	}
}