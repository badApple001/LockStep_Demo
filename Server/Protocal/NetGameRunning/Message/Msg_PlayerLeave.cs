namespace NetGameRunning{
public class Msg_PlayerLeave : AE_NetMessage.BaseMessage<NetGameRunning.PlayerLeaveData>{
public override int GetMessageID()
{
return 10006;
}public override void WriteIn(byte[] buffer, int beginIndex,int length)
{
 data = NetGameRunning.PlayerLeaveData.Parser.ParseFrom(buffer, beginIndex, length);
}
}
}