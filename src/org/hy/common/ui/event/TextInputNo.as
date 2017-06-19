package org.hy.common.ui.event
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import org.hy.common.Help;
	
	import spark.events.TextOperationEvent;
	
	
	
	/**
	 * 禁止文本框输入某些特殊字符。
	 * 
	 * 原本的 TextInput.restrict 属性也是可以做到禁止输入特殊字符的功能，如：
	 *    restrict="^\~\!\@\#\$\%\*\(\)\_\+\-\=\！\￥\…\[\]\'\^`\{\}\:\;\.\,\?/\\\|"
	 * 
	 * 1. 但，对于特殊字符 <、>、& 三个字符无法通过上面的方法做到禁止。因此有了本类。
	 * 
	 * 2. 同时，去除 “粘贴”功能中的字符串中有被禁止的内容，只“粘贴”允许的字符。
	 * 
	 * 3. 并且，用本类写特殊字符的形式也十分简单、十分的短，如：
	 *    new TextInputNo("~`!@#$%^&*()_+-={}[]:;,.<>/?'\"|\\");
	 * 
	 * 在使用时，须添加如下代码：
	 *    private var InputNo:TextInputNo = new TextInputNo("~`!@#$%^&*()_+-={}[]:;,.<>/?'\"|\\");
	 * 
	 *    <s:TextInput keyDown ="InputNo.keyDownHandler(event)" 
	 *                 changing="InputNo.changingHandler(event)"
	 *                 paste   ="InputNo.pasteHandler(event)" />
	 *
	 * @author      ZhengWei(HY)
	 * @createDate  2016-06-30
	 * @version     v1.0
	 */
	public class TextInputNo
	{
		
		/** 是否允许输入事件 */
		private var isAllowInputEvent:Boolean = true;
		
		/** 通过 this._noChars 属性解释出的Ascii码数组 */
		private var noCharsAsciis:Array       = null;
		
		/** 禁止输入的字符串 */
		private var _noChars:String;
		
		[Bindable]
		public function get noChars():String
		{
			return this._noChars;
		}
		
		public function set noChars(i_Value:String):void
		{
			this._noChars = i_Value;
			
			if ( Help.isNull(this._noChars) )
			{
				this.noCharsAsciis = null;
			}
			else
			{
				this.noCharsAsciis = Help.toAsciis(this._noChars);
			}
		}
		
		
		
		public function TextInputNo(i_NoChars:String)
		{
			this.noChars           = i_NoChars;
			this.isAllowInputEvent = true;
		}
		
		
		
		public function keyDownHandler(i_Event:KeyboardEvent):void
		{
			if ( !Help.isNull(this.noCharsAsciis) )
			{
				for each (var v_CharCode:Number in this.noCharsAsciis)
				{
					if ( v_CharCode == i_Event.charCode )
					{
						this.isAllowInputEvent = false;
						return;
					}
				}
			}
			
			this.isAllowInputEvent = true;
		}
		
		
		
		public function changingHandler(i_Event:TextOperationEvent):void
		{
			if ( !this.isAllowInputEvent )
			{
				this.isAllowInputEvent = true;
				i_Event.preventDefault();
			}
		}
		
		
		
		/**
		 * 去除 “粘贴”功能中的字符串中有被禁止的内容，只“粘贴”允许的字符。
		 */
		public function pasteHandler(i_Event:Event):void
		{
			var v_CopyText:String  = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
			var v_NewCopy:String   = new String(v_CopyText);
			var v_IsChange:Boolean = false;
			
			if ( !Help.isNull(this._noChars) )
			{
				for (var v_Index:int=0; v_Index<this._noChars.length; v_Index++)
				{
					var v_CharOne:String = this._noChars.charAt(v_Index);
					
					if ( v_CopyText.indexOf(v_CharOne) >= 0 )
					{
						v_NewCopy  = v_NewCopy.replace(v_CharOne ,"");
						v_IsChange = true;
					}
				}
			}
			
			if ( v_IsChange 
			  && null != i_Event.currentTarget
			  && i_Event.currentTarget.hasOwnProperty("text") )
			{
				i_Event.currentTarget.text = (i_Event.currentTarget.text as String).replace(v_CopyText ,v_NewCopy);
			}
		}

	}
}