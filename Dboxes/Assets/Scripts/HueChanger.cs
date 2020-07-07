using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HueChanger : MonoBehaviour
{
	Material rendermat;


    // Start is called before the first frame update
    void Start()
    {
		rendermat = this.gameObject.GetComponent<DanceBoxes.QuadDataToRenderer>().material;
    }



	void Wheel(string valueName, float toChange)
	{
		Color em1 = rendermat.GetColor(valueName);
		float H;
		float S;
		float V;
		Color.RGBToHSV(em1, out H, out S, out V);
		Debug.Log(em1 + " >>> " + H + ", " + S + " , " + V);
		H += 3f;

		em1 = Color.HSVToRGB(H, S, V, true);
		rendermat.SetColor(valueName, em1);
	}

	// Update is called once per frame
	void Update()
    {
        

	}
}
