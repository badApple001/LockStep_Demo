#define DEBUGMODE
using System.Diagnostics;

namespace LockStep_Demo
{
    public static class AEDebug
    {
        [Conditional( "DEBUGMODE" )]
        public static void Log(object msg)
        {
            Log(msg.ToString());
        }

        [Conditional( "DEBUGMODE" )]
        public static void Log(string msg)
        {
#if DEBUGMODE
#if SERVER
            Console.WriteLine(msg);
#else
            UnityEngine.Debug.Log(msg);
#endif
#endif
        }
    }
}