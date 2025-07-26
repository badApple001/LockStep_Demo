using AE_ClientNet;
using AE_NetMessage;
using AE_ServerNet;

namespace GameServer.Logic.Handler
{
    public static class MainHandler
    {
        public static void AddAllListener( )
        {
            //监听心跳事件 
            //ClientSocket.AddListener( MessagePool.HeartMessage_ID, HeartMessageHandler );
        }

        private static void HeartMessageHandler( BaseMessage arg1, ClientSocket client )
        {
            AEDebug.Log( $"接收到心跳消息:[{client.socket.RemoteEndPoint}]" );
        }
    }
}
