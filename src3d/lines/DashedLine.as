package src3d.lines
{
	import away3d.core.geom.Path;
	import away3d.extrusions.PathExtrusion;
	
	import flash.geom.Vector3D;

	public class DashedLine extends SimpleLine
	{
		public function DashedLine(useBorder:Boolean)
		{
			super(useBorder);
		}
		
		protected override function getMainLine(path:Path):void {
			var slicedPath:SlicedPath = new SlicedPath(path, 30, 20, 50);
			if (slicedPath.slices.length == 0) return;
			var newVVector3D:Vector.<Vector3D> = slicedPath.slices;
			if (newVVector3D.length == 0) return;
			//F11 var vExtrudes:Vector.<Mesh> = new Vector.<Mesh>();
			var tempExtrude:PathExtrusion = new PathExtrusion();
			tempExtrude.profile = this.profile;
			// Add the first segment to the path. Then merge the rest of segments.
			this.path = new Path([newVVector3D[0], newVVector3D[1], newVVector3D[2]]);
			for (var i:int = 3;i<newVVector3D.length;i+=3) {
				tempExtrude.path = new Path([newVVector3D[i], newVVector3D[i+1], newVVector3D[i+2]]);
				merge.apply(this, tempExtrude);
				//F11 vExtrudes.push( new PathExtrusion(null, new Path(new <Vector3D>[newVVector3D[i], newVVector3D[i+1], newVVector3D[i+2]])) as Mesh );
				
			}
			//F11 merge.apply(this, vExtrudes);
		}
		
		
	}
}