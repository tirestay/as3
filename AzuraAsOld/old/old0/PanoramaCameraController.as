package pano
{
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	/**
	 * PanoramaCameraController はパノラマを設計するときに便利なカメラ用コントローラークラスです。
	 * 緯度・経度で配置することができます。
	 *
	 * @author clockmaker
	 *
	 * @langversion 3.0
	 * @playerversion Flash 11
	 * @playerversion AIR 3.0
	 */
	public class PanoramaCameraController extends SimpleObjectController
	{
		
		//----------------------------------------------------------
		//
		//   Static Property 
		//
		//----------------------------------------------------------
		
		/** 中心と方向へ移動するアクションを示す定数です。 */
		public static const ACTION_FORWARD:String = "actionForward";
		
		/** 中心と反対方向へ移動するアクションを示す定数です。 */
		public static const ACTION_BACKWARD:String = "actionBackward";
		
		/** イージングの終了判断に用いるパラメーターです。0〜0.2で設定し、0に近いほどイージングが残されます。 */
		private static const ROUND_VALUE:Number = 0.1;
		
		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------
		
		/**
		 * 新しい PanoramaCameraController インスタンスを作成します。
		 * @param targetObject	コントローラーで制御したいオブジェクトです。
		 * @param mouseDownEventSource	マウスダウンイベントとひもづけるオブジェクトです。
		 * @param mouseUpEventSource	マウスアップイベントとひもづけるオブジェクトです。推奨は stage です。
		 * @param keyEventSource	キーダウン/キーマップイベントとひもづけるオブジェクトです。推奨は stage です。
		 * @param useKeyControl	キーコントロールを使用するか指定します。
		 * @param useMouseWheelControl	マウスホイールコントロールを使用するか指定します。
		 */
		public function PanoramaCameraController(
			targetObject:Object3D,
			mouseDownEventSource:InteractiveObject,
			mouseUpEventSource:InteractiveObject,
			keyEventSource:InteractiveObject,
			useKeyControl:Boolean = true,
			useMouseWheelControl:Boolean = true
		)
		{
			_target = targetObject;
			
			super(mouseDownEventSource, targetObject, 0, 3, mouseSensitivity);
			super.mouseSensitivity = 0;
			super.unbindAll();
			super.accelerate(true);
			
			this._mouseDownEventSource = mouseDownEventSource;
			this._mouseUpEventSource = mouseUpEventSource;
			this._keyEventSource = keyEventSource;
			
			_mouseDownEventSource.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			// マウスホイール操作
			if (useMouseWheelControl)
				_mouseDownEventSource.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			
			// キーボード操作
			if (useKeyControl)
			{
				_keyEventSource.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
				_keyEventSource.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			}
		}
		
		//----------------------------------------------------------
		//
		//   Property 
		//
		//----------------------------------------------------------
		
		//--------------------------------------
		// easingSeparator 
		//--------------------------------------
		
		private var _easingSeparator:Number = 10;
		
		/**
		 * イージング時の現在の位置から最後の位置までの分割係数
		 * フレームレートと相談して使用
		 * 1〜
		 * 正の整数のみ。0 を指定しても 1 になります。
		 * 1 でイージング無し。数値が高いほど、遅延しぬるぬるします
		 */
		public function set easingSeparator(value:uint):void
		{
			if (value)
				_easingSeparator = value;
			else
				_easingSeparator = 1;
		}
		/** Camera の最大fov値です。 */
		public var maxFov:Number = 125 * Math.PI / 180;
		/**
		 * 最大緯度です。
		 */
		public var maxLatitude:Number = 89.9;
		
		/** Camera の最小fov値です。 */
		public var minFov:Number = 90 * Math.PI / 180;
		
		/**
		 * 最小緯度です。
		 */
		public var minLatitude:Number = -89.9;
		
		//--------------------------------------
		// mouseSensitivityX 
		//--------------------------------------
		
		private var _mouseSensitivityX:Number = -0.30;
		
		/**
		 * マウスの X 方向の感度
		 */
		public function set mouseSensitivityX(value:Number):void
		{
			_mouseSensitivityX = value;
		}
		
		//--------------------------------------
		// mouseSensitivityY 
		//--------------------------------------
		
		private var _mouseSensitivityY:Number = -0.30;
		
		/**
		 * マウスの Y 方向の感度
		 */
		public function set mouseSensitivityY(value:Number):void
		{
			_mouseSensitivityY = value;
		}
		
		public var multiplyValue:Number = 10;
		
		//--------------------------------------
		// needsRendering 
		//--------------------------------------
		
		private var _needsRendering:Boolean;
		
		/**
		 * レンダリングが必要かどうかを取得します。
		 * この値は update() メソッドが呼び出されたタイミングで更新されます。
		 *
		 * @see GeoCameraController.update
		 */
		public function get needsRendering():Boolean
		{
			return _needsRendering;
		}
		
		//--------------------------------------
		// pitchSpeed 
		//--------------------------------------
		
		private var _pitchSpeed:Number = 1.5;
		
		/**
		 * 上下スピード
		 * 初期値は5(px)
		 */
		public function set pitchSpeed(value:Number):void
		{
			_pitchSpeed = value
		}
		
		public var useHandCursor:Boolean = true;
		
		//--------------------------------------
		// yawSpeed 
		//--------------------------------------
		
		private var _yawSpeed:Number = 2;
		
		/**
		 * 回転スピード
		 * 初期値は5(度)
		 */
		public function set yawSpeed(value:Number):void
		{
			_yawSpeed = value * Math.PI / 180;
		}
		
		/**
		 * Zoomスピード
		 * 初期値は5(px)
		 */
		public function set zoomSpeed(value:Number):void
		{
			_fovSpeed = value;
		}
		
		private var _angleLatitude:Number = 0;
		private var _angleLongitude:Number = 0;
		private var _fovSpeed:Number = 0.5 * Math.PI / 180;
		private var _keyEventSource:InteractiveObject;
		private var _lastLatitude:Number = 0;
		private var _lastLongitude:Number = _angleLongitude;
		private var _lastZoom:Number = 120 * Math.PI / 180;
		private var _mouseDownEventSource:InteractiveObject;
		private var _mouseMove:Boolean;
		private var _mouseUpEventSource:InteractiveObject;
		private var _mouseX:Number;
		private var _mouseY:Number;
		private var _oldLatitude:Number;
		private var _oldLongitude:Number;
		private var _pitchDown:Boolean;
		private var _pitchUp:Boolean;
		private var _taregetDistanceValue:Number = 0;
		private var _taregetPitchValue:Number = 0;
		private var _taregetYawValue:Number = 0;
		private var _target:Object3D
		private var _yawLeft:Boolean;
		private var _yawRight:Boolean;
		private var _zoom:Number = 120 * Math.PI / 180;
		private var _zoomIn:Boolean;
		private var _zoomOut:Boolean;
		
		//----------------------------------------------------------
		//
		//   Function 
		//
		//----------------------------------------------------------
		
		/** 上方向に移動します。 */
		public function pitchUp():void
		{
			_taregetPitchValue = _pitchSpeed * multiplyValue;
		}
		
		/** 下方向に移動します。 */
		public function pitchDown():void
		{
			_taregetPitchValue = _pitchSpeed * -multiplyValue;
		}
		
		/** 左方向に移動します。 */
		public function yawLeft():void
		{
			_taregetYawValue = _yawSpeed * multiplyValue;
		}
		
		/** 右方向に移動します。 */
		public function yawRight():void
		{
			_taregetYawValue = _yawSpeed * -multiplyValue;
		}
		
		/** 中心へ向かって近づきます。 */
		public function moveForeward():void
		{
			_taregetDistanceValue -= _fovSpeed * multiplyValue;
		}
		
		/** 中心から遠くに離れます。 */
		public function moveBackward():void
		{
			_taregetDistanceValue += _fovSpeed * multiplyValue;
		}
		
		/**
		 *　@inheritDoc
		 */
		override public function bindKey(keyCode:uint, action:String):void
		{
			switch (action)
			{
				case ACTION_FORWARD:
				{
					keyBindings[keyCode] = toggleForward;
					break
				}
				case ACTION_BACKWARD:
				{
					keyBindings[keyCode] = toggleBackward;
					break
				}
				case ACTION_YAW_LEFT:
				{
					keyBindings[keyCode] = toggleYawLeft;
					break
				}
				case ACTION_YAW_RIGHT:
				{
					keyBindings[keyCode] = toggleYawRight;
					break
				}
				case ACTION_PITCH_DOWN:
				{
					keyBindings[keyCode] = togglePitchDown;
					break
				}
				case ACTION_PITCH_UP:
				{
					keyBindings[keyCode] = togglePitchUp;
					break
				}
			}
			//super.bindKey(keyCode, action)
		}
		
		/**
		 * 下方向に移動し続けるかを設定します。
		 * @param value	true の場合は移動が有効になります。
		 */
		public function togglePitchDown(value:Boolean):void
		{
			_pitchDown = value
		}
		
		/**
		 * 上方向に移動し続けるかを設定します。
		 * @param value	true の場合は移動が有効になります。
		 */
		public function togglePitchUp(value:Boolean):void
		{
			_pitchUp = value
		}
		
		/**
		 * 左方向に移動し続けるかを設定します。
		 * @param value	true の場合は移動が有効になります。
		 */
		public function toggleYawLeft(value:Boolean):void
		{
			_yawLeft = value;
		}
		
		/**
		 * 右方向に移動し続けるかを設定します。
		 * @param value	true の場合は移動が有効になります。
		 */
		public function toggleYawRight(value:Boolean):void
		{
			_yawRight = value;
		}
		
		/**
		 * 中心方向に移動し続けるかを設定します。
		 * @param value	true の場合は移動が有効になります。
		 */
		public function toggleForward(value:Boolean):void
		{
			_zoomIn = value;
		}
		
		/**
		 * 中心と反対方向に移動し続けるかを設定します。
		 * @param value	true の場合は移動が有効になります。
		 */
		public function toggleBackward(value:Boolean):void
		{
			_zoomOut = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			const RADIAN:Number = Math.PI / 180;
			var oldAngleLatitude:Number = _angleLatitude;
			var oldAngleLongitude:Number = _angleLongitude;
			var oldLengh:Number = _lastZoom;
			
			//CameraZoom制御
			if (_zoomIn)
				_lastZoom -= _fovSpeed;
			else if (_zoomOut)
				_lastZoom += _fovSpeed;
			
			// ズーム制御
			if (_taregetDistanceValue != 0)
			{
				_lastZoom += _taregetDistanceValue;
				_taregetDistanceValue = 0;
			}
			
			if (_lastZoom < minFov)
				_lastZoom = minFov;
			else if (_lastZoom > maxFov)
				_lastZoom = maxFov;
			if (_lastZoom - _zoom)
				_zoom += (_lastZoom - _zoom) / _easingSeparator;
			
			if (Math.abs(_lastZoom - _zoom) < ROUND_VALUE / 100)
				_zoom = _lastZoom;
			
			//Camera回転制御
			if (_mouseMove)
				_lastLongitude = _oldLongitude + (_mouseDownEventSource.mouseX - _mouseX) * _mouseSensitivityX
			else if (_yawLeft)
				_lastLongitude += _yawSpeed;
			else if (_yawRight)
				_lastLongitude -= _yawSpeed;
			
			if (_taregetYawValue)
			{
				_lastLongitude += _taregetYawValue;
				_taregetYawValue = 0;
			}
			
			if (_lastLongitude - _angleLongitude)
				_angleLongitude += (_lastLongitude - _angleLongitude) / _easingSeparator;
			
			if (Math.abs(_lastLatitude - _angleLatitude) < ROUND_VALUE)
				_angleLatitude = _lastLatitude;
			
			//CameraZ位置制御
			if (_mouseMove)
				_lastLatitude = _oldLatitude + (_mouseDownEventSource.mouseY - _mouseY) * _mouseSensitivityY;
			else if (_pitchDown)
				_lastLatitude -= _pitchSpeed;
			else if (_pitchUp)
				_lastLatitude += _pitchSpeed;
			
			if (_taregetPitchValue)
			{
				_lastLatitude += _taregetPitchValue;
				_taregetPitchValue = 0;
			}
			
			// 最大緯度と最小緯度の間に抑える
			_lastLatitude = Math.max(minLatitude, Math.min(_lastLatitude, maxLatitude));
			
			if (_lastLatitude - _angleLatitude)
				_angleLatitude += (_lastLatitude - _angleLatitude) / _easingSeparator;
			if (Math.abs(_lastLongitude - _angleLongitude) < ROUND_VALUE)
				_angleLongitude = _lastLongitude;
			
			var vec3d:Vector3D = this.translateGeoCoords(_angleLatitude, _angleLongitude, 100);
			
			if (_target is Camera3D)
				Camera3D(_target).fov = _zoom;
			
			//super.update()
			updateObjectTransform()
			lookAt(vec3d);
			
			_needsRendering = oldAngleLatitude != _angleLatitude
				|| oldAngleLongitude != _angleLongitude
				|| oldLengh != _zoom;
		}
		
		/** @private */
		override public function startMouseLook():void
		{
			// 封印
		}
		
		/** @private */
		override public function stopMouseLook():void
		{
			// 封印
		}
		
		/**
		 * 経度を設定します。
		 * @param value	0で、正面から中央方向(lookAtPosition)を見る
		 * @param immediate	trueで、イージングしないで変更
		 */
		public function setLongitude(value:Number, immediate:Boolean = false):void
		{
			if (immediate)
				_angleLongitude = value;
			_lastLongitude = value;
		}
		
		/**
		 * 緯度を設定します。
		 * @param value	0で、正面から中央方向(lookAtPosition)を見る
		 * @param immediate	trueで、イージングしないで変更
		 */
		public function setLatitude(value:Number, immediate:Boolean = false):void
		{
			// 最大緯度、最小緯度の範囲に丸める
			value = Math.max(minLatitude, Math.min(maxLatitude, value));
			
			if (immediate)
				_angleLatitude = value;
			_lastLatitude = value;
		}
		
		/**
		 * Cameraから、targetObjectまでの距離を設定します。
		 * @param value	Cameraから、targetObjectまでの距離
		 * @param immediate trueで、イージングしないで変更
		 */
		public function setDistance(value:Number, immediate:Boolean = false):void
		{
			if (immediate)
				_zoom = value;
			_lastZoom = value;
		}
		
		/**
		 * オブジェクトを使用不可にしてメモリを解放します。
		 */
		public function dispose():void
		{
			// イベントの解放
			if (_mouseDownEventSource)
				_mouseDownEventSource.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			// マウスホイール操作
			if (_mouseDownEventSource)
				_mouseDownEventSource.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			
			// キーボード操作
			if (_keyEventSource)
			{
				_keyEventSource.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
				_keyEventSource.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			}
			
			// プロパティーの解放
			_easingSeparator = 0;
			maxFov = 0;
			minFov = 0;
			_mouseSensitivityX = 0;
			_mouseSensitivityY = 0;
			multiplyValue = 0;
			_needsRendering = false;
			_pitchSpeed = 0;
			useHandCursor = false;
			_yawSpeed = 0;
			_angleLatitude = 0;
			_angleLongitude = 0;
			_fovSpeed = 0;
			_keyEventSource = null;
			_lastLatitude = 0;
			_lastZoom = 0;
			_lastLongitude = 0;
			_zoom = 0;
			_mouseDownEventSource = null;
			_mouseMove = false;
			_mouseUpEventSource = null;
			_mouseX = 0;
			_mouseY = 0;
			_oldLatitude = 0;
			_oldLongitude = 0;
			_pitchDown = false;
			_pitchUp = false;
			_taregetDistanceValue = 0;
			_taregetPitchValue = 0;
			_taregetYawValue = 0;
			_target = null;
			_yawLeft = false;
			_yawRight = false;
			_zoomIn = false;
			_zoomOut = false;
		}
		
		/**
		 * 自動的に適切なキーを割り当てます。
		 */
		public function bindBasicKey():void
		{
			bindKey(Keyboard.LEFT, SimpleObjectController.ACTION_YAW_LEFT);
			bindKey(Keyboard.RIGHT, SimpleObjectController.ACTION_YAW_RIGHT);
			bindKey(Keyboard.DOWN, SimpleObjectController.ACTION_PITCH_DOWN);
			bindKey(Keyboard.UP, SimpleObjectController.ACTION_PITCH_UP);
			bindKey(Keyboard.PAGE_UP, OrbitCameraController.ACTION_BACKWARD);
			bindKey(Keyboard.PAGE_DOWN, OrbitCameraController.ACTION_FORWARD);
		}
		
		protected function mouseDownHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			
			_oldLongitude = _lastLongitude;
			_oldLatitude = _lastLatitude;
			_mouseX = _mouseDownEventSource.mouseX;
			_mouseY = _mouseDownEventSource.mouseY;
			_mouseMove = true;
			
			if (useHandCursor)
				Mouse.cursor = MouseCursor.HAND;
			
			_mouseUpEventSource.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		protected function mouseUpHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			
			if (useHandCursor)
				Mouse.cursor = MouseCursor.AUTO;
			
			_mouseMove = false;
			_mouseUpEventSource.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function keyDownHandler(event:KeyboardEvent):void
		{
			for (var key:String in keyBindings)
			{
				if (String(event.keyCode) == key)
					keyBindings[key](true)
			}
		}
		
		private function keyUpHandler(event:KeyboardEvent = null):void
		{
			for (var key:String in keyBindings)
				keyBindings[key](false)
		}
		
		private function mouseWheelHandler(event:MouseEvent):void
		{
			_lastZoom -= event.delta * 0.01;
			if (_lastZoom < minFov)
				_lastZoom = minFov
			else if (_lastZoom > maxFov)
				_lastZoom = maxFov
		}
		
		/**
		 * 経度と緯度から位置を算出します。
		 * @param latitude	緯度
		 * @param longitude	経度
		 * @param radius	半径
		 * @return 位置情報
		 */
		private function translateGeoCoords(latitude:Number, longitude:Number, radius:Number):Vector3D
		{
			const latitudeDegreeOffset:Number = 90;
			const longitudeDegreeOffset:Number = 90;
			
			latitude = Math.PI * latitude / 180;
			longitude = Math.PI * longitude / 180;
			
			latitude -= (latitudeDegreeOffset * (Math.PI / 180));
			longitude -= (longitudeDegreeOffset * (Math.PI / 180));
			
			var x:Number = radius * Math.sin(latitude) * Math.cos(longitude);
			var y:Number = radius * Math.cos(latitude);
			var z:Number = radius * Math.sin(latitude) * Math.sin(longitude);
			
			return new Vector3D(x, z, y);
		}
	}
}
