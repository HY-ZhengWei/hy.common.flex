package org.hy.common.ui
{
	import mx.collections.IList;
	import mx.events.ValidationResultEvent;
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	import org.hy.common.Help;
	
	
	
	
	
	/**
	 * 支持第三方用户自定义方法来验证。
	 * 
	 *   1. 第三方方法的入参为：验证源对象 this.source
	 *   2. 第三方方法的返回值(String类型)表示错误消息。难通过时返回null或""。
	 *   3. 本验证类，已废弃this.required参数的功能。目的是：百分百调用第三方验证方法。
	 * 
	 * @author      ZhengWei(HY)
	 * @createDate  2015-09-21
	 * @version     V1.0
	 */
	public class ActionValidator extends Validator
	{
		
		private static const $Error:String = "ActionValidatorExtension"; 
		
		
		
		/** 第三方用户自定义的方法引用 */
		private var _action:Function;
		
				
		
		public function ActionValidator()
		{
			super();
		}
		
		
		
		public function get action():Function
		{
			return _action;
		}
		
		
		
		/**
		 * @private
		 */
		public function set action(value:Function):void
		{
			_action = value;
		}
		
		
		
		/**
		 * 内部事件机制触发的验证动作。在此调用第三方用户自定义的验证方法。
		 */
		override protected function doValidation(i_Value:Object):Array
		{
			var v_Results:Array = super.doValidation(i_Value);
			
			if ( v_Results.length > 0 )
			{
				return v_Results;
			}
			
			if ( this._action != null )
			{
				var v_ActionRet:String = this.action.call(this ,this.source);
				
				if ( !Help.isNull(v_ActionRet) )
				{
					v_Results.push(new ValidationResult(true, "", $Error, v_ActionRet));
				}
			}
			
			return v_Results;
		}
		
		
		
		/**
		 * 对外公开的验证动作
		 */
		override public function validate(io_Value:Object=null ,io_SuppressEvents:Boolean=false):ValidationResultEvent
		{
			if ( io_Value == null )
			{
				io_Value = getValueFromSource();
			}
			
			var v_ResultEvent:ValidationResultEvent;
			
			if ( super.enabled )
			{
				var errorResults:Array = this.doValidation(io_Value);
				
				v_ResultEvent = super.handleResults(errorResults);
			}           
			else
			{
				io_SuppressEvents = true; // Don't send any events
			}
			
			if (!io_SuppressEvents)
			{
				dispatchEvent(v_ResultEvent);
			}
			
			return v_ResultEvent;
		}
		
	}
}