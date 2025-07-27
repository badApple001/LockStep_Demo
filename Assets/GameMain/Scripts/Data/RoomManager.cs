using AE_BEPUPhysics_Addition;
using AE_ClientNet;
using AE_NetMessage;
using NetGameRunning;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;


namespace GameScripts
{

    /// <summary>
    /// 网络实体
    /// </summary>
    public interface INetEntity
    {

        void OnLogicUpdate( float delta, PlayerInputData playerInput );

        GameObject gameObject { get; }

        BaseVolumnBaseCollider body { get; }

        int NetId { get; set; }
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
            NetAsyncMgr.AddNetMessageListener( MessagePool.Msg_PlayerLeave_ID, Msg_PlayerLeave );
            NetAsyncMgr.AddNetMessageListener( MessagePool.Msg_SyncRoomPlayerMsg_ID, Msg_SyncRoomPlayers );
        }


        /// <summary>
        /// 清理房间
        /// </summary>
        public void Clear( )
        {
            SelfNetId = -1;
            NetEntityParent = null;
            _AEPhysicsMgr = null;
            _SyncPrefabs?.Clear( );
            _Entitys.Clear( );

            NetAsyncMgr.RemoveNetMessageListener( MessagePool.Res_JoinRoom_ID, Res_JoinRoomMsg );
            NetAsyncMgr.RemoveNetMessageListener( MessagePool.Msg_PlayerLeave_ID, Msg_PlayerLeave );
            NetAsyncMgr.RemoveNetMessageListener( MessagePool.Msg_SyncRoomPlayerMsg_ID, Msg_SyncRoomPlayers );
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
            var players = message.data.Team;
            SelfNetId = message.data.SelfID;
        }

        /// <summary>
        /// 广播房间玩家列表消息
        /// </summary>
        /// <param name="msg"></param>
        private void Msg_SyncRoomPlayers( BaseMessage msg )
        {
            AEDebug.Log( "收到广播房间玩家列表消息" );
            if ( msg is Msg_SyncRoomPlayerMsg message )
            {
                //创建玩家
                var players = message.data.Team.ToList( );
                for ( int i = 0; i < players.Count; i++ )
                {
                    if ( !_Entitys.ContainsKey( players[ i ].PlayerID ) )
                    {
                        CreatePlayer( players[ i ].PlayerID, players[ i ].SkinID );
                    }
                }

                //移除不存在的玩家
                List<INetEntity> removeEntitys = new List<INetEntity>( );
                foreach ( var entity in _Entitys )
                {
                    if ( entity.Value is INetPlayer player )
                    {
                        if ( players.Find( p => p.PlayerID == player.NetId ) == null )
                        {
                            removeEntitys.Add( entity.Value );
                        }
                    }
                }
                for ( int i = 0; i < removeEntitys.Count; i++ )
                    DesotryEntity( removeEntitys[ i ] );

                if ( SelfNetId != -1 && _Entitys.TryGetValue( SelfNetId, out var entity1 ) && entity1 is INetPlayer player1 )
                {
                    var camNode = player1.gameObject.transform.Find( "CameraNode" );
                    if ( camNode != null && Camera.main.transform.parent != camNode )
                    {
                        Camera.main.transform.parent = camNode;
                        Camera.main.transform.localEulerAngles = Vector3.zero;
                        Camera.main.transform.localPosition = Vector3.zero;
                    }
                }
            }
        }

        /// <summary>
        /// 创建玩家
        /// </summary>
        /// <param name="netId"></param>
        private void CreatePlayer( int netId, int skinId = 0 )
        {
            AEDebug.Log( "注册玩家" );
            var player = CreateEntity<NetPlayer>( netId, skinId, Vector3.forward * netId, Quaternion.identity ) as INetPlayer;
            player.speed = 30;
        }


        /// <summary>
        /// 当有玩家离开
        /// </summary>
        /// <param name="msg"></param>
        private void Msg_PlayerLeave( BaseMessage msg )
        {
            if ( msg is Msg_PlayerLeave playerLeaveMsg && _Entitys.TryGetValue( playerLeaveMsg.data.PlayerID, out INetEntity entity ) )
            {
                DesotryEntity( entity );
            }
        }

        /// <summary>
        /// 创建实体
        /// </summary>
        /// <param name="netId"></param>
        /// <param name="skinID"></param>
        public INetEntity CreateEntity<T>( int netId, int skinID, Vector3 localPos, Quaternion rotation ) where T : NetEntity, new()
        {
            var go = InstantiateSyncPrefab( skinID, localPos, rotation );
            T entity = new( );
            entity.Init( go );
            _Entitys.Add( netId, entity );
            return entity;
        }

        /// <summary>
        /// 销毁NetEntity
        /// </summary>
        /// <param name="entity"></param>
        public void DesotryEntity( INetEntity entity )
        {
            _Entitys.Remove( entity.NetId );
            _AEPhysicsMgr.UnRegisterCollider( entity.body );
            GameObject.Destroy( entity.gameObject );
        }

        /// <summary>
        /// 实例化同步客户端预设体
        /// </summary>
        /// <param name="prefabId"></param>
        /// <param name="realativePos"></param>
        /// <param name="rotation"></param>
        /// <returns></returns>
        private GameObject InstantiateSyncPrefab( int prefabId, Vector3 realativePos, Quaternion rotation )
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

            ret.transform.localPosition = realativePos;
            ret.transform.localRotation = rotation;
            if ( null != ret && ret.TryGetComponent<BaseVolumnBaseCollider>( out var collider ) )
            {
                _AEPhysicsMgr.RegisterCollider( collider );
            }

            return ret;
        }

    }

}