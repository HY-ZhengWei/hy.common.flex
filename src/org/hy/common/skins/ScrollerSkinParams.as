package org.hy.common.skins
{
	/**
	 * 滚动条皮肤的相关参数
	 * 
	 * @author      ZhengWei(HY)
	 * @createDate  2015-08-06
	 * @version     V1.0
	 */
	public class ScrollerSkinParams
	{
		
		/** 滚动条滑块的颜色 */
		[Bindable]
		public static var thumbColor:uint  = 0xC7C7C7;
		
		/** 滚动条两端按钮的颜色 */
		[Bindable]
		public static var buttonColor:uint = 0xC7C7C7;
		
		/** 滚动条滑道的颜色 */
		[Bindable]
		public static var trackColor:uint  = 0xCACACA;
		
		
		
		public function ScrollerSkinParams()
		{
		}
		
		
		
		/**
		 * 恢复默认值的情况
		 */
		public static function undoDefault():void
		{
			thumbColor  = 0xC7C7C7;
			buttonColor = 0xC7C7C7;
			trackColor  = 0xCACACA;
		}
		
	}
}