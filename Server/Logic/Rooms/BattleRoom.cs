using AE_ClientNet;
using AE_NetMessage;
using AE_ServerNet;
using NetGameRunning;

namespace GameServer.Logic.Rooms
{
    public class BattleRoom
    {

        public int CurFrame { get; private set; }
        private Dictionary<int, ClientSocket> m_players;
        private Dictionary<int, bool> m_IDRecived;
        private UpdateMessage m_currentFrameplayerInputs;
        private DateTime m_lastSendUpdateMsg;
        private int m_entityIdBase = 0; // | CampId(16) | offset(16) |

        public BattleRoom( )
        {
            m_currentFrameplayerInputs = new UpdateMessage( );
            m_players = new Dictionary<int, ClientSocket>( );
            m_IDRecived = new Dictionary<int, bool>( );

            ClientSocket.AddListener( MessagePool.UpLoadMessage_ID, RecivePlayerInput );
            ClientSocket.AddListener( MessagePool.Req_JoinRoom_ID, On_Req_JoinRoom_Msg );
            ClientSocket.AddListener( MessagePool.HeartMessage_ID, ReciveHearMessage );
            ClientSocket.AddListener( MessagePool.StartRoomMassage_ID, StartRoom );
        }

        /// <summary>
        /// 房间开始
        /// </summary>
        /// <param name="message"></param>
        /// <param name="socket"></param>
        private void StartRoom( BaseMessage message, ClientSocket socket )
        {
            CurFrame = 0;
            m_lastSendUpdateMsg = DateTime.Now;

            m_currentFrameplayerInputs.data.CurFrameIndex = CurFrame;
            m_currentFrameplayerInputs.data.NextFrameIndex = CurFrame + 1;
            foreach ( var item in m_players )
            {
                var playerInput = new PlayerInputData( );
                playerInput.PlayerID = item.Key;
                playerInput.JoyX = 0;
                playerInput.JoyY = 0;
                m_currentFrameplayerInputs.data.PlayerInputs.Add( playerInput );
            }

            socket.serverSocket.Broadcast( m_currentFrameplayerInputs );
            m_currentFrameplayerInputs.data.PlayerInputs.Clear( );
            AEDebug.Log( "接收到房间开始并发布第0帧" );
        }

        /// <summary>
        /// 接收到玩家操作
        /// </summary>
        /// <param name="message"></param>
        /// <param name="socket"></param>
        private void RecivePlayerInput( BaseMessage message, ClientSocket socket )
        {
            lock ( m_currentFrameplayerInputs )
            {
                var upLoadMessage = message as UpLoadMessage;
                if ( upLoadMessage.data.CurFrameIndex == CurFrame + 1 )
                {
                    m_IDRecived[ upLoadMessage.data.PlayerID ] = true;
                    m_currentFrameplayerInputs.data.PlayerInputs.Add( upLoadMessage.data );

                    AEDebug.Log( "接收第" + upLoadMessage.data.CurFrameIndex + "帧" + "输入数据为" + upLoadMessage.data.JoyX +
                                "..." + upLoadMessage.data.JoyY );
                    foreach ( var item in m_IDRecived.Values )
                    {
                        if ( !item )
                        {
                            return;
                        }
                    }

                    //服务器帧更新
                    CurFrame += 1;
                    var span = DateTime.Now - m_lastSendUpdateMsg;
                    m_lastSendUpdateMsg = DateTime.Now;
                    AEDebug.Log( span.TotalSeconds.ToString( ) );
                    //广播
                    m_currentFrameplayerInputs.data.CurFrameIndex = CurFrame;
                    m_currentFrameplayerInputs.data.NextFrameIndex = CurFrame + 1;
                    m_currentFrameplayerInputs.data.Delta = ( float ) span.TotalSeconds;
                    socket.serverSocket.Broadcast( m_currentFrameplayerInputs );
                    AEDebug.Log( "发布第" + upLoadMessage.data.CurFrameIndex + "帧" );
                    //清理
                    m_currentFrameplayerInputs.data.PlayerInputs.Clear( );
                    for ( int i = 0; i < m_IDRecived.Count; i++ )
                    {
                        m_IDRecived[ i ] = false;
                    }
                }
            }
        }

        /// <summary>
        /// 接收注册消息
        /// </summary>
        /// <param name="message"></param>
        /// <param name="socket"></param>
        private void On_Req_JoinRoom_Msg( BaseMessage message, ClientSocket socket )
        {
            if ( m_players.ContainsValue( socket ) )
            {
                AEDebug.Log( "已经存在当前玩家" + m_players.Count );
                return;
            }

            var req_msg = message as Req_JoinRoom;
            if ( req_msg == null )
            {
                AEDebug.Log( "ReciveRegisterSelfPlayer 消息结构有问题" );
                return;
            }

            int playerId = ++m_entityIdBase;
            int skinId = req_msg.data.SkinID;
            foreach ( var client in socket.serverSocket.clientSockets.Values )
            {
                Res_JoinRoom res_msg = new Res_JoinRoom( );
                res_msg.data.PlayerID = playerId;
                res_msg.data.SkinID = skinId;
                res_msg.data.IsSelf = socket == client ? 1 : 0;
                client.Send( res_msg );
            }
            AEDebug.Log( "注册消息" + m_players.Count );
            m_IDRecived.Add( playerId, false );
        }


        /// <summary>
        /// 接收到心跳消息
        /// </summary>
        /// <param name="arg1"></param>
        /// <param name="arg2"></param>
        private void ReciveHearMessage( BaseMessage arg1, ClientSocket arg2 )
        {
            AEDebug.Log( $"心跳消息: from client{arg2.clientID}" );
        }

    }
}
