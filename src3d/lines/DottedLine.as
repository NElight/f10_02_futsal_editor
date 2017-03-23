package src3d.lines
{
	import away3d.core.geom.Path;
	import away3d.primitives.RegularPolygon;
	
	import flash.geom.Vector3D;

	public class DottedLine extends DashedLine
	{
		public function DottedLine(useBorder:Boolean)
		{
			super(useBorder);
		}
		
		protected override function getMainLine(path:Path):void {
			var slicedPath:SlicedPath = new SlicedPath(path, 15, 15, 50);
			if (slicedPath.slices.length == 0) return;
			var newVVector3D:Vector.<Vector3D> = slicedPath.slices;
			if (newVVector3D.length == 0) return;
			//F11 var vExtrudes:Vector.<Mesh> = new Vector.<Mesh>();
			//var dot:Sphere = new Sphere(null, this._lineThickness, 8,8,false);
			var dot:RegularPolygon = new RegularPolygon({sides:8, radius:this._lineThickness, visible:true, name:"Dot"});
			
			//F11 this.path = new Path(new <Vector3D>[newVVector3D[0], newVVector3D[0], newVVector3D[0]]);
			this.path = new Path([newVVector3D[0], newVVector3D[0], newVVector3D[0]]);
			for (var i:int = 0;i<newVVector3D.length;i+=3) {
				dot.position = newVVector3D[i];
				merge.apply(this, dot);
				//F11 vExtrudes.push(dot.clone() as Mesh);
			}
			//F11 merge.apply(this, vExtrudes);
		}
	}
}