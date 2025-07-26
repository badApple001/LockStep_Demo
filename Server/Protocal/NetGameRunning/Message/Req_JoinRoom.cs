namespace NetGameRunning{
public class Req_JoinRoom : AE_NetMessage.BaseMessage<NetGameRunning.ReqJoinRoom>{
public override int GetMessageID()
{
return 10003;
}public override void WriteIn(byte[] buffer, int beginIndex,int length)
{
 data = NetGameRunning.ReqJoinRoom.Parser.ParseFrom(buffer, beginIndex, length);
}
}
}