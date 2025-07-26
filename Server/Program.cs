using GameServer.Logic.Handler;
using GameServer.Logic.Rooms;

namespace AE_ServerNet
{
    internal class Program
    {
        static readonly string ServerIp = "0.0.0.0";
        static readonly int LocalPoint = 8080;
        public static ServerSocket socket;

        static void Main( string[] args )
        {

            socket = new ServerSocket( );
            socket.Start( ServerIp, LocalPoint, 1024 );
            AEDebug.Log( "服务器开启成功" );


            MainHandler.AddAllListener( );
            AEDebug.Log( "MainHandler开启监听" );
            
            var room = new BattleRoom( );
            AEDebug.Log( "创建房间" );

            while ( true )
            {
                string input = Console.ReadLine( );
#if DEBUG
                OnDebugUpdate( );
#endif

                if ( input == null || input.Length == 0 ) continue;
                //定义规则
                if ( input == "Quit" )
                {
                    //socket.Close();
                    break;
                }

                System.Threading.Thread.Sleep( 1 );//让程序挂起1毫秒，这样做的目的是避免死循环，让CPU有个短暂的喘息时间。
            }
        }

#if DEBUG
        static void OnDebugUpdate( )
        {


            Console.Title = $"send: {socket.TotalSendBytes / 1024}kb | recive: {socket.TotalReceiveBytes / 1024}kb";
        }
#endif

    }
}