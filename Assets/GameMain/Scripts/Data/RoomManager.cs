
using AE_BEPUPhysics_Addition;
using AE_ClientNet;
using AE_NetMessage;
using LockStep_Demo;
using NetGameRunning;
using System.Collections.Generic;
using UnityEngine;

public class RoomManager
{
    public static RoomManager Instance { private set; get; } = new RoomManager( );
    private AEPhysicsMgr _AEPhysicsMgr;
    private List<GameObject> _SyncPrefabs;
    private Dictionary<int,BasePlayer> _Players = new Dictionary<int, BasePlayer>();
    public int SelfNetId { private set; get; } = -1;


    public void Setup( AEPhysicsMgr physicsMgr, List<GameObject> syncPrefabs )
    {
        _AEPhysicsMgr = physicsMgr;
        _SyncPrefabs = syncPrefabs;
        SelfNetId = -1;
        NetAsyncMgr.AddNetMessageListener( MessagePool.RegisterMessage_ID, ReciveRegisterPlayer );
        NetAsyncMgr.AddNetMessageListener( MessagePool.RegisterSelfMessage_ID, ReciveRegisterSelfPlayer );
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
            _Players[ ID ].OnLogicUpdate( updateData.Delta, playerInput );
        }
    }

    /// <summary>
    /// ����ע�ᵱǰ�ͻ������
    /// </summary>
    public void SendRegisterPlayer( )
    {
        RegisterSelfMessage registerSelfMsg = new RegisterSelfMessage( );
        NetAsyncMgr.Send( registerSelfMsg );
    }

    /// <summary>
    /// ����ע���Լ�
    /// </summary>
    public void ReciveRegisterSelfPlayer( BaseMessage msg )
    {
        RegisterSelfMessage registerSelfMessage = msg as RegisterSelfMessage;
        SelfNetId = registerSelfMessage.data.PlayerID;
        RegisterPlayer( registerSelfMessage.data.PlayerID );
    }

    /// <summary>
    /// ����ע�����
    /// </summary>
    public void ReciveRegisterPlayer( BaseMessage msg )
    {
        RegisterMessage registerMsg = msg as RegisterMessage;
        RegisterPlayer( registerMsg.data.PlayerID );
    }

    /// <summary>
    /// ����ע�����
    /// </summary>
    /// <param name="playerID"></param>
    /// <exception cref="NotImplementedException"></exception>
    private BasePlayer RegisterPlayer( int playerID )
    {
        var prefab = Resources.Load<GameObject>( "Player" );

        var go = GameObject.Instantiate( prefab );

        BasePlayer player = new BasePlayer( BasePlayer.STATEENUM.idle, go, 30f );
        //m_players.Add( playerID, player );
        //m_physicsMgr.RegisterCollider( go.GetComponent<BaseVolumnBaseCollider>( ) );
        //AEDebug.Log( "ע�����" );
        return player;
    }
}
