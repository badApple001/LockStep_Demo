namespace NetGameRunning{
public class Msg_SyncRoomPlayerMsg : AE_NetMessage.BaseMessage<NetGameRunning.SyncRoomPlayersData>{
public override int GetMessageID()
{
return 10007;
}public override void WriteIn(byte[] buffer, int beginIndex,int length)
{
 data = NetGameRunning.SyncRoomPlayersData.Parser.ParseFrom(buffer, beginIndex, length);
}
}
}