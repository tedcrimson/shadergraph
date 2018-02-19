using UnityEngine;

public class ChangeObjects : MonoBehaviour
{

    int count = 0;

    int index = 0;

    // Use this for initialization
    void Start()
    {
        count = this.transform.childCount;
		ChangeObject();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            ChangeObject();
        }
    }

    void ChangeObject()
    {
        this.transform.GetChild(index).gameObject.SetActive(false);
        index++;
        if (index % count == 0)
            index = 0;
        this.transform.GetChild(index).gameObject.SetActive(true);
    }
}
