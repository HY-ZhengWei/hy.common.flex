package org.hy.common.ui
{
	import mx.controls.ToolTip;
	import mx.core.UITextField;
	import mx.skins.halo.ToolTipBorder;
	
	
	
	
	
	/**
	 * 提示信息支持Html格式的文本
	 * 
	 *   使用时，下行语句激活应用本类
	 *   ToolTipManager.toolTipClass = HtmlToolTip;
	 * 
	 *   提示信息一直显示，直到鼠标移出控件
	 *   ToolTipManager.hideDelay    = Infinity
	 * 
	 * @author      ZhengWei(HY)
	 * @createDate  2016-01-18
	 * @version     V1.0
	 */
	public class HtmlToolTip extends ToolTip
	{
		override protected function commitProperties():void
		{
			super.commitProperties();
			// 转化为HTML文本
			textField.htmlText = this.text;
		}
	}
	
}