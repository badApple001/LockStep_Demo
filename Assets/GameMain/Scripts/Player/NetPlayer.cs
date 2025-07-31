using AE_BEPUPhysics_Addition;
using NetGameRunning;
using UnityEngine;

namespace GameScripts
{

    public interface INetPlayer 
    {
        int playerId { get; set; }  
        float velocity { get; set; }
        GameObject gameObject { get; }
        BaseVolumnBaseCollider body { get; }

        void Init( GameObject gameObject );
        void OnLogicUpdate( float delta, PlayerInputData playerInput );
    }

    public class NetPlayer : INetPlayer
    {
        public float velocity { get; set; }
        public int playerId { get; set; }
        public GameObject gameObject { get; private set; }
        public BaseVolumnBaseCollider body { get; private set; }

        public virtual void Init( GameObject gameObject )
        {
            this.gameObject = gameObject;
            body = this.gameObject.GetComponent<BaseVolumnBaseCollider>( );
            OnInit( );
        }

        public virtual void OnInit( ) { }


        public virtual void OnLogicUpdate( float delta, PlayerInputData playerInput )
        {
            MoveUpdate( delta, playerInput );
        }


        protected virtual void MoveUpdate( float delta, PlayerInputData playerInput )
        {
            var direction = new Vector3( playerInput.JoyX, 0, playerInput.JoyY );
            var tempVelocity = direction * this.velocity;

            var velocity = body.GetVelocity( );
            velocity.x = tempVelocity.x;
            velocity.z = tempVelocity.z;
            body.SetVeolicty( velocity );
            //gameObject.transform.Rotate( Vector3.up * 10 * Time.deltaTime * playerInput.CamX + Vector3.right * 10 * Time.deltaTime * playerInput.CamY );
        }
    }
}
