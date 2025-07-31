using NetGameRunning;

namespace GameScripts
{
    public interface IMonster 
    {

        int Hp { get; set; }
        int Atk { get; set; }
        int Armor { get; set; }
        float MoveSpeed { get; set; }
        float AttackSpeed { get; set; }
        MonsterState State { get; set; }
        void OnLogicUpdate( UpdateMessageData frameData );
    }


    public enum MonsterState
    {
        Idle,
        Move,
        Attack,


        Die,
        Dlying,
        Release,
    }


    /// <summary>
    /// 怪物基础类
    /// 
    /// 血条， 移动， 攻击 伤害
    /// 
    /// </summary>
    public class Monster : IMonster
    {
        public int Hp { get => throw new System.NotImplementedException( ); set => throw new System.NotImplementedException( ); }
        public int Atk { get => throw new System.NotImplementedException( ); set => throw new System.NotImplementedException( ); }
        public int Armor { get => throw new System.NotImplementedException( ); set => throw new System.NotImplementedException( ); }
        public float MoveSpeed { get => throw new System.NotImplementedException( ); set => throw new System.NotImplementedException( ); }
        public float AttackSpeed { get => throw new System.NotImplementedException( ); set => throw new System.NotImplementedException( ); }
        public MonsterState State { get => throw new System.NotImplementedException( ); set => throw new System.NotImplementedException( ); }

        public void OnLogicUpdate( UpdateMessageData frameData )
        {
            throw new System.NotImplementedException( );
        }
    }

}