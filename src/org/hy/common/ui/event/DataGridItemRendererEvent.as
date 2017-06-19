package org.hy.common.ui.event
{
	import flash.events.Event;
	
	import spark.components.Label;
	import spark.components.gridClasses.GridColumn;
	
	import org.hy.common.ui.DataGridItemRenderer;
	
	
	
	
	
	/**
	 * 二维表格的纯文本文字的单元格式组件值的发生改变时触发的事件
	 *
	 * @author      ZhengWei(HY)
	 * @createDate  2015-08-20
	 * @version     v1.0
	 */
	public class DataGridItemRendererEvent extends Event
	{
		public static const $E_Change:String = "change";
		
		
		/** 单元格对象 */
		private var _cell:DataGridItemRenderer;
		
		/** 单元格上的值 */
		private var _data:Object;
		
		/** 单元格对象 */
		private var _column:GridColumn;
		
		/** 显示控件 */
		private var _value:Label;
		
		
		
		public function DataGridItemRendererEvent(i_Cell:DataGridItemRenderer ,i_Data:Object ,i_Column:GridColumn ,i_Value:Label ,i_Type:String = $E_Change)
		{
			super(i_Type);
			
			this._cell     = i_Cell;
			this._data     = i_Data;
			this._column   = i_Column;
			this._value    = i_Value;
		}
		
		
		
		public function get cell():DataGridItemRenderer
		{
			return this._cell;
		}
		
		
		
		public function get data():Object
		{
			return this._data;
		}
		
		
		
		public function get column():GridColumn
		{
			return this._column;
		}
		
		
		
		public function set value(i_Value:String):void
		{
			this._value.text = i_Value;
		}
		
		
		
		public function get value():String
		{
			return this._value.text;
		}
		
		
		
		/**
		 * 设置提示信息
		 */
		public function set toolTip(i_ToolTip:String):void
		{
			this._value.toolTip = i_ToolTip;
		}
		
		
		
		/**
		 * 获取提示信息 
		 */
		public function get toolTip():String
		{
			return this._value.toolTip;
		}
		
	}
}