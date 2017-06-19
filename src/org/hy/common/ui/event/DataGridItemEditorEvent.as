package org.hy.common.ui.event
{
	import flash.events.Event;
	
	import mx.collections.IList;
	import mx.core.UIComponent;
	
	import org.hy.common.ui.DataGridItemEditor;
	
	import spark.components.ComboBox;
	import spark.components.DataGrid;
	import spark.components.TextInput;
	import spark.components.gridClasses.GridColumn;
	
	
	
	
	
	/**
	 * 二维表格的编辑状态下的单元格式组件值的发生改变时触发的事件
	 *
	 * @author      ZhengWei(HY)
	 * @createDate  2015-09-11
	 * @version     v1.0
	 */
	public class DataGridItemEditorEvent extends Event
	{
		public static const $E_ShowComplete:String = "showComplete";
		
		public static const $E_Change:String       = "change";
		
		
		
		/** 单元格对象 */
		private var _cell:DataGridItemEditor;
		
		/** 单元格所属的二维表对象 */
		private var _dataGrid:DataGrid;
		
		/** 单元格上的值 */
		private var _data:Object;
		
		/** 单元格对象 */
		private var _column:GridColumn;
		
		/** 显示控件 */
		private var _value:UIComponent;
		
		
		
		public function DataGridItemEditorEvent(i_Cell:DataGridItemEditor ,i_DataGrid:DataGrid ,i_Data:Object ,i_Column:GridColumn ,i_Value:UIComponent ,i_Type:String)
		{
			super(i_Type);
			
			this._cell     = i_Cell;
			this._dataGrid = i_DataGrid;
			this._data     = i_Data;
			this._column   = i_Column;
			this._value    = i_Value;
		}
		
		
		
		public function get cell():DataGridItemEditor
		{
			return this._cell;
		}
		
		
		
		public function get dataGrid():DataGrid
		{
			return this._dataGrid;
		}
		
		
		
		public function get data():Object
		{
			return this._data;
		}
		
		
		
		public function get column():GridColumn
		{
			return this._column;
		}
		
		
		
		/**
		 * 此 DataGroup 的数据提供程序。它必须为 IList。
		 * 在 Flex 框架中包含多个 IList 实现，包括 ArrayCollection、ArrayList 和 XMLListCollection。
		 * 此属性可用作数据绑定的源代码。
		 */
		public function set dataProvider(i_DataProvider:IList):void
		{
			if ( this._value is ComboBox )
			{
				(this._value as ComboBox).dataProvider = i_DataProvider;
			}
		}
		
		
		
		public function get dataProvider():IList
		{
			if ( this._value is ComboBox )
			{
				return (this._value as ComboBox).dataProvider;
			}
			else
			{
				return null;
			}
		}
		
		
		
		/**
		 * 数据提供程序项目中作为标签显示的字段名称。
		 * 如果 labelField 设置为空字符串 ("")，则在数据提供程序中不会使用任何字段来表示标签。
		 * labelFunction 属性将覆盖此属性。
		 */
		public function set labelField(i_LabelField:String):void
		{
			if ( this._value is ComboBox )
			{
				(this._value as ComboBox).labelField = i_LabelField;
			}
		}
		
		
		
		public function get labelField():String
		{
			if ( this._value is ComboBox )
			{
				return (this._value as ComboBox).labelField;
			}
			else
			{
				return null;
			}
		}
		
		
		
		/**
		 * 编辑控件显示的值
		 */
		public function set value(i_Value:String):void
		{
			if ( this._value is ComboBox )
			{
				var v_ComboBox:ComboBox   = this._value as ComboBox;
				v_ComboBox.selectedItem   = i_Value;
				v_ComboBox.textInput.text = i_Value;
			}
			else if ( this._value is TextInput )
			{
				(this._value as TextInput).text = i_Value;
			}
		}
		
		
		
		public function get value():String
		{
			if ( this._value is ComboBox )
			{
				return (this._value as ComboBox).textInput.text;
			}
			else if ( this._value is TextInput )
			{
				return (this._value as TextInput).text;
			}
			else
			{
				return null;
			}
		}
		
		
		
		/**
		 * 设置提示信息
		 */
		public function set toolTip(i_ToolTip:String):void
		{
			if ( this._value is ComboBox )
			{
				(this._value as ComboBox).toolTip = i_ToolTip;
			}
			else if ( this._value is TextInput )
			{
				(this._value as TextInput).toolTip = i_ToolTip;
			}
		}
		
		
		
		/**
		 * 获取提示信息 
		 */
		public function get toolTip():String
		{
			if ( this._value is ComboBox )
			{
				return (this._value as ComboBox).toolTip;
			}
			else if ( this._value is TextInput )
			{
				return (this._value as TextInput).toolTip;
			}
			else
			{
				return "";
			}
		}
		
		
		
		/**
		 * 下拉列表框选择的值
		 */
		public function set selectedItem(i_SelectedItem:Object):void
		{
			if ( this._value is ComboBox )
			{
				(this._value as ComboBox).selectedItem = i_SelectedItem;
			}
		}
		
		
		
		public function get selectedItem():Object
		{
			if ( this._value is ComboBox )
			{
				return (this._value as ComboBox).selectedItem;
			}
			else
			{
				return null;
			}
		}
		
		
		
		/**
		 * 下拉列表框选择的下标索引
		 */
		public function set selectedIndex(i_SelectedIndex:int):void
		{
			if ( this._value is ComboBox )
			{
				(this._value as ComboBox).selectedIndex = i_SelectedIndex;
			}
		}
		
		
		
		public function get selectedIndex():int
		{
			if ( this._value is ComboBox )
			{
				return (this._value as ComboBox).selectedIndex;
			}
			else
			{
				return -1;
			}
		}
		
	}
}