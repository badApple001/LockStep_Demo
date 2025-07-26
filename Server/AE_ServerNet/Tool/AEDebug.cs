using System.Diagnostics;

namespace AE_ServerNet
{
    public static class AEDebug
    {
        [Conditional( "DEBUG" )]
        public static void Log(string msg)
        {
#if DEBUG
            Console.WriteLine(msg);
#endif
        }
    }
}