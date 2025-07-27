using NetGameRunning;
using UnityEngine;

namespace GameScripts
{

    public interface INetPlayer : INetEntity
    {
        float speed { get; set; }
    }

    public class NetPlayer : NetEntity, INetPlayer
    {
        public float speed { get; set; }


        public override void OnLogicUpdate( float delta, PlayerInputData playerInput )
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
            //gameObject.transform.Rotate( Vector3.up * 10 * Time.deltaTime * playerInput.CamX + Vector3.right * 10 * Time.deltaTime * playerInput.CamY );
        }
    }
}
