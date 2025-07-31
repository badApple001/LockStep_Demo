using AE_BEPUPhysics_Addition;
using AE_ClientNet;
using AE_NetMessage;
using NetGameRunning;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using static Google.Protobuf.WellKnownTypes.Field.Types;


namespace GameScripts
{


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
        private Dictionary<int, INetPlayer> _Players = new Dictionary<int, INetPlayer>( );


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
            _Players.Clear( );

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

            //玩家更新
            for ( int i = 0; i < updateData.PlayerInputs.Count; i++ )
            {
                var playerInput = updateData.PlayerInputs[ i ];
                var ID = playerInput.PlayerID;
                _Players[ ID ].OnLogicUpdate( updateData.Delta, playerInput );
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
                    if ( !_Players.ContainsKey( players[ i ].PlayerID ) )
                    {
                        CreatePlayer( players[ i ].PlayerID, players[ i ].SkinID );
                    }
                }

                //移除不存在的玩家
                List<INetPlayer> removeEntitys = new List<INetPlayer>( );
                foreach ( var player in _Players )
                {
                    if ( players.Find( p => p.PlayerID == player.Key ) == null )
                    {
                        removeEntitys.Add( player.Value );
                    }

                }
                for ( int i = 0; i < removeEntitys.Count; i++ )
                    DesotryEntity( removeEntitys[ i ] );

                //相机移到自己身上
                if ( SelfNetId != -1 && _Players.TryGetValue( SelfNetId, out var player1 ) )
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
            var go = InstantiateSyncPrefab( skinId, Vector3.forward * netId, Quaternion.identity );
            INetPlayer entity = new NetPlayer( );
            entity.Init( go );
            entity.velocity = 30;
            _Players.Add( netId, entity );
        }


        /// <summary>
        /// 当有玩家离开
        /// </summary>
        /// <param name="msg"></param>
        private void Msg_PlayerLeave( BaseMessage msg )
        {
            if ( msg is Msg_PlayerLeave playerLeaveMsg && _Players.TryGetValue( playerLeaveMsg.data.PlayerID, out INetPlayer entity ) )
            {
                DesotryEntity( entity );
            }
        }
 
        /// <summary>
        /// 销毁NetEntity
        /// </summary>
        /// <param name="entity"></param>
        public void DesotryEntity( INetPlayer entity )
        {
            _Players.Remove( entity.playerId );
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