using AE_BEPUPhysics_Addition;
using NetGameRunning;
using UnityEngine;

namespace GameScripts
{
    public class NetPlayer : INetEntity
    {
        protected float speed { get; private set; }
        protected GameObject gameobject { get; private set; }
        protected BaseVolumnBaseCollider body { get; private set; }

        public NetPlayer( GameObject gameObject, float velocity )
        {
            gameobject = gameObject;
            body = gameobject.GetComponent<BaseVolumnBaseCollider>( );
            speed = velocity;
        }


        public void OnLogicUpdate( float delta, PlayerInputData playerInput )
        {
            MoveUpdate( delta, playerInput );
        }


        protected virtual void MoveUpdate( float delta, PlayerInputData playerInput )
        {
            var direction = new Vector3( playerInput.JoyX, 0, playerInput.JoyY );
            var tempVelocity = direction * speed;

            var velocity = body.GetVelocity( );
            velocity.x = tempVelocity.x;
            velocity.z = tempVelocity.z;
            body.SetVeolicty( velocity );
        }


    }

}