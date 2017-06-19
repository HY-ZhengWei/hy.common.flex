package org.hy.common.ui.event
{
	import flash.events.Event;
	
	import spark.components.CheckBox;
	
	
	
	
	
	/**
	 * 可实现复选的下拉列表框。此为下拉列表框项的渲染器值的发生改变时触发的事件
	 *
	 * @author      ZhengWei(HY)
	 * @createDate  2015-12-07
	 * @version     v1.0
	 */
	public class ComboBoxCheckItemRendererEvent extends Event
	{
		public static const $E_ShowComplete:String = "showComplete";
		
		public static const $E_Change:String       = "change";
		
		
		
		/** 单元格上的值 */
		private var _data:Object;
		
		/** 显示控件 */
		private var _valueUI:CheckBox;
		
		
		
		public function ComboBoxCheckItemRendererEvent(i_Data:Object ,i_ValueUI:CheckBox ,i_Type:String = $E_Change)
		{
			super(i_Type);
			
			this._data     = i_Data;
			this._valueUI  = i_ValueUI;
		}
		
		
		
		public function get data():Object
		{
			return this._data;
		}
		
		
		
		public function set label(i_Label:String):void
		{
			this._valueUI.label = i_Label;
		}
		
		
		
		public function get label():String
		{
			return this._valueUI.label;
		}
		
		
		
		public function set selected(i_Selected:Boolean):void
		{
			this._valueUI.selected = i_Selected;
		}
		
		
		
		public function get selected():Boolean
		{
			return this._valueUI.selected;
		}
		
		
		
		public function set itemEnabled(i_Enabled:Boolean):void
		{
			this._valueUI.enabled = i_Enabled;
		}
		
		
		
		public function get itemEnabled():Boolean
		{
			return this._valueUI.enabled;
		}
		
		
		
		public function get valueUI():CheckBox
		{
			return this._valueUI;
		}
		
	}
}