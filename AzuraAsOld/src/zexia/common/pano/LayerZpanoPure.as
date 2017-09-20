package zexia.common.pano
{
	import azura.banshee.engine.Statics;
	
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapCubeTexture;
	
	import azura.banshee.engine.Stage3DLayerI;
	import azura.banshee.engine.Stage3DRoot;
	import azura.banshee.engine.a3d.A3dLayer;
	import azura.banshee.layers.zpano.ZpanoLoader;
	import azura.common.collections.ZintBuffer;
	import azura.touch.mouserOld.MouserDrag;
	import azura.gallerid4.Gal4;
	
	import flash.display.BitmapData;
	import flash.display.Stage;
	
	public class LayerZpanoPure implements Stage3DLayerI
	{
		internal var al:A3dLayer;
		
		private var bgLayer:ObjectContainer3D;
		
		//bg		
		private var cubeTexture:BitmapCubeTexture;
		private var _skyBox:SkyBox; 
		private var mc53:Vector.<String>;
		private var img6:Vector.<BitmapData>;
		private var currentSize:int;
		
		//navigation
		internal var dragging:Boolean;
		internal var downPanAngle:Number=0;
		internal var downTiltAngle:Number=0;
		internal var downMouseX:Number=0;
		internal var downMouseY:Number=0;
		public var mouseX:Number=0;
		public var mouseY:Number=0;
		
		private var md:MouserDrag;
		private var mm:MouseMove;
		
		public var tiltSpeed:Number=0.5;
		
		private var _fov:Number=80;
		
		public function LayerZpanoPure(al:A3dLayer){
			this.al=al;
			Stage3DRoot.singleton().addLayer(this);
			
			md=new MouserDrag(Statics.stage,false);
			mm=new MouseMove(this);
			md.listener=mm;
		}
		
		public function get fov():Number
		{
			return _fov;
		}

		public function set fov(value:Number):void
		{
			_fov = value;
			_fov=Math.max(_fov,50);
			_fov=Math.min(_fov,100);
			PerspectiveLens(al.view.camera.lens).fieldOfView=_fov;
		}
		
		public function init(stage:Stage):void{
			bgLayer=new ObjectContainer3D();
			al.view.scene.addChild(bgLayer);
			al.view.camera.lens = new PerspectiveLens (_fov);  
		}
		
		public function enterFrame():void{
			if (dragging)
			{
				al.camera.panAngle = (-0.2 * (mouseX - downMouseX) + downPanAngle);
				al.camera.tiltAngle = (-0.2 * (mouseY - downMouseY) * tiltSpeed + downTiltAngle);
			}
			al.enterFrame();
		}
		
		public function mouseMoveDelta(dx:int,dy:int):void{
			mm.dragMove(mouseX+dx,mouseY+dy);
			//			dragging=true;
			//			mouseX+=dx;
			//			mouseY+=dy;
		}
		
		public function load(data:ZintBuffer):void{
			currentSize=0;
			img6=new Vector.<BitmapData>(6);
			mc53=new Vector.<String>();
			
			for(var j:int=0;j<3;j++){
				mc53.push(data.readUTFZ());
			}
			
			stepLoading();
		}
		
		private function stepLoading():void{
			
			img6=new Vector.<BitmapData>(6);
			Gal4.readAsync(mc53[currentSize],fileLoaded);
			
			function fileLoaded(item:Gal4):void{
				for(var i:int=0;i<6;i++){
					new ZpanoLoader(mc53[currentSize],i,item.data.readBytesZ()).load(onBitmapReady);
				}						
			}
			
			function onBitmapReady(ll:ZpanoLoader):void{
				img6[ll.direction]=ll.value as BitmapData;
				check6();
			}
		}
		
		private function check6():void{
			var all:Boolean=true;
			for(var i:int=0;i<6;i++){
				if(img6[i]==null)
					all=false;
			}
			
			if(all){
				clearSky();
				
				cubeTexture=new BitmapCubeTexture(img6[0],img6[1],img6[2],img6[3],img6[4],img6[5]);
				_skyBox = new SkyBox(cubeTexture);
				
				bgLayer.addChild(_skyBox);
				
				if(currentSize<2){
					currentSize++;
					stepLoading();
				}
			}
		}
		
		private function clearSky():void{
			dragging=false;
			if(_skyBox!=null){
				bgLayer.removeChild(_skyBox);
				_skyBox.dispose();
				_skyBox=null;
				cubeTexture.dispose();
			}
		}
		
		public function clear():void{
		}
		
		public function dispose():void{
			clearSky();
			bgLayer.dispose();
			Stage3DRoot.singleton().removeLayer(this);
		}
		
		public function lookAt(x:int,y:int):void{
			al.camera.tiltAngle=x;
			al.camera.panAngle=y;
		}
	}
}