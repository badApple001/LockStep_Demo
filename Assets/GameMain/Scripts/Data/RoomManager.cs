using AE_BEPUPhysics_Addition;
using AE_ClientNet;
using AE_NetMessage;
using NetGameRunning;
using System.Collections.Generic;
using UnityEngine;


namespace GameScripts
{


    public interface INetEntity
    {

        void OnLogicUpdate( float delta, PlayerInputData playerInput );
    }

    /// <summary>
    /// �������
    /// </summary>
    public class RoomManager
    {

        /// <summary>
        /// Ψһ����
        /// </summary>
        public static RoomManager Instance { private set; get; } = new RoomManager( );
        
        /// <summary>
        /// ����Լ���NetId
        /// </summary>
        public int SelfNetId { private set; get; } = -1;

        /// <summary>
        /// Entity���ɵĸ���
        /// </summary>
        public Transform NetEntityParent { set; get; } = null;


        /// <summary>
        /// ����������ģ�������
        /// </summary>
        private AEPhysicsMgr _AEPhysicsMgr;

        /// <summary>
        /// Ԥ���壬��Ҫ��ǰ��NetworkManagerע��ã�ȷ�������ͻ���һһ��Ӧ
        /// </summary>
        private List<GameObject> _SyncPrefabs;

        /// <summary>
        /// ���ж�̬�����Ķ���Entity �ֵ�
        /// </summary>
        private Dictionary<int, INetEntity> _Entitys = new Dictionary<int, INetEntity>( );


        /// <summary>
        /// ��ʼ������
        /// </summary>
        /// <param name="physicsMgr"></param>
        /// <param name="syncPrefabs"></param>
        public void Setup( AEPhysicsMgr physicsMgr, List<GameObject> syncPrefabs )
        {
            Clear( );
            _AEPhysicsMgr = physicsMgr;
            _SyncPrefabs = syncPrefabs;
            NetAsyncMgr.AddNetMessageListener( MessagePool.Res_JoinRoom_ID, Res_JoinRoomMsg );
        }


        /// <summary>
        /// ������
        /// </summary>
        public void Clear( )
        {
            SelfNetId = -1;
            NetEntityParent = null;
            _AEPhysicsMgr = null;
            _SyncPrefabs.Clear( );
            _Entitys.Clear( );

            NetAsyncMgr.RemoveNetMessageListener( MessagePool.Res_JoinRoom_ID, Res_JoinRoomMsg );
        }


        /// <summary>
        /// �߼�����,�ܵ�������Ϣ�����
        /// </summary>
        /// <param name="msg"></param>
        public void OnLogincUpdate( UpdateMessageData updateData )
        {
            for ( int i = 0; i < updateData.PlayerInputs.Count; i++ )
            {
                var playerInput = updateData.PlayerInputs[ i ];
                var ID = playerInput.PlayerID;
                _Entitys[ ID ].OnLogicUpdate( updateData.Delta, playerInput );
            }
        }

        /// <summary>
        /// ���뷿��
        /// </summary>
        public void JoinRoom( )
        {
            var msg = new Req_JoinRoom( );
            msg.data.SkinID = 0;
            NetAsyncMgr.Send( msg );
        }

        /// <summary>
        /// ��ʼ��Ϸ - һ���ɷ�������
        /// </summary>
        public void StartGame( )
        {
            var startRoomMsg = new StartRoomMassage( );
            NetAsyncMgr.Send( startRoomMsg );
        }

        /// <summary>
        /// �յ���ҽ��뷿�����Ϣ
        /// </summary>
        private void Res_JoinRoomMsg( BaseMessage msg )
        {
            var message = msg as Res_JoinRoom;
            if ( message.data.IsSelf == 1 ) SelfNetId = message.data.PlayerID;
            CreatePlayer( message.data.PlayerID, message.data.SkinID );
        }

        /// <summary>
        /// �������
        /// </summary>
        /// <param name="netId"></param>
        private void CreatePlayer( int netId, int skinId = 0 )
        {
            var go = InstantiateSyncPrefab( skinId );
            NetPlayer player = new NetPlayer( go, 30f );
            _Entitys.Add( netId, player );
            AEDebug.Log( "ע�����" );
        }

        /// <summary>
        /// ʵ����ͬ���ͻ���Ԥ����
        /// </summary>
        /// <param name="prefabId"></param>
        /// <returns></returns>
        private GameObject InstantiateSyncPrefab( int prefabId )
        {
            if ( prefabId < 0 || prefabId >= _SyncPrefabs.Count )
            {
                Debug.LogError( $"RoomManager.Instantiate [{prefabId}] ������" );
                return null;
            }

            GameObject ret = null;
            if ( NetEntityParent != null )
            {
                ret = GameObject.Instantiate( _SyncPrefabs[ prefabId ], NetEntityParent );
            }
            else
            {
                ret = GameObject.Instantiate( _SyncPrefabs[ prefabId ] );
            }

            if ( null != ret && ret.TryGetComponent<BaseVolumnBaseCollider>( out var collider ) )
            {
                _AEPhysicsMgr.RegisterCollider( collider );
            }

            return ret;
        }

    }

}