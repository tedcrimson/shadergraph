using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Emitter : MonoBehaviour {

	public ParticleSystem.EmissionModule emission;
	// Use this for initialization
	void Start () {
		emission = GetComponent<ParticleSystem>().emission;
	}
	
	// Update is called once per frame
	void Update () {
		if(Input.GetKey(KeyCode.B))
		{
			emission.enabled = true;
		}else if(emission.enabled)
			emission.enabled = false;
		// emission.enabled = Input.GetKey(KeyCode.B);
	}
}
