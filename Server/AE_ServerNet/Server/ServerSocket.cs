﻿using System.Diagnostics;
using System.Net;
using System.Net.Sockets;
using AE_NetMessage;

namespace AE_ServerNet
{
    public class ServerSocket
    {
        public Socket socket;
        public Dictionary<int, ClientSocket> clientSockets = new Dictionary<int, ClientSocket>();

#if DEBUG
        public long TotalSendBytes = 0;
        public long TotalReceiveBytes = 0;
#endif


        /// <summary>
        /// 开启服务器
        /// </summary>
        /// <param name="ip"></param>
        /// <param name="port"></param>
        /// <param name="num"></param>
        public void Start(string ip, int port, int num)
        {
            this.socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            IPEndPoint ipEndPoint = new IPEndPoint(IPAddress.Parse(ip), port);
            try
            {
                socket.Bind(ipEndPoint);
                socket.Listen(num);
                this.socket.BeginAccept(Accept, this.socket);
            }
            catch (Exception e)
            {
                AEDebug.Log($"服务器开启失败: {e.Message}");
            }
        }

        /// <summary>
        /// 连接客户端
        /// </summary>
        /// <param name="result"></param>
        private void Accept(IAsyncResult result)
        {
            try
            {
                Socket clientSocket = this.socket.EndAccept(result);


                ClientSocket client = new ClientSocket(clientSocket, this);
                clientSockets.Add(client.clientID, client);

                AEDebug.Log($"客户端[{clientSocket.RemoteEndPoint}]连接服务器");

                this.socket.BeginAccept(Accept, this.socket);

            }
            catch (Exception e)
            {
                AEDebug.Log($"客户端接入失败: {e.Message}");
            }
        }

        /// <summary>
        /// 广播
        /// </summary>
        /// <param name="info"></param>
        public void Broadcast(BaseMessage info)
        {
            lock (clientSockets)
            {
                foreach (ClientSocket item in clientSockets.Values)
                {
                    item.Send(info);
                }
            }
        }

        /// <summary>
        /// 关闭连接
        /// </summary>
        /// <param name="socket"></param>
        public void CloseClientSocket(ClientSocket socket)
        {
            if (socket != null)
            {
                lock (clientSockets)
                {
                    AEDebug.Log($"客户端: {socket.socket.RemoteEndPoint} 断开连接");
                    socket.Close();
                    if (clientSockets.ContainsKey(socket.clientID))
                        clientSockets.Remove(socket.clientID);
                }
            }
        }
    }
}
