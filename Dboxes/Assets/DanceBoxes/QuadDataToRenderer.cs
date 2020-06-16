﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DanceBoxes
{
	public class QuadDataToRenderer : MonoBehaviour, IWantQuadData
	{
		public const int READ = 1;
		public const int WRITE = 0;

		ComputeBuffer[] quadDataBuffer;//gets this from a different class
		ComputeBuffer quadArgBuffer;

		public Material material;

		void Start()
		{
			quadArgBuffer = new ComputeBuffer(4, sizeof(int), ComputeBufferType.IndirectArguments);
			int[] args = new int[] { 0, 1, 0, 0 };
			quadArgBuffer.SetData(args);
		}

		void IWantQuadData.GiveQuadData(ComputeBuffer[] quadDataAndAges)
		{
			this.quadDataBuffer = quadDataAndAges;
		}


		MaterialPropertyBlock _props;

		void Update()
		{
			if (quadDataBuffer != null)
			{
				ComputeBuffer.CopyCount(quadDataBuffer[READ], quadArgBuffer, 0);
				material.SetPass(0);
				material.SetBuffer("_Data", quadDataBuffer[READ]);
				//BufferTools.DebugComputeRaw<int>(quadArgBuffer, "quadARGEBUFFEr", 4);
				//Graphics.DrawProceduralIndirectNow(MeshTopology.Points, quadArgBuffer, 0);
				/*Graphics.DrawProcedural(
					material,
					new Bounds (DanceBoxManager.inst.renderBoundsCenter, DanceBoxManager.inst.renderBoundsScale),
					MeshTopology.Points, 
					)*/
				if (_props == null) _props = new MaterialPropertyBlock();

				_props.SetBuffer("_Data", quadDataBuffer[READ]);

				Graphics.DrawProceduralIndirect(material,
					new Bounds(DanceBoxManager.inst.renderBoundsCenter, DanceBoxManager.inst.renderBoundsScale),
					MeshTopology.Points, quadArgBuffer, 0, null, _props, UnityEngine.Rendering.ShadowCastingMode.On, true);
			}

		}


		private void OnDisable()
		{
			quadArgBuffer.Dispose();
		}
	}
}
