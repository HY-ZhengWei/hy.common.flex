package org.hy.common
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.events.SyncEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
	import mx.binding.BindingManager;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.controls.ComboBox;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.core.Singleton;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.formatters.DateFormatter;
	import mx.graphics.ImageSnapshot;
	import mx.graphics.codec.IImageEncoder;
	import mx.graphics.codec.PNGEncoder;
	import mx.managers.PopUpManager;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	
	import org.hy.common.ui.TimerMessage;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.components.Button;
	import spark.components.ComboBox;
	import spark.components.Label;
	import spark.components.TextArea;
	import spark.components.TextInput;

	
	
	/**
	 * 编程的辅助类
	 * 
	 * @author  ZhengWei(HY)
	 * @version 1.0  2015-07-13
	 */
	public class Help
	{
		
		public function Help()
		{
			// 无法定义 private 类型的构造器，为了性能建议不要new则类。
		}
		
		
		
		/**
		 * 获取组件对象在屏幕上的绝对位置X
		 * 
		 * @param i_UI      组件对象
		 * 
		 * @version 1.0  2016-12-16
		 */
		public static function getX(i_UI:DisplayObject):Number
		{
			if ( i_UI != null )
			{
				return i_UI.x + getX(i_UI.parent);
			}
			else
			{
				return 0;
			}
		}
		
		
		
		/**
		 * 获取组件对象在屏幕上的绝对位置Y
		 * 
		 * @param i_UI      组件对象
		 * 
		 * @version 1.0  2016-12-16
		 */
		public static function getY(i_UI:DisplayObject):Number
		{
			if ( i_UI != null )
			{
				return i_UI.y + getY(i_UI.parent);
			}
			else
			{
				return 0;
			}
		}
		
		
		
		/**
		 * 在鼠标位置上显示一个定时自动关闭的消息（非模式窗口）
		 * 
		 * @param i_Info      消息
		 * @param i_ShowTime  显示时长(秒)
		 * @param i_Event     鼠标事件（如：按钮的点击事件等）
		 * 
		 * @version 1.0  2016-10-10
		 */
		public static function showMsgByMouse(i_Info:String ,i_ShowTime:uint ,i_Event:MouseEvent):TimerMessage
		{
			return Help.showMsg(i_Info ,i_ShowTime ,i_Event.currentTarget as DisplayObject ,i_Event.stageX ,i_Event.stageY);
		}
		
		
		
		/**
		 * 显示一个定时自动关闭的消息（非模式窗口）
		 * 
		 * @param i_Info      消息
		 * @param i_ShowTime  显示时长(秒)
		 * @param i_UI        容器对象
		 * @param i_X         显示位置x。如果为时，则为屏幕水平中心位置
		 * @param i_Y         显示位置y。如果为时，则为屏幕垂直中心位置
		 * 
		 * @version 1.0  2016-10-10
		 */
		public static function showMsg(i_Info:String ,i_ShowTime:uint ,i_UI:DisplayObject ,i_X:Number=-1 ,i_Y:Number=-1):TimerMessage
		{
			var v_TimerMessage:TimerMessage = new TimerMessage();
			
			v_TimerMessage.timeSecond = i_ShowTime;
			v_TimerMessage.message    = i_Info;
			
			PopUpManager.addPopUp(v_TimerMessage ,i_UI ,false);
			PopUpManager.centerPopUp(v_TimerMessage);
			
			if ( i_X == -1 )
			{
				// Capabilities.screenResolutionX / 2
				v_TimerMessage.x = getX(i_UI) + i_UI.width + 5;
			}
			else if ( i_X >= 0 )
			{
				v_TimerMessage.x = i_X;
			}
			
			if ( i_Y == -1 )
			{
				v_TimerMessage.y = getY(i_UI);
			}
			else if ( i_Y >= 0 )
			{
				v_TimerMessage.y = i_Y;
			}
			
			return v_TimerMessage;
		}
		
		
		
		/**
		 * 截图。根据 i_Source 对象的大小自动生成图片大小
		 * 
		 * 方法的返回结果，只要通过下面实例代码就可以保存了。
		 *    (new FileReference()).save(Help.screenShot(this), "文件名称.png");
		 * 
		 * 当然，如果你加了scroller,不管用bitmapdata还是ImageSnapshot，都只能抓到显示区域的内容了。
		 * 但，可以通过scroller中的第二层Group组件为入参，获取全部区域的内容(包括非显示的区域)。
		 * 
		 * @param i_Source      截图的数据源。可以是任一组件对象。如 this
		 * @param i_ImgEncoder  截图的数据格式。默认为：png 格式
		 * 
		 * @version 1.0  2016-11-24
		 */
		public static function screenShot(i_Source:IBitmapDrawable ,i_ImgEncoder:IImageEncoder=null):ByteArray
		{
			var v_BitmapData:BitmapData     = screenShotBitmapData(i_Source);
			var v_ImgEncoder:IImageEncoder  = i_ImgEncoder == null ? new PNGEncoder() : i_ImgEncoder;
			var v_BitmapDataBytes:ByteArray = v_ImgEncoder.encode(v_BitmapData);
			
			// 方法二
			/*
			var v_ImageSnapshot:ImageSnapshot = ImageSnapshot.captureImage(i_Source ,0 ,i_ImgEncoder);
			var v_BitmapDataBytes:ByteArray   = v_ImageSnapshot.data;
			*/
			
			return v_BitmapDataBytes;
		}
		
		
		
		/**
		 * 截图。根据 i_Source 对象的大小自动生成图片大小
		 * 
		 * 方法的返回结果，只要通过下面实例代码就可以保存了。
		 *    (new FileReference()).save(Help.screenShot(this), "文件名称.png");
		 * 
		 * 当然，如果你加了scroller,不管用bitmapdata还是ImageSnapshot，都只能抓到显示区域的内容了。
		 * 但，可以通过scroller中的第二层Group组件为入参，获取全部区域的内容(包括非显示的区域)。
		 * 
		 * @param i_Source      截图的数据源。可以是任一组件对象。如 this
		 * 
		 * @version 1.0  2016-12-19
		 */
		public static function screenShotBitmapData(i_Source:IBitmapDrawable):BitmapData
		{
			return ImageSnapshot.captureBitmapData(i_Source);
		}
		
		
		
		/** 上下组合 */
		public static const $ScreenShots_TopBottom:String   = "ScreenShots_TopBottom";
		
		/** 左右组合 */
		public static const $ScreenShots_LeftRight:String   = "ScreenShots_LeftRight";
		
		/** 第二张图重叠放在第一张图的左上角 */
		public static const $ScreenShots_TopLeft:String     = "ScreenShots_TopLeft";
		
		/** 第二张图重叠放在第一张图的右上角 */
		public static const $ScreenShots_TopRight:String    = "ScreenShots_TopRight";
		
		/** 第二张图重叠放在第一张图的左下角 */
		public static const $ScreenShots_BottomLeft:String  = "ScreenShots_BottomLeft";
		
		/** 第二张图重叠放在第一张图的右下角 */
		public static const $ScreenShots_BottomRight:String = "ScreenShots_BottomRight";
		
		
		
		/**
		 * 合组两张截图为一张图片。根据 i_Source01 和 i_Source02 两对象的组合类型的自动生成图片大小
		 * 
		 * 方法的返回结果，只要通过下面实例代码就可以保存了。
		 *    (new FileReference()).save(Help.screenShot(this), "文件名称.png");
		 * 
		 * 当然，如果你加了scroller,不管用bitmapdata还是ImageSnapshot，都只能抓到显示区域的内容了。
		 * 但，可以通过scroller中的第二层Group组件为入参，获取全部区域的内容(包括非显示的区域)。
		 * 
		 * @param i_Source01    截图的数据源01。可以是任一组件对象。如 this
		 * @param i_Source02    截图的数据源02。可以是任一组件对象。如 this
		 * @param i_GroupType   合组类型。默认为上下组合。
		 * @param i_Transparent 是否背景透明。默认为透明
		 * 
		 * @version 1.0  2016-11-25
		 */
		public static function screenShotsBitmapData(i_Source01:IBitmapDrawable ,i_Source02:IBitmapDrawable ,i_GroupType:String=$ScreenShots_TopBottom ,i_Transparent:Boolean=true):BitmapData
		{
			var v_BitmapData01:BitmapData = ImageSnapshot.captureBitmapData(i_Source01);
			var v_BitmapData02:BitmapData = ImageSnapshot.captureBitmapData(i_Source02);
			var v_Widths:int              = 0;   // 组合后图片的宽度
			var v_Heights:int             = 0;   // 组合后图片的高度
			var v_X02:int                 = 0;   // 第二张小图片的组合填充X坐标
			var v_Y02:int                 = 0;   // 第二张小图片的组合填充Y坐标
			
			if ( i_GroupType == $ScreenShots_TopBottom )
			{
				v_Widths  = Math.max(v_BitmapData01.width ,v_BitmapData02.width);
				v_Heights = v_BitmapData01.height + v_BitmapData02.height;
				v_X02     = 0;
				v_Y02     = v_Heights - v_BitmapData02.height;
			}
			else if ( i_GroupType == $ScreenShots_LeftRight )
			{
				v_Widths  = v_BitmapData01.width + v_BitmapData02.width;
				v_Heights = Math.max(v_BitmapData01.height ,v_BitmapData02.height);
				v_X02     = v_Widths - v_BitmapData02.width;
				v_Y02     = 0;
			}
			else if ( i_GroupType == $ScreenShots_TopLeft )
			{
				v_Widths  = v_BitmapData01.width;
				v_Heights = v_BitmapData01.height;
				v_X02     = 0;
				v_Y02     = 0;
			}
			else if ( i_GroupType == $ScreenShots_TopRight )
			{
				v_Widths  = v_BitmapData01.width;
				v_Heights = v_BitmapData01.height;
				v_X02     = v_BitmapData01.width - v_BitmapData02.width;
				v_Y02     = 0;
			}
			else if ( i_GroupType == $ScreenShots_BottomLeft )
			{
				v_Widths  = v_BitmapData01.width;
				v_Heights = v_BitmapData01.height;
				v_X02     = 0;
				v_Y02     = v_BitmapData01.height - v_BitmapData02.height;
			}
			else if ( i_GroupType == $ScreenShots_BottomRight )
			{
				v_Widths  = v_BitmapData01.width;
				v_Heights = v_BitmapData01.height;
				v_X02     = v_BitmapData01.width  - v_BitmapData02.width;
				v_Y02     = v_BitmapData01.height - v_BitmapData02.height;
			}
			else
			{
				return null;
			}
			
			// 创建背景
			var v_BitmapDatas:BitmapData = new BitmapData(v_Widths ,v_Heights ,i_Transparent ,i_Transparent ? 0 : 0xFFFFFFFF);
			
			// 填充第一张图片
			v_BitmapDatas.draw(v_BitmapData01);
			
			// 填充第二张图片
			var v_Matrix02:Matrix = new Matrix(1 ,0 ,0, 1 ,v_X02 ,v_Y02);
			v_BitmapDatas.draw(v_BitmapData02 ,v_Matrix02);
			
			return v_BitmapDatas;
		}
		
		
		/**
		 * 合组两张截图为一张图片。根据 i_Source01 和 i_Source02 两对象的组合类型的自动生成图片大小
		 * 
		 * 方法的返回结果，只要通过下面实例代码就可以保存了。
		 *    (new FileReference()).save(Help.screenShot(this), "文件名称.png");
		 * 
		 * 当然，如果你加了scroller,不管用bitmapdata还是ImageSnapshot，都只能抓到显示区域的内容了。
		 * 但，可以通过scroller中的第二层Group组件为入参，获取全部区域的内容(包括非显示的区域)。
		 * 
		 * @param i_Source01    截图的数据源01。可以是任一组件对象。如 this
		 * @param i_Source02    截图的数据源02。可以是任一组件对象。如 this
		 * @param i_GroupType   合组类型。默认为上下组合。
		 * @param i_Transparent 是否背景透明。默认为透明
		 * @param i_ImgEncoder  截图的数据格式。默认为：png 格式
		 * 
		 * @version 1.0  2016-11-25
		 */
		public static function screenShots(i_Source01:IBitmapDrawable ,i_Source02:IBitmapDrawable ,i_GroupType:String=$ScreenShots_TopBottom ,i_Transparent:Boolean=true ,i_ImgEncoder:IImageEncoder=null):ByteArray
		{
			var v_BitmapDatas:BitmapData    = screenShotsBitmapData(i_Source01 ,i_Source02 ,i_GroupType ,i_Transparent);
			var v_ImgEncoder:IImageEncoder  = i_ImgEncoder == null ? new PNGEncoder() : i_ImgEncoder;
			var v_BitmapDataBytes:ByteArray = v_ImgEncoder.encode(v_BitmapDatas);
			
			return v_BitmapDataBytes;
		}
		
		
		
		public static var v_RightMenuCopy:ContextMenu;  // 右键菜单
		
		/**
		 * 获取右键复制功能的菜单
		 * 
		 * @version 1.0  2016-11-11
		 */
		public static function getContextMenuCopy():ContextMenu
		{
			if ( v_RightMenuCopy == null )
			{
				v_RightMenuCopy = new ContextMenu();
				
				var v_MenuCopy:ContextMenuItem = new ContextMenuItem("复制文本");
				v_MenuCopy.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT ,menuCopy_Handler);
				
				var v_RightMenuCopy:ContextMenu = new ContextMenu();  // 创建右键菜单
				v_RightMenuCopy.hideBuiltInItems();                   // 隐藏内置菜单
				v_RightMenuCopy.customItems.push(v_MenuCopy);
			}
			
			return v_RightMenuCopy;
		}
		
		/**
		 * 右键菜单中“复制”菜单的点击事件
		 * 
		 * @version 1.0  2016-11-11
		 */
		private static function menuCopy_Handler(i_Event:ContextMenuEvent):void 
		{
			var v_Value:String = null;
			
			if ( i_Event.contextMenuOwner is spark.components.Label )
			{
				v_Value = (i_Event.contextMenuOwner as spark.components.Label).text;
			}
			else if ( i_Event.contextMenuOwner is mx.controls.Label )
			{
				v_Value = (i_Event.contextMenuOwner as mx.controls.Label).text;
			}
			else if ( i_Event.contextMenuOwner is spark.components.TextInput )
			{
				v_Value = (i_Event.contextMenuOwner as spark.components.TextInput).text;
			}
			else if ( i_Event.contextMenuOwner is mx.controls.TextInput )
			{
				v_Value = (i_Event.contextMenuOwner as mx.controls.TextInput).text;
			}
			else if ( i_Event.contextMenuOwner is spark.components.TextArea )
			{
				v_Value = (i_Event.contextMenuOwner as spark.components.TextArea).text;
			}
			else if ( i_Event.contextMenuOwner is mx.controls.TextArea )
			{
				v_Value = (i_Event.contextMenuOwner as mx.controls.TextArea).text;
			}
			else if ( i_Event.contextMenuOwner is spark.components.Button )
			{
				v_Value = (i_Event.contextMenuOwner as spark.components.Button).label;
			}
			else if ( i_Event.contextMenuOwner is mx.controls.Button )
			{
				v_Value = (i_Event.contextMenuOwner as mx.controls.Button).label;
			}
			else if ( i_Event.contextMenuOwner is spark.components.ComboBox )
			{
				v_Value = (i_Event.contextMenuOwner as spark.components.ComboBox).textInput.text;
			}
			else if ( i_Event.contextMenuOwner is mx.controls.ComboBox )
			{
				v_Value = (i_Event.contextMenuOwner as mx.controls.ComboBox).text;
			}
			
			if ( !Help.isNull(v_Value) )
			{
				System.setClipboard(v_Value);
			}
		}
		
		
		
		/**
		 * 去除前、后空格
		 */
		public static function trim(i_Value:String):String
		{
			return StringUtil.trim(i_Value);
		}
		
		
		
		/**
		 * 判断对象是否为空
		 * 
		 * @param i_Value    1. 当为String类型时         ，值是空字符或null时，返回 true
		 *                   2. 当为ArrayCollection类型时，值是空集合或null时，返回 true
		 *                   3. 当为Array类型时          ，值是空数组或null时，返回 true
		 *                   4. 其它类型时               ，值为null时       ，返回 true
		 */
		public static function isNull(i_Value:*):Boolean
		{
			if ( i_Value == null )
			{
				return true;
			}
			else if ( i_Value is String )
			{
				if ( i_Value == null || "" == StringUtil.trim(i_Value as String) )
				{
					return true;
				}
			}
			else if ( i_Value is ArrayCollection )
			{
				if ( i_Value == null || (i_Value as ArrayCollection).length == 0 )
				{
					return true;
				}
			}
			else if ( i_Value is Array )
			{
				if ( i_Value == null || (i_Value as Array).length == 0 )
				{
					return true;
				}
			}
			
			return false;
		}
		
				
		
		/**
		 * 模拟于Oracle中的 NVL() 函数
		 *
		 * @param i_Value    1. 当为String类型时         ，值是空字符或null时，返回默认值 (默认值也为null，时返回空字符)
		 *                   2. 当为ArrayCollection类型时，值是空集合或null时，返回默认值 (默认值也为null，时返回空集合)
		 *                   3. 当为Array类型时          ，值是空数组或null时，返回默认值 (默认值也为null，时返回空数组)
		 *                   4. 其它类型时               ，值为null时       ，返回默认值 (默认值也为null，时返回new Object)
		 * @param i_Default  默认值
		 * @return 
		 */
		public static function NVL(i_Value:* ,i_Default:*=null):*
		{
			if ( i_Value is String )
			{
				if ( i_Value == null || "" == StringUtil.trim(i_Value as String) )
				{
					return i_Default == null ? "" : i_Default
				}
			}
			else if ( i_Value is ArrayCollection )
			{
				if ( i_Value == null || (i_Value as ArrayCollection).length == 0 )
				{
					return i_Default == null ? new ArrayCollection() : i_Default
				}
			}
			else if ( i_Value is Array )
			{
				if ( i_Value == null || (i_Value as Array).length == 0 )
				{
					return i_Default == null ? new Array() : i_Default
				}
			}
			else if ( i_Value == null )
			{
				return i_Default == null ? new Object() : i_Default;
			}
			
			return i_Value;
		}
		
		
		
		/**
		 * 转码为Base64编码字符
		 * 
		 * @version 1.0  2016-12-19
		 */
		public static function toBase64Encoder(i_Datas:Object):String
		{
			if ( i_Datas == null )
			{
				return null;
			}
			
			var v_Encode:Base64Encoder = new Base64Encoder();
			
			if ( i_Datas is String )
			{
				v_Encode.encode(i_Datas as String);
			}
			else if ( i_Datas is ByteArray )
			{
				v_Encode.encodeBytes(i_Datas as ByteArray);
			}
			else
			{
				return null;
			}
			
			return v_Encode.toString();
		}
		
		
		
		/**
		 * Base64编码字符转码为普通字符
		 * 
		 * @version 1.0  2016-12-19
		 */
		public static function toBase64Decoder(i_Datas:String):ByteArray
		{
			if ( i_Datas == null )
			{
				return null;
			}
			
			var v_Decoder:Base64Decoder = new Base64Decoder();
			
			v_Decoder.decode(i_Datas);
			
			return v_Decoder.toByteArray();
		}
		
		
		
		/**
		 * 单字符转为Ascii码，返回结果为10进行数字
		 * 
		 * @param i_CharOne    单字符
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2016-06-30
		 */
		public static function toAscii(i_CharOne:String):Number
		{
			return i_CharOne.charCodeAt(0);
		}
		
		
		
		/**
		 * 字符串转为一组Ascii码，返回结果为10进行数字
		 * 
		 * @param i_Value    字符串
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2016-06-30
		 */
		public static function toAsciis(i_Value:String):Array
		{
			var v_Ret:Array = new Array();
			
			if ( !Help.isNull(i_Value) )
			{
				for (var v_Index:int=0; v_Index<i_Value.length; v_Index++)
				{
					v_Ret.push(i_Value.charCodeAt(v_Index));
				}
			}
			
			return v_Ret;
		}
		
		
		
		/**
		 * 判断字符是否为数字。
		 * 
		 * 如："2016ABC" ，parseFloat("2016ABC") = 2016;  也不会出错，这本身就是一个问题。
		 * 
		 * @param i_Value    字符数字
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2016-04-06
		 */
		public static function isNumber(i_Value:String):Boolean
		{
			var v_Num:Number = Number(i_Value);
			
			return !isNaN(v_Num);
		}
		
		
		
		/**
		 * 字符转数字（为了好记方便，并无特别操作）
		 * 
		 * @param i_Value    字符数字
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2016-04-06
		 */
		public static function toNumber(i_Value:String):Number
		{
			if ( isNumber(i_Value) )
			{
				return parseFloat(i_Value);
			}
			else
			{
				return NaN;
			}
		}
		
		
		
		/**
		 * 替代Flex自身的 toFixed(...)方法，因此方法有四舍五入方面的问题（详见Help.round(...)）
		 * 
		 * @param i_Num
		 * @param i_Digit   保留小数位数
		 * @return
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2017-06-16
		 */
		public static function toFixed(i_Num:Number ,i_Digit:uint):String
		{
			var v_Num:Number = round(i_Num ,i_Digit);
			
			if ( isNaN(v_Num) )
			{
				return NaN.toString();
			}
			else
			{
				return v_Num.toFixed(i_Digit);
			}
		}
		
		
		
		/**
		 * 四舍五入。
		 * 
		 * 参见于Help.java类中的round(...)方法编写的
		 * 
		 * 解决Flex本身无法完全处理四舍五入的问题，如下的情况
		 *    1. 0.00005.toFixed(3) = 0.001
		 *    2. 0.00005.toFixed(4) = 0.001
		 * 
		 * @param i_Num
		 * @param i_Digit   保留小数位数
		 * @return
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2017-06-16
		 */
		public static function round(i_Num:Number ,i_Digit:uint):Number
		{
			if ( isNaN(i_Num) )
			{
				return NaN;
			}
			else if ( i_Num == 0 )
			{
				return 0;
			}
			
			var v_Pow     :Number = Math.pow(10 ,i_Digit);
			var v_Big     :Number = i_Num * v_Pow;
			var v_Small   :Number = Math.floor(v_Big);
			var v_Subtract:Number = v_Big - v_Small;
			
			if ( v_Subtract >= 0.5 )
			{
				v_Small = v_Small + 1;
			}
			
			v_Small = v_Small / v_Pow;
			
			return v_Small;
		}
		
		
		
		/**
		 * 科学计数
		 * 
		 * Number.toExponential(...) 也是科学计数法
		 * 
		 * @param i_Num              数字
		 * @param i_Decimal          多少位的小数启用科学计数
		 * @param i_RoundScientific  如果启用了科学计数后，科学计数的显示小数位数（四舍五入）
		 * @param i_Round            未启用科学计数时，对数字i_Num的四舍五入。
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2016-08-30
		 */
		public static function toScientificNotation(i_Num:Number ,i_Decimal:uint ,i_RoundScientific:uint ,i_Round:uint=9):String
		{
			if ( isNaN(i_Num) )
			{
				return ""; 
			}
			
			if ( 1 > i_Num && i_Num > -1 && i_Num != 0 )
			{
				var v_Num:Number   = i_Num;
				var v_Decimal:uint = 0;
				
				do
				{
					v_Num = v_Num * 10;
					v_Decimal++;
				}
				while ( 1 > v_Num && v_Num > -1 );
				
				if ( v_Decimal >= i_Decimal )
				{
					return v_Num.toFixed(i_RoundScientific) + "E-" + v_Decimal.toString();
				}
			}
			
			var v_RetOrigi:String = i_Num.toString();
			var v_RetFixed:String = i_Num.toFixed(i_Round);
			return v_RetOrigi.length <= v_RetFixed.length ? v_RetOrigi : v_RetFixed;
		}
		
		
		
		/**
		 * 字符串填充
		 * 
		 * 参见于StringHelp.java类中的pad(...)方法编写的
		 * 
		 * @param i_Str          原始字符串
		 * @param i_TotalLength  填充后的总长度
		 * @param i_PadStr       填充的字符串
		 * @return
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2017-06-20
		 */
		public static function lpad(i_Value:* ,i_TotalLength:uint ,i_PadStr:String):String
		{
			return pad(i_Value ,i_TotalLength ,i_PadStr ,-1);
		}
		
		
		
		/**
		 * 字符串填充
		 * 
		 * 参见于StringHelp.java类中的pad(...)方法编写的
		 * 
		 * @param i_Str          原始字符串
		 * @param i_TotalLength  填充后的总长度
		 * @param i_PadStr       填充的字符串
		 * @return
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2017-06-20
		 */
		public static function rpad(i_Value:* ,i_TotalLength:uint ,i_PadStr:String):String
		{
			return pad(i_Value ,i_TotalLength ,i_PadStr ,1);
		}
			
		
		
		/**
		 * 字符串填充
		 * 
		 * 参见于StringHelp.java类中的pad(...)方法编写的
		 * 
		 * @param i_Str          原始字符串
		 * @param i_TotalLength  填充后的总长度
		 * @param i_PadStr       填充的字符串
		 * @param i_Way          填充方向。小于0，左则填充；大于0，右则填充
		 * @return
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2017-06-20
		 */
		public static function pad(i_Value:* ,i_TotalLength:uint ,i_PadStr:String ,i_Way:int):String
		{
			var v_Str:String = "";
			
			if ( i_Value == null )
			{
				return null;
			}
			else if ( i_Value is String )
			{
				v_Str = i_Value as String;
			}
			else
			{
				v_Str = i_Value.toString();
			}
			
			var v_Len:int  = v_Str.length;
			var v_Buffer:String = "";
			
			if ( i_Way >= 0 )
			{
				v_Buffer += v_Str;
			}
			
			for (var i:int=0; i<i_TotalLength-v_Len; i++)
			{
				v_Buffer += i_PadStr;
			}
			
			if ( i_Way < 0 )
			{
				v_Buffer += v_Str;
			}
			
			return v_Buffer;
		}
		
		
		
		
		
		
		
		/**
		 * 时间比较
		 */
		public static function toCompare(i_Date1:Date ,i_Date2:Date):int
		{
			return ObjectUtil.dateCompare(i_Date1 ,i_Date2);
		}
		
		
		
		/**
		 * 字符转时间
		 */
		public static function toDate(i_Value:String):Date
		{
			return DateFormatter.parseDateString(i_Value);
		}
		
		
		
		/**
		 * 获取访问地址（浏览器地址栏的内容）
		 * 
		 * 在某些特殊情况下（如VPN登陆内网），通过Java后台服务器获取的访问地址，与此方法获取的地址是不一样的。
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2016-05-11
		 */
		public static function getHttpURL():String
		{
			return ExternalInterface.call('window.location.href.toString');
		}
		
		
		
		/**
		 * 时间转为格式化字符
		 */
		public static function getDateFormatter(i_Date:Date=null ,i_Formatter:String="YYYY-MM-DD HH:NN:SS"):String
		{
			var v_DateFormatter:DateFormatter = new DateFormatter();
			v_DateFormatter.formatString = i_Formatter;
			
			return v_DateFormatter.format((i_Date == null ? new Date() :i_Date));
		}
		
		
		
		/**
		 * 获取 YYYY-MM-DD HH:MI:SS 格式的字符
		 * 
		 * @return
		 */
		public static function getDateFull(i_Date:Date=null):String
		{
			return getDateFormatter(i_Date ,"YYYY-MM-DD HH:NN:SS")
		}
		
		
		
		/**
		 * 获取 YYYYMMDDHHMISS 格式的字符
		 * 
		 * @return
		 */
		public static function getDateFull_ID(i_Date:Date=null):String
		{
			return getDateFormatter(i_Date ,"YYYYMMDDHHNNSS");
		}
		
		
		
		/**
		 * 获取 YYYY-MM-DD HH:MI:SS.QQQ 格式的字符
		 * 
		 * @return
		 */
		public static function getDateFullMilli(i_Date:Date=null):String
		{
			return getDateFormatter(i_Date ,"YYYY-MM-DD HH:NN:SS.QQQ")
		}
		
		
		
		/**
		 * 获取 YYYYMMDDHHMI 格式的字符
		 * 
		 * @return
		 */
		public static function getDateYMDHMI_ID(i_Date:Date=null):String
		{
			return getDateFormatter(i_Date ,"YYYYMMDDHHNN");
		}
		
		
		
		/**
		 * 获取 YYYY-MM-DD HH:MI 格式的字符
		 * 
		 * @return
		 */
		public static function getDateYMDHMI(i_Date:Date=null):String
		{
			return getDateFormatter(i_Date ,"YYYY-MM-DD HH:NN")
		}
		
		
		
		/**
		 * 获取 YYYYMMDDHHMISSQQQ 格式的字符
		 * 
		 * @return
		 */
		public static function getDateFullMilli_ID(i_Date:Date=null):String
		{
			return getDateFormatter(i_Date ,"YYYYMMDDHHNNSSQQQ");
		}
		
		
		
		/**
		 * 获取 YYYY-MM-DD 格式的字符
		 * 
		 * @return
		 */
		public static function getDateYMD(i_Date:Date=null):String
		{
			return getDateFormatter(i_Date ,"YYYY-MM-DD");
		}
		
		
		
		/**
		 * 获取 YYYYMMDD 格式的字符
		 * 
		 * @return
		 */
		public static function getDateYMD_ID(i_Date:Date=null):String
		{
			return getDateFormatter(i_Date ,"YYYYMMDD");
		}
		
		
		
		/**
		 * 获取 HH:MI:SS 格式的字符
		 * 
		 * @return
		 */
		public static function getDateHHMISS(i_Date:Date=null):String
		{
			return getDateFormatter(i_Date ,"HH:NN:SS");
		}
		
		
		
		/**
		 * 获取 HHMISS 格式的字符
		 * 
		 * @return
		 */
		public static function getDateHHMISS_ID(i_Date:Date=null):String
		{
			return getDateFormatter(i_Date ,"HHNNSS");
		}
		
		
		
		/**
		 * 复制对象（为了好记方便，并无特别操作）
		 * 
		 * @param i_Source    原始对象
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2015-12-03
		 */
		public static function copyObj(i_Source:Object):Object
		{
			return ObjectUtil.copy(i_Source);
		}
		
		
		
		/**
		 * 克隆对象（为了好记方便，并无特别操作）
		 * 
		 * ObjectUtil.clone() 与 ObjectUtil.copy() 的不同之处在于：每个对象实例的 uid 属性 ObjectUtil.clone() 方法会被保留。
		 * 
		 * @param i_Source    原始对象
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2015-12-03
		 */
		public static function cloneObj(i_Source:Object):Object
		{
			return ObjectUtil.clone(i_Source);
		}
		
		
		
		/**
		 * 克隆集合元素，使其相同索引号对应的元素完全一样，多出的元素删除。
		 * 
		 * 1. 原始集合元素个数 <= 目标集合元素个数时，目标集合中多出的元素将被删除。
		 * 2. 原始集合元素个数 >  目标集合元素个数时，原始集合中多出的元素添加到目标集合中。
		 * 
		 * @param i_Source    原始集合
		 * @param io_Target   目标被添加新元素的集合
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2015-09-19
		 */
		public static function clone(i_Source:IList ,io_Target:IList):void
		{
			if ( i_Source == null || io_Target == null || i_Source.length <= 0 )
			{
				return;
			}
			
			var x:int           = 0;
			var v_TargetLen:int = io_Target.length;
			
			if ( i_Source.length <= v_TargetLen )
			{
				for (; x<i_Source.length; x++)
				{
					io_Target.setItemAt(i_Source.getItemAt(x) ,x);
				}
				
				for (x=v_TargetLen-1; x>i_Source.length-1; x--)
				{
					io_Target.removeItemAt(x);
				}
			}
			else
			{
				for (; x<v_TargetLen; x++)
				{
					io_Target.setItemAt(i_Source.getItemAt(x) ,x);
				}
				
				for (; x<i_Source.length; x++)
				{
					io_Target.addItem(i_Source.getItemAt(x));
				}
			}
		}
		
		
		
		/**
		 * 拷贝集合元素，使其相同索引号对应的元素完全一样，但多出的元素是不变的。
		 * 
		 * 1. 原始集合元素个数 <= 目标集合元素个数时，目标集合中多出的元素不变。
		 * 2. 原始集合元素个数 >  目标集合元素个数时，原始集合中多出的元素添加到目标集合中。
		 * 
		 * @param i_Source    原始集合
		 * @param io_Target   目标被添加新元素的集合
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2015-09-19
		 */
		public static function copy(i_Source:IList ,io_Target:IList):void
		{
			if ( i_Source == null || io_Target == null || i_Source.length <= 0 )
			{
				return;
			}
			
			var x:int           = 0;
			var v_TargetLen:int = io_Target.length;
			
			if ( i_Source.length <= v_TargetLen )
			{
				for (; x<i_Source.length; x++)
				{
					io_Target.setItemAt(i_Source.getItemAt(x) ,x);
				}
			}
			else
			{
				for (; x<v_TargetLen; x++)
				{
					io_Target.setItemAt(i_Source.getItemAt(x) ,x);
				}
				
				for (; x<i_Source.length; x++)
				{
					io_Target.addItem(i_Source.getItemAt(x));
				}
			}
		}
		
		
		
		/**
		 * 将一个集合的所有元素添加到另一个集合元素中(向目标集合的后面追加元素)
		 * 
		 * @param i_Source    原始集合
		 * @param io_Target   目标被添加新元素的集合
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2015-09-19
		 */
		public static function addAll(i_Source:IList ,io_Target:IList):void
		{
			if ( i_Source == null || io_Target == null || i_Source.length <= 0 )
			{
				return;
			}
			
			for (var x:int=0; x<=i_Source.length; x++)
			{
				io_Target.addItem(i_Source.getItemAt(x));
			}
		}
		
		
		
		/**
		 * 设置一个组件对象是否启显示
		 * 
		 * @param i_UI        组件对象
		 * @param i_Visible   是否显示
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2016-11-30
		 */
		public static function setVisible(i_UI:UIComponent ,i_Visible:Boolean=true):void
		{
			i_UI.visible         = i_Visible;
			i_UI.includeInLayout = i_Visible;
		}
		
		
		
		/**
		 * 设置一个组件对象是否启用按钮模式
		 * 
		 * @param i_UI        组件对象
		 * @param i_Enabled   是否启用
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2016-06-16
		 */
		public static function setButtonEnabled(i_UI:UIComponent ,i_Enabled:Boolean=true):void
		{
			if ( i_UI == null )
			{
				return;
			}
			
			i_UI.enabled            = i_Enabled;
			i_UI.buttonMode         = i_Enabled;
			i_UI.doubleClickEnabled = i_Enabled;
			i_UI.mouseEnabled       = i_Enabled;
			i_UI.mouseChildren      = i_Enabled;
			i_UI.validateNow();
			i_UI.validateDisplayList();
			
		}
		
		
		
		/**
		 * 通用的，设置下拉列表框不可编辑，只能选取既定的选项。
		 * 
		 * 使用方法：<s:ComboBox initialize="Help.setComboBoxReadOnly(event)" />
		 * 
		 * @param i_Event       事件对象
		 * 
		 * @version 1.0  2016-06-15
		 */
		public static function setComboBoxReadOnly(i_Event:FlexEvent):void
		{
			if ( i_Event.currentTarget is spark.components.ComboBox)
			{
				var v_UI01:spark.components.ComboBox = (i_Event.currentTarget as spark.components.ComboBox);
				
				if ( v_UI01.textInput != null )
				{
					v_UI01.textInput.editable = false;
				}
			}
			else if ( i_Event.currentTarget is mx.controls.ComboBox )
			{
				var v_UI02:mx.controls.ComboBox = (i_Event.currentTarget as mx.controls.ComboBox);
				
				v_UI02.editable = false;
			}
		}
		
		
		
		/**
		 * 通用的，设置下拉列表框不可编辑，只能选取既定的选项。
		 * 
		 * @param i_UI       下拉列表对象
		 * 
		 * @version 1.0  2016-09-28
		 */
		public static function setComboBoxReadOnlyUI(i_UI:UIComponent):void
		{
			if ( i_UI is spark.components.ComboBox)
			{
				var v_UI01:spark.components.ComboBox = (i_UI as spark.components.ComboBox);
				
				if ( v_UI01.textInput != null )
				{
					v_UI01.textInput.editable = false;
				}
			}
			else if ( i_UI is mx.controls.ComboBox )
			{
				var v_UI02:mx.controls.ComboBox = (i_UI as mx.controls.ComboBox);
				
				v_UI02.editable = false;
			}
		}
		
		
		
		/**
		 * 获取下拉列表框选中或输入的数值
		 * 
		 * @param i_UI          下拉列表对象
		 * @param i_ValueField  当下拉列表绑定数据源是一个对象时，只获取对象某个属性名(i_ValueField)对应的数值。
		 * 
		 * @version 1.0  2016-09-29
		 */
		public static function getComboBoxValue(i_UI:UIComponent ,i_ValueField:String):String
		{
			if ( i_UI is spark.components.ComboBox)
			{
				var v_UI01:spark.components.ComboBox = (i_UI as spark.components.ComboBox);
				
				if ( v_UI01.selectedItem == null )
				{
					if ( v_UI01.textInput != null )
					{
						return Help.NVL(v_UI01.textInput.text ,"");
					}
					else
					{
						return "";
					}
				}
				else if ( Help.isNull(i_ValueField)
					   || v_UI01.selectedItem is String
					   || !(v_UI01.selectedItem as Object).hasOwnProperty(i_ValueField) )
				{
					return v_UI01.selectedItem as String;
				}
				else
				{
					return v_UI01.selectedItem[i_ValueField] as String;
				}
			}
			else if ( i_UI is mx.controls.ComboBox )
			{
				var v_UI02:mx.controls.ComboBox = (i_UI as mx.controls.ComboBox);
				
				if ( v_UI02.selectedItem == null )
				{
					return Help.NVL(v_UI02.text ,"");
				}
				else if ( Help.isNull(i_ValueField)
					   || v_UI02.selectedItem is String
					   || !(v_UI02.selectedItem as Object).hasOwnProperty(i_ValueField) )
				{
					return v_UI02.selectedItem as String;
				}
				else
				{
					return v_UI02.selectedItem[i_ValueField] as String;
				}
			}
			else
			{
				return "";
			}
		}
		
		
		
		/**
		 * 为下拉表框设置选中项。
		 * 
		 * @param io_ComboBox  下拉列表框对象
		 * @param i_Value      即将被设置为选中项的值
		 * @return             返回选中项的索引号
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2015-12-01
		 */
		public static function setSelectedItem(io_ComboBox:spark.components.ComboBox ,i_Value:Object):int
		{
			if ( io_ComboBox == null )
			{
				return -1;
			}
			
			if ( i_Value == null )
			{
				io_ComboBox.selectedIndex = -1;
				if ( io_ComboBox.textInput != null )
				{
					io_ComboBox.textInput.text = "";
				}
				return -1;
			}
			
			var v_Index:int        = 0;
			var v_ItemValue:Object = null;
			
			if ( Help.isNull(io_ComboBox.dataProvider) )
			{
				io_ComboBox.selectedIndex = -1;
				if ( io_ComboBox.textInput != null )
				{
					if ( i_Value is String )
					{
						io_ComboBox.textInput.text = i_Value as String;
					}
					else if ( Help.isNull(io_ComboBox.labelField) )
					{
						io_ComboBox.textInput.text = i_Value.toString();
					}
					else if ( i_Value.hasOwnProperty(io_ComboBox.labelField) )
					{
						io_ComboBox.textInput.text = i_Value[io_ComboBox.labelField];
					}
					else
					{
						io_ComboBox.textInput.text = i_Value.toString();
					}
				}
				
				return -1;
			}
			else
			{
				if ( i_Value is String )
				{
					if ( Help.isNull(io_ComboBox.labelField) )
					{
						for (v_Index=0; v_Index<io_ComboBox.dataProvider; v_Index++)
						{
							if ( i_Value == io_ComboBox.dataProvider.getItemAt(v_Index) )
							{
								io_ComboBox.selectedIndex = v_Index;
								if ( io_ComboBox.textInput != null )
								{
									io_ComboBox.textInput.text = i_Value as String;
								}
								return v_Index;
							}
						}
					}
					else
					{
						for (v_Index=0; v_Index<io_ComboBox.dataProvider; v_Index++)
						{
							v_ItemValue = io_ComboBox.dataProvider.getItemAt(v_Index);
							
							if ( v_ItemValue != null && v_ItemValue.hasOwnProperty(io_ComboBox.labelField) )
							{
								if ( i_Value == v_ItemValue[io_ComboBox.labelField] )
								{
									io_ComboBox.selectedIndex = v_Index;
									if ( io_ComboBox.textInput != null )
									{
										io_ComboBox.textInput.text = v_ItemValue[io_ComboBox.labelField].toString();
									}
									return v_Index;
								}
							}
						}
					}
				}
				else
				{
					if ( Help.isNull(io_ComboBox.labelField) )
					{
						var v_ValueString:String = i_Value.toString();
						
						for (v_Index=0; v_Index<io_ComboBox.dataProvider; v_Index++)
						{
							if ( v_ValueString == io_ComboBox.dataProvider.getItemAt(v_Index) )
							{
								io_ComboBox.selectedIndex = v_Index;
								if ( io_ComboBox.textInput != null )
								{
									io_ComboBox.textInput.text = v_ValueString;
								}
								return v_Index;
							}
						}
					}
					else if ( i_Value.hasOwnProperty(io_ComboBox.labelField) )
					{
						var v_ValueObj:Object = i_Value[io_ComboBox.labelField];
							
						for (v_Index=0; v_Index<io_ComboBox.dataProvider; v_Index++)
						{
							v_ItemValue = io_ComboBox.dataProvider.getItemAt(v_Index);
							
							if ( v_ItemValue != null && v_ItemValue.hasOwnProperty(io_ComboBox.labelField) )
							{
								if ( v_ValueObj == v_ItemValue[io_ComboBox.labelField] )
								{
									io_ComboBox.selectedIndex = v_Index;
									if ( io_ComboBox.textInput != null )
									{
										io_ComboBox.textInput.text = v_ItemValue[io_ComboBox.labelField].toString();
									}
									return v_Index;
								}
							}
						}
					}
					else
					{
						var v_ValueToString:Object = i_Value.toString();
						
						for (v_Index=0; v_Index<io_ComboBox.dataProvider; v_Index++)
						{
							v_ItemValue = io_ComboBox.dataProvider.getItemAt(v_Index);
							
							if ( v_ItemValue != null && v_ItemValue.hasOwnProperty(io_ComboBox.labelField) )
							{
								if ( v_ValueToString == v_ItemValue[io_ComboBox.labelField] )
								{
									io_ComboBox.selectedIndex = v_Index;
									if ( io_ComboBox.textInput != null )
									{
										io_ComboBox.textInput.text = v_ItemValue[io_ComboBox.labelField].toString();
									}
									return v_Index;
								}
							}
						}
					}
				}
			}
			
			io_ComboBox.selectedIndex = -1;
			if ( io_ComboBox.textInput != null )
			{
				io_ComboBox.textInput.text = i_Value.toString();
			}
			return -1;
		}
		
		
		
		/**
		 * 字符串转换成颜色值
		 */
		public static function toColor(i_Color:String):uint
		{
			return Singleton.getInstance("mx.styles::IStyleManager2").getColorName(i_Color);
		}
		
		
		
		/**
		 * 多个数据中的最大值
		 * 
		 * @param i_Values  数据集合
		 * 
		 * @version 1.0  2016-01-08
		 */
		public static function max(...i_Values):*
		{
			if ( null == i_Values )
			{
				return null;
			}
			
			var v_Datas:ArrayCollection = Help.toSortValues(i_Values);
			
			return v_Datas[v_Datas.length - 1].value;
		}
		
		
		
		/**
		 * 多个数据中的最小值
		 * 
		 * @param i_Values  数据集合
		 * 
		 * @version 1.0  2016-01-08
		 */
		public static function min(...i_Values):*
		{
			if ( null == i_Values )
			{
				return null;
			}
			
			var v_Datas:ArrayCollection = Help.toSortValues(i_Values);
			
			return v_Datas[0].value;
		}
		
		
		
		/**
		 * 对多个数据的排序
		 * 
		 * @param i_Values  数据集合
		 * 
		 * @version 1.0  2016-01-08
		 */
		public static function toSortValues(...i_Values):ArrayCollection
		{
			// 暂时不明白。为什么在此情况下，要获取不定参数的值有如下区别？  ZhengWei(HY) Add 2016-01-08
			// i_Values[0][0] 表示第一个参数
			// i_Values[0][1] 表示第二个参数
			// 但，你看 toSort() 方法中的 i_SortPropertyNames 参数取值却不这样的。
			// i_SortPropertyNames[0] 表示第一个参数
			// i_SortPropertyNames[1] 表示第二个参数
			// 难不成，这于 ...i_Values 为方法的首的参数有关系？ 
			
			if ( null == i_Values )
			{
				return null;
			}
			
			var v_Datas:ArrayCollection = new ArrayCollection();
			for (var v_Index:int=0; v_Index<i_Values[0].length; v_Index++)
			{
				var v_Item:Object = new Object();
				
				v_Item.value = i_Values[0][v_Index];
				v_Datas.addItem(v_Item);
			}
			
			Help.toSort(v_Datas ,"value");
			
			return v_Datas;
		}
		
		
		
		/**
		 * 集合多维排序
		 * 
		 * @param io_Datas              集合数据
		 * @param i_SortPropertyNames   参与排序的属性名称
		 * 
		 * @version 1.0  2015-11-25
		 */
		public static function toSort(io_Datas:ArrayCollection ,...i_SortPropertyNames):void
		{
			if ( io_Datas == null || i_SortPropertyNames == null)
			{
				return;
			}
			
			var v_Sort:Sort     = new Sort();
			var v_SPNames:Array = new Array();
			for (var v_Index:int=0; v_Index<i_SortPropertyNames.length; v_Index++)
			{
				v_SPNames.push(new SortField(Help.NVL(i_SortPropertyNames[v_Index].toString() ,"")));
			}
			
			v_Sort.fields = v_SPNames;
			io_Datas.sort = v_Sort;
			io_Datas.refresh();
		}
		
		
		
		/**
		 * Json字符串转为对象（为了好记方便，并无特别操作）
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2015-12-09
		 */
		public static function toJsonObject(i_JsonString:String ,i_Reviver:Function = null):Object
		{
			return JSON.parse(i_JsonString ,i_Reviver);
		}
		
		
		
		/**
		 * 对象转为Json字符串（为了好记方便，并无特别操作）
		 * 
		 * @author  ZhengWei(HY)
		 * @version 1.0  2015-12-09
		 */
		public static function toJsonString(i_Object:Object ,i_Replacer:* ,i_Space:*):String
		{
			return JSON.stringify(i_Object ,i_Replacer ,i_Space);
		}
		
		
		
		/**
		 * 单向绑定
		 * 
		 * @param i_Site              绑定的对象
		 * @param i_Prop              绑定对象的属性名称
		 * @param i_Host              监视者的对象
		 * @param i_Chain             监视者对象的属性名称
		 * @param i_CommitOnly
		 * @param i_UseWeakReference  
		 * 
		 * @version 1.0  2015-11-11
		 */
		public static function bindProperty(i_Site:Object
										   ,i_Prop:String
										   ,i_Host:Object
										   ,i_Chain:Object
										   ,i_CommitOnly:Boolean = false
										   ,i_UseWeakReference:Boolean = false):void
		{
			try
			{
				// i_Site.i_Prop 的值跟随 i_Host.i_Chain值的变化
				BindingUtils.bindProperty(i_Site ,i_Prop  ,i_Host ,i_Chain ,i_CommitOnly ,i_UseWeakReference);
			}
			catch (error:Error)
			{
				if ( i_Site != null && i_Prop != null && i_Chain != null )
				{
					trace("-- bindProperty: " + error.message.toString() + i_Site.toString() + "." + i_Prop + " => " + i_Chain.toString());
				}
				else if ( i_Site != null && i_Prop != null )
				{
					trace("-- bindProperty: " + error.message.toString() + i_Site.toString() + "." + i_Prop + " => null");
				}
				else if ( i_Site != null )
				{
					trace("-- bindProperty: " + error.message.toString() + i_Site.toString() + "." + "null" + " => null");
				}
				else
				{
					trace("-- bindProperty: " + error.message.toString());
				}
			}
		}
		
		
		
		/**
		 * 双向绑定
		 * 
		 * @param i_Site              绑定的对象
		 * @param i_Prop              绑定对象的属性名称
		 * @param i_Host              监视者的对象
		 * @param i_Chain             监视者对象的属性名称
		 * @param i_CommitOnly
		 * @param i_UseWeakReference  
		 * 
		 * @version 1.0  2015-11-11
		 */
		public static function bindPropertyTwoWay(i_Site:Object
												 ,i_Prop:String
												 ,i_Host:Object
												 ,i_Chain:String
												 ,i_CommitOnly:Boolean = false
												 ,i_UseWeakReference:Boolean = false):void
		{
			try
			{
				// i_Site.i_Prop 的值跟随 i_Host.i_Chain值的变化
				BindingUtils.bindProperty(i_Site ,i_Prop  ,i_Host ,i_Chain ,i_CommitOnly ,i_UseWeakReference);
				// i_Host.i_Chain的值跟随 i_Site.i_Prop 值的变化
				BindingUtils.bindProperty(i_Host ,i_Chain ,i_Site ,i_Prop  ,i_CommitOnly ,i_UseWeakReference);
			}
			catch (error:Error)
			{
				if ( i_Site != null && i_Prop != null && i_Chain != null )
				{
					trace("-- bindProperty: " + error.message.toString() + i_Site.toString() + "." + i_Prop + " => " + i_Chain.toString());
				}
				else if ( i_Site != null && i_Prop != null )
				{
					trace("-- bindProperty: " + error.message.toString() + i_Site.toString() + "." + i_Prop + " => null");
				}
				else if ( i_Site != null )
				{
					trace("-- bindProperty: " + error.message.toString() + i_Site.toString() + "." + "null" + " => null");
				}
				else
				{
					trace("-- bindProperty: " + error.message.toString());
				}
			}
		}
		
		
		
		/**
		 * 统一设置某一类(或某几类)控件的样式
		 * 
		 * 注意：只能设置有定义 id属性 的控件
		 * 
		 * @param i_View        页面容器。通常值为：this
		 * @param i_Types       组件类型名称的集合。如 ["spark.components::TextArea"]。默认所包含常用组件
		 * @param i_Containers  容器控件类型名称的集合。一但有值，将递归遍历。默认值为空
		 * 
		 * @version 1.0  2015-11-11
		 */
		public static function debugBinding(i_View:UIComponent ,i_Types:Array=null ,i_Containers:Array=null):void
		{
			var v_Types:Array = (Help.isNull(i_Types) ? ["org.hy.common.ui::TextInputDouble" ,"spark.components::TextInput" ,"spark.components::TextArea" ,"spark.components::ComboBox"] : i_Types);
			var v_Index:int   = 0;
			
			Help.setValues(i_View ,v_Types ,function(i_Child:UIComponent):void {
				if ( i_Child != null )
				{
					if ( i_Child.hasOwnProperty("text") )
					{
						trace("-- Binding [" + (++v_Index) + "]：" + i_Child.id + ".text");
						BindingManager.debugBinding(i_Child.id + ".text");
					}
					
					if ( i_Child.hasOwnProperty("selectedItem") )
					{
						trace("-- Binding [" + (++v_Index) + "]：" + i_Child.id + ".selectedItem");
						BindingManager.debugBinding(i_Child.id + ".selectedItem");
					}
					
					if ( i_Child.hasOwnProperty("dataProvider") )
					{
						trace("-- Binding [" + (++v_Index) + "]：" + i_Child.id + ".dataProvider");
						BindingManager.debugBinding(i_Child.id + ".dataProvider");
					}
				}
			});
		}
		
		
		
		/**
		 * 统一设置某一类控件的样式
		 * 
		 * 注意：只能设置有定义 id属性 的控件
		 * 
		 * @param i_View        页面容器。通常值为：this
		 * @param i_Type        组件类型名。如 "spark.components::TextArea"
		 * @param i_StyleName   样式名称。如选中文本的背景色的属性名：focusedTextSelectionColor
		 * @param i_StyleValue  样式值
		 * @param i_Containers  容器控件类型名称的集合。一但有值，将递归遍历。默认值为空
		 * 
		 * @version 1.0  2015-07-20
		 */
		public static function setStyle(i_View:UIComponent ,i_Types:String ,i_StyleName:String ,i_StyleValue:* ,i_Containers:Array=null):void
		{
			setStyles(i_View ,[i_Types] ,i_StyleName ,i_StyleValue);
		}
		
		
		
		/**
		 * 统一设置某一类(或某几类)控件的样式
		 * 
		 * 注意：只能设置有定义 id属性 的控件
		 * 
		 * @param i_View        页面容器。通常值为：this
		 * @param i_Types       组件类型名称的集合。如 ["spark.components::TextArea"]
		 * @param i_StyleName   样式名称。如选中文本的背景色的属性名：focusedTextSelectionColor
		 * @param i_StyleValue  样式值
		 * @param i_Containers  容器控件类型名称的集合。一但有值，将递归遍历。默认值为空
		 * 
		 * @version 1.0  2015-07-20
		 */
		public static function setStyles(i_View:UIComponent ,i_Types:Array ,i_StyleName:String ,i_StyleValue:* ,i_Containers:Array=null):void
		{
			setValues(i_View ,i_Types ,function (i_ChildUI:UIComponent):void {
				i_ChildUI.setStyle(i_StyleName, i_StyleValue);
			} ,i_Containers);
		}
		
		
		
		/**
		 * 统一设置某一类(或某几类)控件的样式
		 * 
		 * 注意：只能设置有定义 id属性 的控件
		 * 
		 * @param i_View        页面容器。通常值为：this
		 * @param i_Type        组件类型名称。如 "spark.components::TextArea"
		 * @param i_FunName     具体执行的函数。其惟一的入参参数是：查找控件的实例
		 * @param i_Containers  容器控件类型名称的集合。一但有值，将递归遍历。默认值为空
		 * 
		 * @version 1.0  2015-07-20
		 */
		public static function setValue(i_View:UIComponent ,i_Type:String ,i_FunName:Function ,i_Containers:Array=null):void
		{
			setValues(i_View ,[i_View] ,i_FunName ,i_Containers);
		}
		
		
		
		/**
		 * 统一设置某一类(或某几类)控件的样式
		 * 
		 * 注意：只能设置有定义 id属性 的控件
		 * 
		 * @param i_View        页面容器。通常值为：this
		 * @param i_Types       组件类型名称的集合。如 ["spark.components::TextArea"]
		 * @param i_FunName     具体执行的函数。其惟一的入参参数是：查找控件的实例
		 * @param i_Containers  容器控件类型名称的集合。一但有值，将递归遍历。默认值为空
		 * 
		 * @version 1.0  2015-07-20
		 */
		public static function setValues(i_View:UIComponent ,i_Types:Array ,i_FunName:Function ,i_Containers:Array=null):void
		{
			// 通过反射机制取出当前MXML中的信息 
			var v_InstanceInfo:XML = flash.utils.describeType(i_View);
			
			for each (var v_Type:String in i_Types)
			{
				// 找出所有的文件框控件
				var v_Properties:XMLList = v_InstanceInfo.accessor.(@type==v_Type);
				
				for each (var v_PropertyInfo:XML in v_Properties)
				{   
					// 获取控件的标识名称
					var v_PropertyName:String = v_PropertyInfo.@name;
					
					if ( !Help.isNull(v_PropertyName) )
					{
						i_FunName(i_View[v_PropertyName]);
					}
				}
			}
			
			if ( i_Containers != null && i_Containers.length > 0 )
			{
				for each (var v_Container:String in i_Containers)
				{
					// 找出所有的容器控件
					var v_ContainerPS:XMLList = v_InstanceInfo.accessor.(@type==v_Container);
					
					for each (var v_ContainerPInfo:XML in v_ContainerPS)
					{   
						var v_ContainerPName:String = v_ContainerPInfo.@name;
						
						if ( !Help.isNull(v_ContainerPName) )
						{
							// 递归遍历
							setValues(i_View[v_ContainerPName] ,i_Types ,i_FunName ,i_Containers);
						}
					}
				}
			}
			
		}
		
		
		
		/**
		 * 获取某一类(或某几类)控件的ID
		 * 
		 * 注意：只能设置有定义 id属性 的控件
		 * 
		 * @param i_View        页面容器。通常值为：this
		 * @param i_Types       组件类型名称的集合。如 ["spark.components::TextArea"]
		 * @param i_Containers  容器控件类型名称的集合。一但有值，将递归遍历。默认值为空
		 * 
		 * @version 1.0  2015-07-22
		 */
		public static function getIDs(i_View:UIComponent ,i_Types:Array ,i_Containers:Array=null):Array
		{
			// 通过反射机制取出当前MXML中的信息 
			var v_InstanceInfo:XML = flash.utils.describeType(i_View);
			var v_Ret:Array        = new Array();
			
			for each (var v_Type:String in i_Types)
			{
				// 找出所有的文件框控件
				var v_Properties:XMLList = v_InstanceInfo.accessor.(@type==v_Type);
				
				for each (var v_PropertyInfo:XML in v_Properties)
				{   
					// 获取控件的标识名称
					var v_PropertyName:String = v_PropertyInfo.@name;
					
					if ( !Help.isNull(v_PropertyName) )
					{
						v_Ret.push(v_PropertyName);
					}
				}
			}
			
			if ( i_Containers != null && i_Containers.length > 0 )
			{
				for each (var v_Container:String in i_Containers)
				{
					// 找出所有的容器控件
					var v_ContainerPS:XMLList = v_InstanceInfo.accessor.(@type==v_Container);
					
					for each (var v_ContainerPInfo:XML in v_ContainerPS)
					{   
						var v_ContainerPName:String = v_ContainerPInfo.@name;
						
						if ( !Help.isNull(v_ContainerPName) )
						{
							// 递归遍历
							var v_RetChild:Array = getIDs(i_View[v_ContainerPName] ,i_Types ,i_Containers);
							
							v_Ret.push(v_RetChild);
						}
					}
				}
			}
			
			return v_Ret;
		}
		
		
		
		/**
		 * 获取某一类(或某几类)控件的实例
		 * 
		 * 注意：只能设置有定义 id属性 的控件
		 * 
		 * @param i_View        页面容器。通常值为：this
		 * @param i_Types       组件类型名称的集合。如 ["spark.components::TextArea"]
		 * @param i_Containers  容器控件类型名称的集合。一但有值，将递归遍历。默认值为空
		 * 
		 * @version 1.0  2015-07-22
		 */
		public static function getUIs(i_View:UIComponent ,i_Types:Array ,i_Containers:Array=null):Array
		{
			// 通过反射机制取出当前MXML中的信息 
			var v_InstanceInfo:XML = flash.utils.describeType(i_View);
			var v_Ret:Array        = new Array();
			
			for each (var v_Type:String in i_Types)
			{
				// 找出所有的文件框控件
				var v_Properties:XMLList = v_InstanceInfo.accessor.(@type==v_Type);
				
				for each (var v_PropertyInfo:XML in v_Properties)
				{   
					// 获取控件的标识名称
					var v_PropertyName:String = v_PropertyInfo.@name;
					
					if ( !Help.isNull(v_PropertyName) )
					{
						v_Ret.push(i_View[v_PropertyName]);
					}
				}
			}
			
			if ( i_Containers != null && i_Containers.length > 0 )
			{
				for each (var v_Container:String in i_Containers)
				{
					// 找出所有的容器控件
					var v_ContainerPS:XMLList = v_InstanceInfo.accessor.(@type==v_Container);
					
					for each (var v_ContainerPInfo:XML in v_ContainerPS)
					{   
						var v_ContainerPName:String = v_ContainerPInfo.@name;
						
						if ( !Help.isNull(v_ContainerPName) )
						{
							// 递归遍历
							var v_RetChild:Array = getIDs(i_View[v_ContainerPName] ,i_Types ,i_Containers);
							
							v_Ret.push(v_RetChild);
						}
					}
				}
			}
			
			return v_Ret;
		}
		
	}
}