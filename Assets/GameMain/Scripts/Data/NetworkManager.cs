using AE_BEPUPhysics_Addition;
using AE_BEPUPhysics_Addition.Interface;
using AE_ClientNet;
using System.Collections.Generic;
using UnityEngine;

public class NetworkManager : MonoBehaviour
{

    public List<GameObject> SyncPrefabs = new List<GameObject>( );
    public static NetworkManager Instance { private set; get; }

    private void Awake( )
    {
        if( Instance != null && Instance != this )
        {
            Destroy( gameObject );
            return;
        }

        Instance = this;
        name = "NetworkManager - Singleton";
        DontDestroyOnLoad( gameObject );
    }


    private int m_curFrame;
    private bool m_reciveFromLastUpLoad;
    private float m_upLoadInterval; //单位秒 间隔多少上传数据
    private float m_timer; //计时器
    private AEPhysicsMgr m_AEPhysicsMgr;

    [SerializeField] private string m_serverIP;
    [SerializeField] private int m_port;
    [SerializeField] private int m_FPS;



    public void InitSceneColliders( )
    {

        var colliders = GameObject.FindObjectsByType<BaseCollider>( FindObjectsSortMode.None );
        AEDebug.Log( $"遍历AE碰撞器: ${colliders.Length}" );

        m_AEPhysicsMgr = new AEPhysicsMgr( new BEPUutilities.Vector3( 0, -20m, 0 ) );
        foreach ( var VARIABLE in colliders )
        {
            m_AEPhysicsMgr.RegisterCollider( VARIABLE );
        }
    }


    public void StartConnect( )
    {
        NetAsyncMgr.ClearNetMessageListener( );
        m_curFrame = -1;
        m_timer = 0;
        m_upLoadInterval = ( 1f / m_FPS ).ToFix64( ).ToFloat();

        //m_playerMgr = new PlayerMgr( m_AEPhysicsMgr );
        //RoomManager.Instance.Setup()
        //NetAsyncMgr.AddNetMessageListener( MessagePool.UpdateMessage_ID, ReciveUpdateMessage );
        NetAsyncMgr.SetMaxMessageFire( m_FPS );
        NetAsyncMgr.Connect( m_serverIP, m_port );
    }




}
