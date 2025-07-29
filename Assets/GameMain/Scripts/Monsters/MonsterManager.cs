using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MonsterManager : MonoBehaviour
{

    public Transform MonsterSpawnPoint;
    public Transform EntityRoot;
    public GameObject MonsterPrefab;
    public Transform MonsterDestination;




    private IEnumerator Start( )
    {

        while ( true )
        {
            var pos = MonsterSpawnPoint.position;
            var monster = GameObject.Instantiate( MonsterPrefab, pos, Quaternion.identity, EntityRoot );
            monster.GetComponent<Destination>( ).dest = MonsterDestination;
            yield return new WaitForSeconds( Random.Range( 0.5f, 3f ) );
        }

    }



}
