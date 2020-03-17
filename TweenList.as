/**
 * @author: Danny
 * @time: 2020-3-4 上午10:21:17
 * @description: TweenList
 */
package com.eyu.framework.utils
{
	import laya.utils.Handler;
	import laya.utils.Tween;

	public class TweenList
	{
		/**
		 * 参数列表 
		 */		
		private var _params:Vector.<TweenParam>;
		
		/**
		 * 当前参数下标 
		 */		
		private var _curIndex:int;
		
		/**
		 * 正在执行的Tween 
		 */		
		private var _tween:Tween
		
		public function TweenList()
		{
			this.reset();
		}
		
		/**
		 * 添加参数 
		 * @param target
		 * @param props
		 * @param duration
		 * @param ease
		 * @param complete
		 * @param delay
		 * 
		 */		
		public function addTo(target:*, props:Object, duration:int, ease:Function = null, complete:Handler = null, delay:int = 0):void
		{
			var param:TweenParam = new TweenParam;
			param.target = target;
			param.props = props;
			param.duration = duration;
			param.ease = ease;
			param.complete = complete;
			param.delay = delay;
			
			_params.push(param);
		}
		
		/**
		 * 播放 
		 * 
		 */		
		public function play():void
		{
			this.stop();
			this.playByIndex(_curIndex);
		}
		
		/**
		 * 重置 
		 * 
		 */		
		public function reset():void
		{
			this.stop();
			_params = new Vector.<TweenParam>;
		}
		
		/**
		 * 停止 
		 * 
		 */		
		public function stop():void
		{
			_curIndex = 0;
			if(_tween)
			{
				Tween.clear(_tween);
				_tween = null;
			}
		}
		
		/**
		 * 暂停 
		 * 
		 */		
		public function pause():void
		{
			if(_tween)
			{
				_tween.pause();
			}
		}
		
		/**
		 * 恢复 
		 * 
		 */		
		public function resume():void
		{
			if(_tween)
			{
				_tween.resume();
			}	
		}
		
		private function to(param:TweenParam):void
		{
			_tween = Tween.to(param.target,param.props,param.duration,param.ease,Handler.create(this,this.onComplete),param.delay);
		}
		
		private function onComplete():void
		{
			//执行回调
			_tween = null;
			var param:TweenParam = _params[_curIndex];
			if(param && param.complete)
			{
				param.complete.run();
			}
			
			//执行新的
			_curIndex++;
			this.playByIndex(_curIndex);
		}
		
		private function playByIndex(index:int):void
		{
			if(index < _params.length)
			{
				var param:TweenParam = _params[index];
				if(param)
				{
					this.to(param);
				}
			}
		}
	}
}
import laya.utils.Handler;

class TweenParam
{
	public var target:*;
	public var props:Object;
	public var duration:int;
	public var ease:Function;
	public var complete:Handler;
	public var delay:int;
}