package com.eyu.framework.utils
{
	import PathFinding.core.Node;
	
	import laya.maths.Point;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Utils;

	/**
	 * 贝塞尔曲线运动
	 * @author: Anon
	 * @date: 2018-5-26下午3:34:09
	 * @version: IdleHero V1.0.0
	 * @description: BezierAni
	 */
	public class BezierAni
	{
		/**@private */
		/*[IF-FLASH]*/
		private static var bezierAniMap:Object = new Object();
		//[IF-JS] private static var bezierAniMap:Array = {};
		/**@private */
		private var _complete:Handler;
		/**@private */
		private var _target:*;
		/**@private */
		private var _ease:Function;
		/**@private */
		private var _controlPoints:Array;
		/**@private */
		private var _duration:int;
		/**@private */
		private var _delay:int;
		/**@private */
		private var _startTimer:int;
		/**@private */
		private var _usedTimer:int;
		/**@private */
		private var _usedPool:Boolean;
		/**@private */
		private var _otherValue:Object;
		
		public function BezierAni()
		{
		}
		
		/**
		 * 缓动对象的props属性到目标值。
		 * @param	target 目标对象(即将更改属性值的对象)。
		 * @param	props 贝塞尔曲线的三个点,{起始点，控制点，终点}
		 * @param	duration 花费的时间，单位毫秒。
		 * @param	ease 缓动类型，默认为匀速运动。
		 * @param	complete 结束回调函数。
		 * @param	delay 延迟执行时间。
		 * @param	coverBefore 是否覆盖之前的缓动。
		 * @param	autoRecover 是否自动回收，默认为true，缓动结束之后自动回收到对象池。
		 * @param	otherValue 其他Tween参数，先加一种角度。
		 * @return	返回Tween对象。
		 */
		public static function to(target:*, props:Array, duration:int, ease:Function = null, complete:Handler = null, delay:int = 0, coverBefore:Boolean = false, autoRecover:Boolean = true,otherValue:Object=null):BezierAni {
			return Pool.getItemByClass("BezierAni", BezierAni)._create(
				target, props, duration, ease, complete, delay, coverBefore, autoRecover, true,otherValue);
		}
		
		/**
		 * 缓动对象的props属性到目标值。
		 * @param	target 目标对象(即将更改属性值的对象)。
		 * @param	props 贝塞尔曲线的三个点,{起始点，控制点，终点}
		 * @param	duration 花费的时间，单位毫秒。
		 * @param	ease 缓动类型，默认为匀速运动。
		 * @param	complete 结束回调函数。
		 * @param	delay 延迟执行时间。
		 * @param	coverBefore 是否覆盖之前的缓动。
		 * @return	返回Tween对象。
		 */
		public function to(target:*, props:Array, duration:int, ease:Function = null, complete:Handler = null, delay:int = 0, coverBefore:Boolean = false):BezierAni {
			return _create(target, props, duration, ease, complete, delay, coverBefore, false, true);
		}
		
		/** @private */
		public function _create(target:*, props:Array, duration:int, ease:Function, complete:Handler, delay:int, coverBefore:Boolean, usePool:Boolean, runNow:Boolean,otherValue:Object=null):BezierAni {
			if (!target) throw new Error("BezierAni:target is null");
			this._target = target;
			this._duration = duration;
			this._ease = ease || easeNone;
			this._complete = complete;
			this._delay = delay;
			this._controlPoints = props;
			this._usedTimer = 0;
			this._startTimer = Browser.now();
			this._usedPool = usePool;
			this._otherValue = otherValue;
			
			var gid:int;
			//判断是否覆盖			
			//[IF-JS]gid = (target.$_GID || (target.$_GID = Utils.getGID()));
//			var gid:* = target;
			if (!bezierAniMap[gid]) {
				bezierAniMap[gid] = [this];
			} else {
				if (coverBefore) clearTween(target);
				bezierAniMap[gid].push(this);
			}
			
			if (runNow) {
				if (delay <= 0) firstStart(target, props);
				else Laya.scaleTimer.once(delay, this, firstStart, [target, props]);
			} else {
				_initProps(target, props);
			}
			return this;
		}
		
		private function firstStart(target:*, props:Object):void {
			if (target.destroyed) {
				this.clear();
				return;
			}
			_initProps(target, props);
			_beginLoop();
		}
		
		private function _initProps(target:*, props:Object):void {
			//初始化属性
//			for (var p:String in props) {
//				if (target[p] is Number) {
//					var start:Number = isTo ? target[p] : props[p];
//					var end:Number = isTo ? props[p] : target[p];
//					this._props.push([p, start, end - start]);
//					if (!isTo) target[p] = start;
//				}
//			}
			if(target["x"])
			{
				target["x"] = props[0].x;
				target["y"] = props[0].y;
			}
		}
		
		private function _beginLoop():void {
			Laya.scaleTimer.frameLoop(1, this, _doEase);
		}
		
		/**执行缓动**/
		private function _doEase():void {
			_updateEase(Browser.now());
		}
		
		/**@private */
		public function _updateEase(time:Number):void {
			var target:* = this._target;
			if (!target) return;
			
			//如果对象被销毁，则立即停止缓动
			/*[IF-FLASH]*/
			if (target is Node && target.destroyed) return clearTween(target);
			//[IF-JS]if (target.destroyed) return clearTween(target);
			
			var usedTimer:Number = this._usedTimer = time - this._startTimer - this._delay;
			if (usedTimer < 0) return;
			if (usedTimer >= this._duration) return complete();
			
			var ratio:Number = usedTimer > 0 ? this._ease(usedTimer, 0, 1, this._duration) : 0;
			var newPoint:Point = Pool.getItemByClass("point", Point);
			getPoint2(ratio, newPoint, this._controlPoints);
			if(_otherValue&&_otherValue["rotation"]&&(target["x"] != newPoint.x||target["y"] != newPoint.y)){
				var handler:Handler = _otherValue["rotation"];
				handler.runWith(getAngle360(target["x"],target["y"],newPoint.x,newPoint.y));
			}
			target["x"] = newPoint.x;
			target["y"] = newPoint.y;
			//var newPoint:Point = Pool.recover("point", newPoint);
//			for (var i:int, n:int = props.length; i < n; i++) {
//				var prop:Array = props[i];
//				target[prop[0]] = prop[1] + (ratio * prop[2]);
//			}
		}
		
		private function getAngle360(x1:Number,y1:Number,x2:Number,y2:Number):Number{
			if(x2==x1){
				return y2>y1?90:270;
			}else if(y2 == y1){
				return x2>x1?0:180;
			}
			var r:Number = Math.atan((y2-y1)/(x2-x1))*180/Math.PI;
			r = r<0?r+180:r;
			r = y2<y1?r+180:r;
			return r;
		}
		
		/**设置当前执行比例**/
		public function set progress(v:Number):void {
			var uTime:Number = v * _duration;
			this._startTimer = Browser.now() - this._delay - uTime;
		}
		
		/**
		 * 立即结束缓动并到终点。
		 */
		public function complete():void {
			if (!this._target) return;
			
			//立即执行初始化
			Laya.scaleTimer.runTimer(this, firstStart);
			
			//缓存当前属性
			var target:* = this._target;
			//var props:* = this._props;
			var handler:Handler = this._complete;
			//设置终点属性
//			for (var i:int, n:int = props.length; i < n; i++) {
//				var prop:Array = props[i];
//				target[prop[0]] = prop[1] + prop[2];
//			}
			if(target["x"])
			{
				target["x"] = this._controlPoints[2]?this._controlPoints[2].x:this._controlPoints[1].x;
				target["y"] = this._controlPoints[2]?this._controlPoints[2].y:this._controlPoints[1].y;
			}
			//清理
			clear();
			//回调
			handler && handler.run();
			
		}
		
		/**
		 * 暂停缓动，可以通过resume或restart重新开始。
		 */
		public function pause():void {
			Laya.scaleTimer.clear(this, _beginLoop);
			Laya.scaleTimer.clear(this, _doEase);
		}
		
		/**
		 * 设置开始时间。
		 * @param	startTime 开始时间。
		 */
		public function setStartTime(startTime:Number):void {
			_startTimer = startTime;
		}
		
		/**
		 * 清理指定目标对象上的所有缓动。
		 * @param	target 目标对象。
		 */
		public static function clearAll(target:Object):void {
			/*[IF-FLASH]*/
			if (!target) return;
			//[IF-JS]if (!target || !target.$_GID) return;
			/*[IF-FLASH]*/
			var tweens:Array = bezierAniMap[target];
			//[IF-JS]var tweens:Array = bezierAniMap[target.$_GID];
			if (tweens) {
				for (var i:int, n:int = tweens.length; i < n; i++) {
					tweens[i]._clear();
				}
				tweens.length = 0;
			}
		}
		
		/**
		 * 清理某个缓动。
		 * @param	BezierAni 缓动对象。
		 */
		public static function clear(bezierAni:BezierAni):void {
			bezierAni.clear();
		}
		
		/**@private 同clearAll，废弃掉，尽量别用。*/
		public static function clearTween(target:Object):void {
			clearAll(target);
		}
		
		/**
		 * 停止并清理当前缓动。
		 */
		public function clear():void {
			if (this._target) {
				_remove();
				_clear();
			}
		}
		
		/**
		 * @private
		 */
		public function _clear():void {
			pause();
			Laya.scaleTimer.clear(this, firstStart);
			this._complete = null;
			this._target = null;
			this._ease = null;
			this._controlPoints = null;
			this._otherValue = null;
			
			if (this._usedPool) {
				Pool.recover("BezierAni", this);
			}
		}
		
		/** 回收到对象池。*/
		public function recover():void {
			_usedPool = true;
			_clear();
		}
		
		private function _remove():void {
			/*[IF-FLASH]*/
			var tweens:Array = bezierAniMap[this._target];
			//[IF-JS]var tweens:Array = bezierAniMap[this._target.$_GID];
			if (tweens) {
				for (var i:int, n:int = tweens.length; i < n; i++) {
					if (tweens[i] === this) {
						tweens.splice(i, 1);
						break;
					}
				}
			}
		}
		
		/**
		 * 重新开始暂停的缓动。
		 */
		public function restart():void {
			pause();
			this._usedTimer = 0;
			this._startTimer = Browser.now();
//			var props:Array = this._controlPoints;
//			for (var i:int, n:int = props.length; i < n; i++) {
//				var prop:Array = props[i];
//				this._target[prop[0]] = prop[1];
//			}
			this._initProps(this._target, this._controlPoints);
			Laya.scaleTimer.once(this._delay, this, _beginLoop);
		}
		
		/**
		 * 恢复暂停的缓动。
		 */
		public function resume():void {
			if (this._usedTimer >= this._duration) return;
			this._startTimer = Browser.now() - this._usedTimer - this._delay;
			_beginLoop();
		}
		
		private static function easeNone(t:Number, b:Number, c:Number, d:Number):Number {
			return c * t / d + b;
		}
		
		/**
		 * 计算二次贝塞尔点。
		 * @param t
		 * @param rst
		 *
		 */
		public function getPoint2(t:Number, resPoint:Point, controlPoints:Array):void 
		{
			//二次贝塞尔曲线公式
			var p1:Point = controlPoints[0];
			var p2:Point = controlPoints[1];
			var p3:Point = controlPoints[2];
			p3 = p3?p3:p2;
			var lineX:Number = Math.pow((1 - t), 2) * p1.x + 2 * t * (1 - t) * p2.x + Math.pow(t, 2) * p3.x;
			var lineY:Number = Math.pow((1 - t), 2) * p1.y + 2 * t * (1 - t) * p2.y + Math.pow(t, 2) * p3.y;
			
			resPoint.x = lineX;
			resPoint.y = lineY;
		}
		
		/**
		 * 计算三次贝塞尔点
		 * @param t
		 * @param rst
		 *
		 */
		public function getPoint3(t:Number, resPoint:Point, controlPoints:Array):void 
		{
			//三次贝塞尔曲线公式
			var p1:Point = controlPoints[0];
			var p2:Point = controlPoints[1];
			var p3:Point = controlPoints[2];
			var p4:Point = controlPoints[3];
			var lineX:Number = Math.pow((1 - t), 3) * p1.x + 3 * p2.x * t * (1 - t) * (1 - t) + 3 * p3.x * t * t * (1 - t) + p4.x * Math.pow(t, 3);
			var lineY:Number = Math.pow((1 - t), 3) * p1.y + 3 * p2.y * t * (1 - t) * (1 - t) + 3 * p3.y * t * t * (1 - t) + p4.y * Math.pow(t, 3);
			
			resPoint.x = lineX;
			resPoint.y = lineY;
		}
	}
}