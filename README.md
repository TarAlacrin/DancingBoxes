# DancingBoxes
This is a project I've been working on lately in Unity. It uses HLSL compute shaders to capture mesh data from a vertex shader every frame, and then turn the mesh data into volumetric voxel data, then using an algorithm (marching ants I think?) it turns that voxel data back into triangle mesh data to then be piped into a normal vert-geometry-fragment shader for rendering (written in a combination of HLSL and CgFx). Its mainly just an excersize for me to expiriment and learn more about GPGPU/compute shaders and render pipelines, and also to make something pretty. 

The advantage with this method over other similar methods out there is that no data ever leaves the gpu, so it winds up performing pretty smoothly. 

I'm using Unity's HDRP, which doesn't play well with shaders that aren't written with Shadergraph, but its definitely still possible. Big thanks to Keijiro Takahashi for some of his older repositories which pointed me in the right direction to get things like HDR and bloom connected with the rest of the pipeline properly. 

The code is a bit of a mess right now, but I'm going to do a full writeup talking about all the hurdles I encountered making this and how I overcame them on my blog at https://samd.biz so I'll clean up my code for that and put a link to that here when its done.

You can see a video of it in action here:
https://youtu.be/OawOQ55m0x4

