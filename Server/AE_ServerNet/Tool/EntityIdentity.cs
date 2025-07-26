namespace AE_ServerNet
{
    public class EntityIdentity
    {
        public static ushort GetLow16( int value )
        {
            return ( ushort ) ( value & 0xFFFF );
        }

        public static ushort GetHigh16( int value )
        {
            return ( ushort ) ( ( value >> 16 ) & 0xFFFF );
        }

        public static int Combine( ushort high, ushort low )
        {
            return ( high << 16 ) | low;
        }

        public static int SetLow16( int original, ushort newLow )
        {
            return ( original & unchecked(( int ) 0xFFFF0000) ) | newLow;
        }

        public static int SetHigh16( int original, ushort newHigh )
        {
            return ( original & 0x0000FFFF ) | ( newHigh << 16 );
        }

        public static int GetNextEntityId( int createId )
        {
            ushort nextId = GetHigh16( createId );
            return SetHigh16( createId, ++nextId );
        }

    }
}
