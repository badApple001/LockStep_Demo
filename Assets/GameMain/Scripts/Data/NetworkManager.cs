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


   

        private AEPhysicsMgr m_AEPhysicsMgr;

        [SerializeField] private string m_serverIP;
        [SerializeField] private int m_port;


        [SerializeField] private int m_FPS;
        
        //��λ�� ��������ϴ�����
        private float m_upLoadInterval;
        private float m_timer;

        //��֡
        private int m_curFrame;
        private bool m_reciveFromLastUpLoad;


        private void InitScene( )
        {

            var colliders = GameObject.FindObjectsByType<BaseCollider>( FindObjectsSortMode.None );
            AEDebug.Log( $"����AE��ײ��: ${colliders.Length}" );

            m_AEPhysicsMgr = new AEPhysicsMgr( new BEPUutilities.Vector3( 0, -20m, 0 ) );
            foreach ( var VARIABLE in colliders )
            {
                m_AEPhysicsMgr.RegisterCollider( VARIABLE );
            }

            RoomManager.Instance.Setup( m_AEPhysicsMgr, SyncPrefabs );
            RoomManager.Instance.NetEntityParent = EntitysParent;
        }


        public void StartConnect( )
        {
            NetAsyncMgr.ClearNetMessageListener( );
            m_curFrame = -1;
            m_timer = 0;
            m_upLoadInterval = ( 1f / m_FPS ).ToFix64( ).ToFloat( );
            
            InitScene( );

            NetAsyncMgr.AddNetMessageListener( MessagePool.UpdateMessage_ID, ReciveUpdateMessage );
            NetAsyncMgr.SetMaxMessageFire( m_FPS );
            NetAsyncMgr.Connect( m_serverIP, m_port );
        }



        public void JoinRoom( )
        {
            AEDebug.Log( "���뷿��" );
            RoomManager.Instance.JoinRoom( );
        }

        public void StartGame( )
        {
            AEDebug.Log( "��ʼͬ��" );
            RoomManager.Instance.StartGame( );
        }
  

        private void Update( )
        {
            NetAsyncMgr.FireMessage( );
            if ( !NetAsyncMgr.IsConnected ) return;
            if ( m_curFrame == -1 ) return;
            m_AEPhysicsMgr.UpdatePosition( );
            Upload( Time.deltaTime );
        }

        /// <summary>
        /// ����֡����
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
                m_AEPhysicsMgr.PhysicsUpdate( updateDate.Delta );
            }

            AEDebug.Log( updateDate.Delta );
            AEDebug.Log( "���յ���:" + updateDate.CurFrameIndex + "֡����" );
        }

        /// <summary>
        /// �ϴ������Ϣ
        /// </summary>
        private void Upload( float delta )
        {
            //���û�н��յ���ǰ֡��ȴ�
            if ( RoomManager.Instance.SelfNetId == -1 ) return;
            if ( !m_reciveFromLastUpLoad ) return;
            m_timer += delta;
            if ( m_timer >= m_upLoadInterval )
            {
                m_timer = 0;
                UpLoad( );
                AEDebug.Log( "����:" + ( m_curFrame + 1 ) + "֡����" );
                m_reciveFromLastUpLoad = false;
            }
        }

        /// <summary>
        /// �ϴ������Ϣ
        /// </summary>
        private void UpLoad( )
        {
            UpLoadMessage upLoadMsg = new UpLoadMessage( );
            var playerInput = upLoadMsg.data;

            playerInput.JoyX = Input.GetAxis( "Horizontal" );
            playerInput.JoyY = Input.GetAxis( "Vertical" );
            playerInput.PlayerID = RoomManager.Instance.SelfNetId;
            playerInput.CurFrameIndex = m_curFrame + 1;

            NetAsyncMgr.Send( upLoadMsg );
            AEDebug.Log( "�ϴ���" + playerInput.CurFrameIndex + "֡������" + playerInput.JoyX + "..." + playerInput.JoyY );
        }

      

    }

}