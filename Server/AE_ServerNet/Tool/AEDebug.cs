using System.Diagnostics;

#if DEBUG || UNITY_EDITOR

using Newtonsoft.Json;

#endif

namespace AE_ServerNet
{

    public static class AEDebug
    {
        [Conditional( "DEBUG" )]
        [Conditional( "UNITY_EDITOR" )]
        public static void Log( string msg )
        {
#if UNITY_EDITOR
            UnityEngine.Debug.Log( msg );
#else
            Console.WriteLine( msg );
#endif
        }

        [Conditional( "DEBUG" )]
        [Conditional( "UNITY_EDITOR" )]
        public static void Json( object msg )
        {
            if ( msg != null )
            {
                string text = JsonConvert.SerializeObject( msg );
                Log( text );
            }
        }

    }

}