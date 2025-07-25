﻿using System.Diagnostics;
using System.Net.Sockets;
using AE_ClientNet;
using AE_NetMessage;

namespace AE_ServerNet
{
    public class ClientSocket
    {
        #region Static
        private static Dictionary<int, Action<BaseMessage, ClientSocket>> listeners = new Dictionary<int, Action<BaseMessage, ClientSocket>>();

        public static readonly float TimeOutTime = 1120f;

        private static int CLIENT_BEGIN_ID = 1;

        static ClientSocket()
        {
            InitLister();
        }

        /// <summary>
        /// 初始化消息监听器
        /// </summary>
        private static void InitLister()
        {
            foreach (int item in MessagePool.MessageIDs)
            {
                if (listeners.ContainsKey(item)) { listeners[item] = null; continue; }
                listeners.Add(item, null);
            }
        }

        /// <summary>
        /// 添加消息监听
        /// </summary>
        /// <param name="messageID"></param>
        /// <param name="callback"></param>
        public static void AddListener(int messageID, Action<BaseMessage, ClientSocket> callback)
        {
            if (listeners.ContainsKey(messageID))
                listeners[messageID] += callback;
            else
                AEDebug.Log("没有这个消息类型" + messageID);
        }

        #endregion

        public int clientID;

        public Socket socket;

        public ServerSocket serverSocket;

        public bool Connected => socket.Connected;

        //缓存
        private byte[] bufferBytes = new byte[1024 * 1024];

        //接收缓冲区
        ByteArray readBuff = new ByteArray();

        //缓存长度
        private int bufferLenght = 0;

        private long lastHeartMessageTime = -1;

        //监听消息处理
        public long LastHeartMessageTime { get => lastHeartMessageTime; set { lastHeartMessageTime = value; } }

        //发送缓存
        Queue<ByteArray> writeQueue = new Queue<ByteArray>();

        public ClientSocket(Socket socket, ServerSocket serverSocket)
        {
            this.clientID = CLIENT_BEGIN_ID;
            this.socket = socket;
            this.serverSocket = serverSocket;
            ++CLIENT_BEGIN_ID;

            SocketAsyncEventArgs argsRecive = new SocketAsyncEventArgs();
            argsRecive.SetBuffer(bufferBytes, 0, bufferBytes.Length);
            argsRecive.Completed += ReciveCallback;
            this.socket.ReceiveAsync(argsRecive);
        }

        private void ReciveCallback(object obj, SocketAsyncEventArgs args)
        {
            try
            {
                if (this.socket != null && this.socket.Connected)
                {
                    int byteLength = args.BytesTransferred;

                    HandleReceiveMessage(byteLength);

                    //接收消息
                    if (socket != null && this.socket.Connected)
                        args.SetBuffer(bufferLenght, bufferBytes.Length);
                    this.socket.ReceiveAsync(args);
                }
                else
                {
                    AEDebug.Log("没有连接，不用再收消息了");
                    serverSocket.CloseClientSocket(this);
                }
            }
            catch (Exception e)
            {
                if (e is SocketException)
                {
                    AEDebug.Log($"接收消息出错 [{socket.RemoteEndPoint}] {(e as SocketException).ErrorCode}:{e.Message}");
                }
                else
                {
                    AEDebug.Log($"接收消息出错 [{socket.RemoteEndPoint}] :{e.Message}");
                }
                serverSocket.CloseClientSocket(this);
            }
        }

        private void HandleReceiveMessage(int bytesLength)
        {
            byte[] bytes = readBuff.bytes;

            if (bytesLength == 0) return;

            //处理
            int massageID = -1;
            int massageBodyLength = -1;
            int currentIndex = 0;

            bufferLenght += bytesLength;

            while (true)//粘包
            {
                if (bufferLenght >= 8)
                {
                    //ID
                    massageID = BitConverter.ToInt32(bufferBytes, currentIndex);
                    currentIndex += 4;
                    //长度
                    massageBodyLength = BitConverter.ToInt32(bufferBytes, currentIndex) - 8;
                    currentIndex += 4;
                }

                if (bufferLenght - currentIndex >= massageBodyLength && massageBodyLength != -1 && massageID != -1)
                {
                    //消息体 
                    BaseMessage baseMassage = MessagePool.GetMessage(massageID);

                    if (baseMassage != null)
                    {
                        if (massageBodyLength != 0)
                            baseMassage.WriteIn(bufferBytes, currentIndex, massageBodyLength);

                        ThreadPool.QueueUserWorkItem(HandleMassage, baseMassage);
                    }

                    currentIndex += massageBodyLength;
                    if (currentIndex == bufferLenght)
                    {
                        bufferLenght = 0;
                        break;
                    }
                }
                else//分包
                {
                    if (massageBodyLength != -1)
                        currentIndex -= 8;
                    Array.Copy(bufferBytes, currentIndex, bufferBytes, 0, bufferLenght - currentIndex);
                    bufferLenght = bufferLenght - currentIndex;
                    break;
                }
            }
        }

        private void HandleMassage(object? state)
        {
            if (state == null)
            {
                AEDebug.Log($"接收消息出错: 消息内容为null");
                return;
            }

            BaseMessage message = state as BaseMessage;
            if (message == null)
            {
                AEDebug.Log($"接收消息出错: 消息内容为null");
                return;
            }

#if DEBUG
            //记录接收的数据包大小
            serverSocket.TotalReceiveBytes += message.GetByteLength( );
#endif
            listeners[message.GetMessageID()]?.Invoke(message, this);
        }

        
        public void Send(BaseMessage info)
        {

            if (!Connected)
            {
                serverSocket.CloseClientSocket(this);
                return;
            }


            try
            {
                SocketAsyncEventArgs argsSend = new SocketAsyncEventArgs();
                byte[] bytes = info.GetBytes();
                argsSend.SetBuffer(bytes, 0, bytes.Length);
                argsSend.Completed += SendCallback;
                this.socket.SendAsync(argsSend);


#if DEBUG
            //记录发送的数据包大小
            serverSocket.TotalSendBytes += ( 8 + bytes.Length );
#endif
            }
            catch (Exception e)
            {
                AEDebug.Log($"发送消息出错: {e.Message}");
                serverSocket.CloseClientSocket(this);
            }
        }


        private void SendCallback(object obj, SocketAsyncEventArgs args)
        {
            if (args.SocketError == SocketError.Success)
            {

            }
            else
            {

                AEDebug.Log($"{args.SocketError}");
                Close();
            }
        }



        public void Close()
        {
            if (Connected)
            {
                socket.Shutdown(SocketShutdown.Both);
                socket.Close();
            }
        }
    }
}
