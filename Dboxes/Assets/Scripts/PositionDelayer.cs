using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PositionDelayer : MonoBehaviour
{
	public Transform targetAnchor;
	public int numberOfFrameDelays = 3;

	List<Vector3> previousPositions = new List<Vector3>();
	List<Quaternion> previousRotations = new List<Quaternion>();
    // Update is called once per frame
    void LateUpdate()
    {
		this.transform.position = AddAndGetCurrentPosition();
		this.transform.rotation = AddAndGetCurrentQuaternion();
    }

	Vector3 AddAndGetCurrentPosition()
	{
		previousPositions.Add(targetAnchor.position);

		Vector3 toreturn = previousPositions[0];

		if (previousPositions.Count >= numberOfFrameDelays)
			previousPositions.RemoveAt(0);
		if (previousPositions.Count >= numberOfFrameDelays)
			previousPositions.RemoveAt(0);

		return toreturn;
	}



	Quaternion AddAndGetCurrentQuaternion()
	{
		previousRotations.Add(targetAnchor.rotation);

		Quaternion toreturn = previousRotations[0];

		if (previousRotations.Count >= numberOfFrameDelays)
			previousRotations.RemoveAt(0);
		if (previousRotations.Count >= numberOfFrameDelays)
			previousRotations.RemoveAt(0);

		return toreturn;
	}

}
