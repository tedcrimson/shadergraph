using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class jiggle : MonoBehaviour {

	Vector3 startposition;
	public float JiggleWiggle;
	// Use this for initialization
	void Start () {
		startposition = this.transform.position;
	}
	
	// Update is called once per frame
	void Update () {
		transform.position = startposition + new Vector3(Mathf.Sin(Time.time)/JiggleWiggle,Mathf.Cos(Time.time)/JiggleWiggle,Mathf.Cos(Time.time)/JiggleWiggle);
	}
}
