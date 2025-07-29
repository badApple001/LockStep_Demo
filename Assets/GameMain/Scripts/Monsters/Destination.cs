using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Destination : MonoBehaviour
{
    public Transform dest;
    

    private void Start( )
    {

        var nma = GetComponent<NavMeshAgent>( );
        nma.SetDestination( dest.position );
    }

    private void Update( )
    {
        if( GetComponent<NavMeshAgent>( ).isStopped )
        {
            GameObject.Destroy( gameObject );
        }
    }
}
