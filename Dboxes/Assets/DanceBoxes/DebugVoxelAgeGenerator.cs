using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DanceBoxes
{
	public class DebugVoxelAgeGenerator : MonoBehaviour
	{

		public bool debug = false;
		public const int READ = 1;
		public const int WRITE = 0;


		public ComputeShader voxelAgeGenerator;
		public GameObject voxelAgeRecipientObject;
		IWantVoxelAges voxelAgeRecipient;

		ComputeBuffer[] filledVoxelGridBuffer = new ComputeBuffer[2];

		public const string _vgKernelName = "CSMain"; //"CSBlockMain";//"CSTwirl";
		public int vgkernal
		{
			get
			{
				return voxelAgeGenerator.FindKernel(_vgKernelName);
			}
		}

		void Start()
		{
			filledVoxelGridBuffer[READ] = new ComputeBuffer(DanceBoxManager.inst.totalVoxels, DanceBoxManager.inst.sizeOfVoxelData, ComputeBufferType.Default);
			filledVoxelGridBuffer[WRITE] = new ComputeBuffer(DanceBoxManager.inst.totalVoxels, DanceBoxManager.inst.sizeOfVoxelData, ComputeBufferType.Default);
			voxelAgeRecipient = voxelAgeRecipientObject.GetComponent<IWantVoxelAges>();
			voxelAgeGenerator.SetVector("_Dimensions", DanceBoxManager.inst.voxelDimensions4);
			voxelAgeGenerator.SetVector("_InvDimensions", DanceBoxManager.inst.inverseVoxelDimensions4);
		}
		private void OnDisable()
		{
			filledVoxelGridBuffer[READ].Dispose();
			filledVoxelGridBuffer[WRITE].Dispose();
		}

		void Update()
		{
			BufferTools.Swap(filledVoxelGridBuffer);

			voxelAgeGenerator.SetBuffer(vgkernal, "WVoxelAgeBuffer", filledVoxelGridBuffer[WRITE]);
			voxelAgeGenerator.Dispatch(vgkernal, DanceBoxManager.inst.totalVoxelsThreadGroup, 1, 1);// DanceBoxManager.inst.voxelDimX, DanceBoxManager.inst.voxelDimY, DanceBoxManager.inst.voxelDimZ);
			voxelAgeGenerator.SetFloat("_Time", Time.time);
			if (debug)
			{
				Debug.Log("Running");
				BufferTools.DebugComputeGrid<float>(filledVoxelGridBuffer[READ], "output voxel ages READ", DanceBoxManager.inst.singleDimensionCount);
			}

			voxelAgeRecipient.GiveSwappedVoxelAgeBuffer(filledVoxelGridBuffer[READ]);
		}

		private void LateUpdate()
		{
		}
	}

}
