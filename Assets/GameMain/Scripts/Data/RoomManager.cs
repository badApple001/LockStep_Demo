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
    /// 房间管理
    /// </summary>
    public class RoomManager
    {

        /// <summary>
        /// 唯一单例
        /// </summary>
        public static RoomManager Instance { private set; get; } = new RoomManager( );
        
        /// <summary>
        /// 玩家自己的NetId
        /// </summary>
        public int SelfNetId { private set; get; } = -1;

        /// <summary>
        /// Entity生成的父类
        /// </summary>
        public Transform NetEntityParent { set; get; } = null;


        /// <summary>
        /// 第三方物理模拟管理器
        /// </summary>
        private AEPhysicsMgr _AEPhysicsMgr;

        /// <summary>
        /// 预制体，需要提前在NetworkManager注册好，确保其它客户端一一对应
        /// </summary>
        private List<GameObject> _SyncPrefabs;

        /// <summary>
        /// 所有动态创建的对象Entity 字典
        /// </summary>
        private Dictionary<int, INetEntity> _Entitys = new Dictionary<int, INetEntity>( );


        /// <summary>
        /// 初始化房间
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
        /// 清理房间
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
        /// 逻辑更新,受到更新消息后更新
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
        /// 加入房间
        /// </summary>
        public void JoinRoom( )
        {
            var msg = new Req_JoinRoom( );
            msg.data.SkinID = 0;
            NetAsyncMgr.Send( msg );
        }

        /// <summary>
        /// 开始游戏 - 一般由房主发起
        /// </summary>
        public void StartGame( )
        {
            var startRoomMsg = new StartRoomMassage( );
            NetAsyncMgr.Send( startRoomMsg );
        }

        /// <summary>
        /// 收到玩家进入房间的消息
        /// </summary>
        private void Res_JoinRoomMsg( BaseMessage msg )
        {
            var message = msg as Res_JoinRoom;
            if ( message.data.IsSelf == 1 ) SelfNetId = message.data.PlayerID;
            CreatePlayer( message.data.PlayerID, message.data.SkinID );
        }

        /// <summary>
        /// 创建玩家
        /// </summary>
        /// <param name="netId"></param>
        private void CreatePlayer( int netId, int skinId = 0 )
        {
            var go = InstantiateSyncPrefab( skinId );
            NetPlayer player = new NetPlayer( go, 30f );
            _Entitys.Add( netId, player );
            AEDebug.Log( "注册玩家" );
        }

        /// <summary>
        /// 实例化同步客户端预设体
        /// </summary>
        /// <param name="prefabId"></param>
        /// <returns></returns>
        private GameObject InstantiateSyncPrefab( int prefabId )
        {
            if ( prefabId < 0 || prefabId >= _SyncPrefabs.Count )
            {
                Debug.LogError( $"RoomManager.Instantiate [{prefabId}] 不存在" );
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