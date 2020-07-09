using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DanceBoxes
{
	public class DecaySpeedAndGravityRecorder : MonoBehaviour
	{
		public TextAsset recordeddatatextasset;
		VoxelAgeSimulationHandler vsim;
		public bool recordData = true;
		public bool playbackData = false;

		RecordedSettings recordedSettings = new RecordedSettings();
		// Start is called before the first frame update
		void Start()
		{
			vsim = this.GetComponent<VoxelAgeSimulationHandler>();
			if (playbackData && recordeddatatextasset != null)
			{
				recordedSettings = JsonUtility.FromJson<RecordedSettings>(recordeddatatextasset.text);
			}
			//recordedSettings.NullInit();
		}

		float lasttime = 0;
		// Update is called once per frame
		void Update()
		{
			lasttime = (int)Time.time;
			if(recordData)
			{
				Vector2 decayAndGrav = new Vector2(vsim.decaySpeed, vsim.gravity);
				if(recordedSettings.values.Count <= 0 || recordedSettings.values[recordedSettings.values.Count-1] != decayAndGrav)
				{
					recordedSettings.times.Add(Time.time);
					recordedSettings.values.Add(decayAndGrav);
				}
			}
			else if(playbackData)
			{
				Vector2 playback = recordedSettings.GetValueFromTime(Time.time);
				vsim.decaySpeed = playback.x;
				vsim.gravity = (int)(playback.y);
			}
		}



		private void OnDisable()
		{
			if(recordData)
			{
				string tosave = JsonUtility.ToJson(recordedSettings);
				Debug.LogWarning("count: " + recordedSettings.values.Count + " output: \n" + tosave);
				
				System.IO.File.WriteAllText(Application.dataPath + "\\RecordedData" + lasttime + ".json", tosave);
			}
		}
	}

}

[System.Serializable]
public struct RecordedSettings
{
	[SerializeField]
	public List<float> times;
	[SerializeField]
	public List<Vector2> values;


	public void NullInit()
	{
		if (times == null)
			times = new List<float>();
		if (values == null)
			values = new List<Vector2>();
	}

	public Vector2 GetValueFromTime(float intime)
	{
		int i;
		for(i = times.Count-1; i>=0; i--)
		{
			if (intime > times[i])
				break; 
		}
		if (i == -1)
			i = 0;

		return values[i];
	}
}
