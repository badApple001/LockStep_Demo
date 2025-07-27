using AE_BEPUPhysics_Addition;
using NetGameRunning;
using UnityEngine;

namespace GameScripts
{
    public class NetEntity : INetEntity
    {
        public GameObject gameObject { get; private set; }
        public BaseVolumnBaseCollider body { get; private set; }
        public int NetId { get; set; }


        public virtual void Init( GameObject gameObject  )
        {
            this.gameObject = gameObject;
            body = this.gameObject.GetComponent<BaseVolumnBaseCollider>( );
            OnInit( );
        }


        public virtual void OnInit( ) { }

        public virtual void OnLogicUpdate( float delta, PlayerInputData playerInput ) { }
    }

}