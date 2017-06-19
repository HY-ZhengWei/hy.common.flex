package org.hy.common.ui
{
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.IList;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import org.hy.common.Help;
	import org.hy.common.ui.event.ComboBoxCheckEvent;
	import org.hy.common.ui.event.ComboBoxCheckItemRendererEvent;
	
	import spark.components.CheckBox;
	import spark.components.ComboBox;
	import spark.components.List;
	import spark.components.supportClasses.DropDownListBase;
	import spark.components.supportClasses.ItemRenderer;
	import spark.events.IndexChangeEvent;
	
	
	
	
	
	/**
	 * 复选的下拉列表框
	 * 
	 * @author      ZhengWei(HY)
	 * @createDate  2015-12-07
	 * @version     V1.0
	 */
	[Event(name="changedata" ,type="org.hy.common.ui.event.ComboBoxCheckEvent")]
	public class ComboBoxCheck extends ComboBox
	{
		
		/** 
		 * 下拉列表框中的常驻标题文字。
		 * 2016-02-18：发现一个Bug：当初始化时，赋值为""时，选择后鼠标离开后title会变成""（无论是否其后设置了title）。所以，请初始时设置一个值 
		 */
		private var _title:String;
		
		/** 标识复选框是否选中的字段名称 */
		[Bindable]
		public var selectedField:String;
		
		/** 标识复选框是否可用的字段名称 */
		[Bindable]
		public var enabledField:String;
		
		/** 是否允许编辑文本框内容。默认为不可编辑 */
		private var _isAllowTextEdit:Boolean;
		
		[Bindable]
		private var checkUIs:Object;
		
		
		
		public function ComboBoxCheck()
		{
			super();
			
			this._title           = "";
			this.selectedField    = "";
			this.enabledField     = "";
			this._isAllowTextEdit = false;
			this.checkUIs         = new Object();
			
			var v_RendererFactory:ClassFactory = new ClassFactory(ComboBoxCheckItemRenderer);
			v_RendererFactory.properties = {showComplete:item_ShowCompleteHandler ,change:item_ChangeHandler};
			this.itemRenderer = v_RendererFactory;
			
			this.addEventListener(MouseEvent.CLICK        ,clickHandler);
			this.addEventListener(FlexEvent.INITIALIZE    ,initializeHandler);
			
			// 因为重写了 item_mouseDownHandler(...) 方法，造成选择项下标不会改变，所以此方法也就没有用了。
			this.addEventListener(IndexChangeEvent.CHANGE ,changeHandler);
		}
		
		
		
		/**
		 * 刷新所有选项状态。
		 * 因值与组件没有绑定，所以当值变化时，需手工刷新。
		 */
		public function refurbish():void
		{
			if ( this.dataProvider != null && this.checkUIs != null )
			{
				for (var v_Index:int=0; v_Index<this.dataProvider.length; v_Index++)
				{
					var v_Item:Object = this.dataProvider.getItemAt(v_Index);
					var v_UI:CheckBox = this.checkUIs[v_Item[this.labelField]] as CheckBox;
					
					if ( v_UI != null )
					{
						if ( !Help.isNull(this.selectedField) )
						{
							v_UI.selected = v_Item[this.selectedField];
						}
						else
						{
							v_UI.selected = false;
						}
						
						if ( !Help.isNull(this.enabledField) )
						{
							v_UI.enabled = v_Item[this.enabledField];
						}
						else
						{
							v_UI.enabled = true;
						}
					}
				}
			}
			
			this.selectedItem = Help.NVL(this._title ,"");
		}
		
		
		
		/**
		 * 初始化显示下拉列表项时的事件
		 */
		protected function item_ShowCompleteHandler(i_Event:ComboBoxCheckItemRendererEvent):void
		{
			if ( i_Event.data != null )
			{
				i_Event.label = i_Event.data[this.labelField];
				
				if ( !Help.isNull(this.selectedField) )
				{
					i_Event.selected = i_Event.data[this.selectedField];
				}
				else
				{
					i_Event.selected = false;
				}
				
				if ( !Help.isNull(this.enabledField) )
				{
					i_Event.itemEnabled = i_Event.data[this.enabledField];
				}
				else
				{
					i_Event.itemEnabled = true;
				}
				
				this.checkUIs[i_Event.label] = i_Event.valueUI;
			}
			else
			{
				i_Event.label       = "";
				i_Event.selected    = false;
				i_Event.itemEnabled = true;
			}
		}
		
		
		
		/**
		 * 下拉列表项的值改变时的事件
		 */
		protected function item_ChangeHandler(i_Event:ComboBoxCheckItemRendererEvent):void
		{
			if ( i_Event != null )
			{
				for (var v_Index:int=0; v_Index<this.dataProvider.length; v_Index++)
				{
					var v_Item:Object = this.dataProvider.getItemAt(v_Index);
					
					if ( v_Item[this.labelField] == i_Event.label )
					{
						v_Item[this.selectedField] = i_Event.selected;
						this.dispatchEvent(new ComboBoxCheckEvent(v_Index ,v_Item ,ComboBoxCheckEvent.$E_ChangeData));
						break;
					}
				}
			}
		}
		
		
		
		/**
		 * 点击下拉表任何地方，就自动打开下拉列表
		 */
		protected function clickHandler(i_Event:MouseEvent):void
		{
			if ( !this._isAllowTextEdit )
			{
				this.openDropDown();
			}
		}
		
		
		
		/**
		 * 设置下拉列表不可被编辑
		 */
		protected function initializeHandler(event:FlexEvent):void
		{
			this.textInput.enabled = this._isAllowTextEdit;
		}
		
		
		
		/**
		 * 如果重写了 item_mouseDownHandler(...) 方法，造成选择项下标不会改变，所以此方法也就没有用了。
		 */ 
		protected function changeHandler(i_Event:IndexChangeEvent):void
		{
			if ( !this._isAllowTextEdit )
			{
				this.selectedItem = Help.NVL(this._title ,"");
				if ( this.textInput != null )
				{
					this.textInput.text = Help.NVL(this._title ,"");
				}
			}
		}
		
		
		
		override protected function item_mouseDownHandler(event:MouseEvent):void
		{
			// 选择项时，不自动关闭下拉列表 
			// super.item_mouseDownHandler(event);
		}
		
		
		
		
		[Bindable]
		public function set title(i_Title:String):void
		{
			this._title       = i_Title;
			this.selectedItem = this._title;
			if ( this.textInput != null )
			{
				this.textInput.text = Help.NVL(this._title ,"");
			}
		}
		
		
		
		public function get title():String
		{
			return this._title;
		}

		
		
		/** 是否允许编辑文本框内容 */
		[Bindable]
		public function get isAllowTextEdit():Boolean
		{
			return _isAllowTextEdit;
		}

		public function set isAllowTextEdit(value:Boolean):void
		{
			_isAllowTextEdit = value;
		}
		
	}
	
}