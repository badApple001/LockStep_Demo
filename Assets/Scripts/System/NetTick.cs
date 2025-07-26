using System.Collections.Generic;
using AE_BEPUPhysics_Addition;
using AE_BEPUPhysics_Addition.Interface;
using AE_ClientNet;
using AE_NetMessage;
using NetGameRunning;
using UnityEngine;

namespace LockStep_Demo
{
    public class NetTick : MonoBehaviour
    {
        private int m_curFrame;
        private bool m_reciveFromLastUpLoad;

        private float m_upLoadInterval; //单位秒 间隔多少上传数据
        private float m_timer; //计时器

        PlayerMgr m_playerMgr;
        private AEPhysicsMgr m_AEPhysicsMgr;

        [SerializeField] private List<BaseCollider> m_colliders;

        [SerializeField] private string m_serverIP;
        [SerializeField] private int m_port;
        [SerializeField] private int m_FPS;

        [ContextMenu("开启连接")]
        public void StartConnect()
        {
            NetAsyncMgr.ClearNetMessageListener();
            m_curFrame = -1;
            m_timer = 0;
            SetFPS(m_FPS);
            m_AEPhysicsMgr = new AEPhysicsMgr(new BEPUutilities.Vector3(0, -20m, 0));
            foreach (var VARIABLE in m_colliders)
            {
                m_AEPhysicsMgr.RegisterCollider(VARIABLE);
            }

            m_playerMgr = new PlayerMgr(m_AEPhysicsMgr);
            NetAsyncMgr.AddNetMessageListener(MessagePool.UpdateMessage_ID, ReciveUpdateMessage);
            NetAsyncMgr.SetMaxMessageFire(m_FPS);
            NetAsyncMgr.Connect(m_serverIP, m_port);
        }


        public void JoinRoom( )
        {
            m_playerMgr.SendRegisterPlayer( );
        }


        public void StartGame( )
        {
            var startRoomMsg = new StartRoomMassage( );
            NetAsyncMgr.Send( startRoomMsg );
            AEDebug.Log( "开始同步" );
        }

        private void Update()
        {
            NetAsyncMgr.FireMessage();
            if (!NetAsyncMgr.IsConnected) return;
            if (m_curFrame == -1) return;
            m_AEPhysicsMgr.UpdatePosition();
            Upload(Time.deltaTime);
        }

        /// <summary>
        /// 接收帧数据
        /// </summary>
        /// <param name="msg"></param>
        private void ReciveUpdateMessage(BaseMessage msg)
        {
            var updateMessage = msg as UpdateMessage;
            var updateDate = updateMessage.data;
            if (updateDate.CurFrameIndex == m_curFrame + 1)
            {
                m_curFrame = updateDate.CurFrameIndex;
                m_reciveFromLastUpLoad = true;
                m_playerMgr.OnLogincUpdate(updateDate);
                m_AEPhysicsMgr.PhysicsUpdate(updateDate.Delta);
            }

            AEDebug.Log(updateDate.Delta);
            AEDebug.Log("接收到第:" + updateDate.CurFrameIndex + "帧数据");
        }

        /// <summary>
        /// 上传玩家消息
        /// </summary>
        private void Upload(float delta)
        {
            //如果没有接收到当前帧则等待
            if (m_playerMgr.PlayerID == -1) return;
            if (!m_reciveFromLastUpLoad) return;
            m_timer += delta;
            if (m_timer >= m_upLoadInterval)
            {
                m_timer = 0;
                UpLoad();
                AEDebug.Log("发布:" + (m_curFrame + 1) + "帧数据");
                m_reciveFromLastUpLoad = false;
            }
        }

        /// <summary>
        /// 上传玩家消息
        /// </summary>
        private void UpLoad()
        {
            UpLoadMessage upLoadMsg = new UpLoadMessage();
            var playerInput = upLoadMsg.data;

            playerInput.JoyX = Input.GetAxis("Horizontal");
            playerInput.JoyY = Input.GetAxis("Vertical");
            playerInput.PlayerID = m_playerMgr.PlayerID;
            playerInput.CurFrameIndex = m_curFrame + 1;

            NetAsyncMgr.Send(upLoadMsg);
            AEDebug.Log("上传第" + playerInput.CurFrameIndex + "帧的数据" + playerInput.JoyX + "..." + playerInput.JoyY);
        }

        /// <summary>
        /// 设置上传帧率
        /// </summary>
        /// <param name="FPS"></param>
        private void SetFPS(int FPS)
        {
            m_upLoadInterval = 1f / FPS;
        }


        [ContextMenu("注册碰撞体")]
        private void AddInColloders()
        {
            MonoBehaviour[] monoBehaviours = FindObjectsOfType<BaseCollider>();

            m_colliders.Clear();

            foreach (BaseCollider monoBehaviour in monoBehaviours)
            {
                m_colliders.Add(monoBehaviour);
            }
        }
    }
}