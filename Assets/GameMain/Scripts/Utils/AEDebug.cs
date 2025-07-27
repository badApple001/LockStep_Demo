using System.Diagnostics;
using Newtonsoft.Json;

namespace GameScripts
{

    public static class AEDebug
    {
        [Conditional( "DEBUG" )]
        [Conditional( "UNITY_EDITOR" )]
        public static void Log( string msg )
        {
#if UNITY_EDITOR
            UnityEngine.Debug.Log( msg );
#endif
        }

        [Conditional("DEBUG")]
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