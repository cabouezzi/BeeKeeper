#  Notes
Process for exporting from Blender to SceneKit
* When rigging model, use parenting as opposed to vertex weights
    * This allows avoiding needing to re-weight when changing geometry in game
* Make sure origin of meshes align with the root of the parent bone
    * This will result in defects in exporting (likely bug in Blender). Manually set *position* to 0 in scene editor
* Export .dae file, check `Main/Global Orientation/Apply`, set `Forward: -Z, Up: Y`
* Uncheck `Geom/Apply Modifiers`, set `Geom/Transform` to `Matrix`
* Run the python script `ColladaAnimationForXcode` for .dae files containing an animation
* Convert to .scn file, have parent node rotate for

*always* work in .scn files, seems like SceneKit does some modifications to .dae files under the hood
