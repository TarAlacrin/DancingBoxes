using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DanceBoxes
{
	public class decayspeedadjuster : MonoBehaviour
	{
		VoxelAgeSimulationHandler vash;
		public ComputeShader alternateComputeSim;
		// Start is called before the first frame update
		void Start()
		{
			vash = this.GetComponent<VoxelAgeSimulationHandler>();
		}

		// Update is called once per frame
		void Update()
		{
			if (Input.GetKeyDown(KeyCode.RightArrow))
				vash.decaySpeed += 0.1f;
			else if (Input.GetKeyDown(KeyCode.LeftArrow))
				vash.decaySpeed -= 0.1f;


			if (Input.GetKeyDown(KeyCode.UpArrow))
				vash.gravity -=1;
			else if (Input.GetKeyDown(KeyCode.DownArrow))
				vash.gravity += 1;



			if(Input.GetKeyDown(KeyCode.Tab))
			{
				ComputeShader alt = alternateComputeSim;
				alternateComputeSim = vash.cubeAgeSimulationShader;
				vash.cubeAgeSimulationShader = alt;
			}
		}
	}

}
