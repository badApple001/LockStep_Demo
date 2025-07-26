namespace NetGameRunning{
public class Res_JoinRoom : AE_NetMessage.BaseMessage<NetGameRunning.ResJoinRoom>{
public override int GetMessageID()
{
return 10004;
}public override void WriteIn(byte[] buffer, int beginIndex,int length)
{
 data = NetGameRunning.ResJoinRoom.Parser.ParseFrom(buffer, beginIndex, length);
}
}
}