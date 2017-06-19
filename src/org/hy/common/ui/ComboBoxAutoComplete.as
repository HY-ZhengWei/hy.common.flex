package org.hy.common.ui
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ICollectionView;
	import mx.controls.ComboBox;
	import mx.core.UIComponent;
	
	import org.hy.common.Help;
	
	
	
	
	
	/**
	 * 一款能自动提示、自动完成的combobox控件（类似百度搜索框）
	 * <ol><b>新增属性</b>
	 * <li>isAutoComplete 是否自动完成，默认false</li>
	 * <li>isFocusInDropDown 获得焦点时，是否自动弹出下拉框，默认false</li>
	 * </ol>
	 * 参考于 http://blog.csdn.net/dirful/article/details/6894219
	 */
	public class ComboBoxAutoComplete extends ComboBox
	{
		public function ComboBoxAutoComplete()
		{
			super();
			
			editable = true;
			rowCount = 8;
			selectedIndex = -1;
			isTextBoxStringChange = false;
			isFocusInDropDown = false;
			isAutoComplete = false;
			//伪装成TextBox
			setStyle("cornerRadius",0);
			setStyle("arrowButtonWidth",0);
			setStyle("fontWeight","normal");
			setStyle("paddingLeft",0);
		}
		
		//获得焦点时，是否自动弹出下拉框，get set
		private var isFocusInDropDown:Boolean = false;
		
		//是否自动完成,get set
		private var isAutoComplete:Boolean = false;
		
		//类默认过滤函数,get set
		private var _filterFunction:Function = myFilterFunction;
		
		//文本是否发生了变化
		private var isTextBoxStringChange:Boolean = false;
		
		//按下的键是否是退格键
		private var isBackSpaceKeyDown:Boolean = false;
		
		
		/**
		 * 处理退格键按下的情况
		 */ 	
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if(!event.ctrlKey&&!event.shiftKey)
			{
				if(event.keyCode == Keyboard.BACKSPACE)
				{
					close();
					isBackSpaceKeyDown = true;
				}
				else
				{
					isBackSpaceKeyDown = false;
				}
				//当按UP键向上选择时，到达最顶时，显示用户原来所需文字
				if(event.keyCode == Keyboard.UP && selectedIndex == 0)
				{
					selectedIndex = -1;
				}								
			}
			super.keyDownHandler(event);
		}		
		
		/**
		 * 数据源发生变化,数据不为0弹出下拉列表
		 */ 
		override protected function collectionChangeHandler(event:Event):void
		{
			super.collectionChangeHandler(event);
			if(dataProvider.length > 0)
			{
				open();
			}
		}
		
		/**
		 * 获得焦点
		 */ 
		override protected function focusInHandler(event:FocusEvent):void{
			if(isFocusInDropDown) open();
			//
			super.focusInHandler(event);
		}
		
		/**
		 * 文本发生变化时
		 */ 
		override protected function textInput_changeHandler(event:Event):void
		{
			if(textInput.text == ""){
				isTextBoxStringChange = false;
			}
			else{			
				isTextBoxStringChange = true;
			}
			super.textInput_changeHandler(event);
			invalidateProperties();		//调用该方法，随后会触发调用commitProperties()
		}
		
		override protected function commitProperties():void{
			if(isTextBoxStringChange){
				prompt = text;
				filter();				//进行匹配项的查找
				if(isAutoComplete&&!isBackSpaceKeyDown){
					var autoCompleteString:String = "";
					if(dataProvider.length > 0)
					{
						autoCompleteString = itemToLabel(dataProvider[0]);
						textInput.selectRange(prompt.length,autoCompleteString.length);
						prompt = autoCompleteString;													
					}	
					else{
						textInput.selectRange(textInput.selectionActivePosition,textInput.selectionActivePosition);
					}
				}
				else{
					textInput.selectRange(textInput.selectionActivePosition,textInput.selectionActivePosition);	
				}
			}				
			super.commitProperties();
		}
		
		/**
		 * 与TextBox同样的宽度
		 */ 
		override protected function measure():void
		{
			super.measure();
			measuredWidth = UIComponent.DEFAULT_MEASURED_WIDTH;	
		}
		
		/**
		 * 过滤操作
		 */ 
		private function filter():void{
			var tmpCollection:ICollectionView = dataProvider as ICollectionView;
			tmpCollection.filterFunction = _filterFunction;
			tmpCollection.refresh();
		}
		
		/**
		 * 过滤函数
		 */ 
		private function myFilterFunction(item:Object):Boolean
		{
			var myLabel:String = itemToLabel(item);
			
			// ZhengWei(HY) Add 2016-05-16 输入空格显示所有下拉列表项
			if ( Help.isNull(text) )
			{
				return true;
			}
			
			// 原内容为： if(myLabel.substr(0,text.length).toLowerCase() == prompt.toLowerCase())
			// ZhengWei(HY) Edit 2016-05-16 改为下面的方式
			if ( myLabel.toLowerCase().indexOf(text.toLowerCase()) >= 0 )
			{
				return true;
			}
			
			return false;
		}
		
		
		/************************Get Set 属性**********************************/
		
		public function get FilterFunction():Function{
			return _filterFunction;
		}
		
		public function set FilterFunction(filterFunction:Function):void{
			_filterFunction = filterFunction;
		}
		
		
		public function get IsFocusInDropDown():Boolean{
			return isFocusInDropDown;
		}
		
		/**
		 * 获得焦点时，是否自动弹出下拉框，get set
		 */
		public function set IsFocusInDropDown(value:Boolean):void{
			isFocusInDropDown = value;
		}
		
		public function get IsAutoComplete():Boolean{
			return isAutoComplete;
		}
		
		/**
		 * 是否自动完成,get set
		 */
		public function set IsAutoComplete(value:Boolean):void{
			isAutoComplete = value;
		}		
		
	}
}