using AE_BEPUPhysics_Addition;
using AE_BEPUPhysics_Addition.Interface;
using AE_ClientNet;
using AE_NetMessage;
using NetGameRunning;
using System.Collections.Generic;
using UnityEngine;

namespace GameScripts
{

    public class NetworkManager : MonoBehaviour
    {

        public List<GameObject> SyncPrefabs = new List<GameObject>( );
        public Transform EntitysParent;

        public static NetworkManager Instance { private set; get; }

        private void Awake( )
        {
            if ( Instance != null && Instance != this )
            {
                Destroy( gameObject );
                return;
            }

            Instance = this;
            name = "NetworkManager - Singleton";
            DontDestroyOnLoad( gameObject );
        }


        private AEPhysicsMgr _AEPhysicsMgr;

        [SerializeField] private string _ServerIP;
        [SerializeField] private int _Port;
        [SerializeField] private int _SyncRate;

        //单位秒 间隔多少上传数据
        private float m_upLoadInterval;
        private float m_timer;

        //锁帧
        private int m_curFrame;
        private bool m_reciveFromLastUpLoad;


        private void InitScene( )
        {

            var colliders = GameObject.FindObjectsByType<BaseCollider>( FindObjectsSortMode.None );
            AEDebug.Log( $"遍历AE碰撞器: ${colliders.Length}" );

            _AEPhysicsMgr = new AEPhysicsMgr( new BEPUutilities.Vector3( 0, -20m, 0 ) );
            foreach ( var VARIABLE in colliders )
            {
                _AEPhysicsMgr.RegisterCollider( VARIABLE );
            }

            RoomManager.Instance.Setup( _AEPhysicsMgr, SyncPrefabs );
            RoomManager.Instance.NetEntityParent = EntitysParent;
        }


        public void StartConnect( )
        {
            NetAsyncMgr.ClearNetMessageListener( );
            m_curFrame = -1;
            m_timer = 0;
            m_upLoadInterval = 1f / _SyncRate;

            InitScene( );

            NetAsyncMgr.AddNetMessageListener( MessagePool.UpdateMessage_ID, ReciveUpdateMessage );
            NetAsyncMgr.SetMaxMessageFire( _SyncRate );
            NetAsyncMgr.Connect( _ServerIP, _Port );
        }



        public void JoinRoom( )
        {
            AEDebug.Log( "加入房间" );
            RoomManager.Instance.JoinRoom( );
        }

        public void StartGame( )
        {
            AEDebug.Log( "开始同步" );
            RoomManager.Instance.StartGame( );
        }


        private void Update( )
        {
            NetAsyncMgr.FireMessage( );
            if ( !NetAsyncMgr.IsConnected ) return;
            if ( m_curFrame == -1 ) return;
            _AEPhysicsMgr.UpdatePosition( );
            Upload( Time.deltaTime );
        }

        /// <summary>
        /// 接收帧数据
        /// </summary>
        /// <param name="msg"></param>
        private void ReciveUpdateMessage( BaseMessage msg )
        {
            var updateMessage = msg as UpdateMessage;
            var updateDate = updateMessage.data;
            if ( updateDate.CurFrameIndex == m_curFrame + 1 )
            {
                m_curFrame = updateDate.CurFrameIndex;
                m_reciveFromLastUpLoad = true;
                RoomManager.Instance.OnLogincUpdate( updateDate );
                _AEPhysicsMgr.PhysicsUpdate( updateDate.Delta );
            }

            AEDebug.Log( "接收到第:" + updateDate.CurFrameIndex + "帧数据  " + updateDate.Delta.ToString( ) );
        }

        /// <summary>
        /// 上传玩家消息
        /// </summary>
        private void Upload( float delta )
        {
            //如果没有接收到当前帧则等待
            if ( RoomManager.Instance.SelfNetId == -1 ) return;
            if ( !m_reciveFromLastUpLoad ) return;
            m_timer += delta;
            if ( m_timer >= m_upLoadInterval )
            {
                m_timer = 0;
                UpLoad( );
                AEDebug.Log( "发布:" + ( m_curFrame + 1 ) + "帧数据" );
                m_reciveFromLastUpLoad = false;
            }
        }

        private Vector3 oldMousePos = Vector3.zero;
        /// <summary>
        /// 上传玩家消息
        /// </summary>
        private void UpLoad( )
        {
            UpLoadMessage upLoadMsg = new UpLoadMessage( );
            var playerInput = upLoadMsg.data;

            if( oldMousePos != Input.mousePosition )
            {
                var delta = Input.mousePosition - oldMousePos;
                var dir = delta.normalized;
                playerInput.CamX = Mathf.FloorToInt( dir.x * 1000 ) / 1000f;
                playerInput.CamY = Mathf.FloorToInt( dir.y * 1000 ) / 1000f;
            }

            playerInput.JoyX = Input.GetAxis( "Horizontal" );
            playerInput.JoyY = Input.GetAxis( "Vertical" );
            playerInput.PlayerID = RoomManager.Instance.SelfNetId;
            playerInput.CurFrameIndex = m_curFrame + 1;

            NetAsyncMgr.Send( upLoadMsg );
            AEDebug.Log( "上传第" + playerInput.CurFrameIndex + "帧的数据" + playerInput.JoyX + "..." + playerInput.JoyY );
        }



    }

}