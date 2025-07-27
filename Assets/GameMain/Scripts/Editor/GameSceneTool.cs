using System.Linq;
using UnityEditor;
using UnityEngine;

public class GameSceneTool : EditorWindow
{

    [MenuItem( "GameObject/Tools/移除当前节点下的所有碰撞器" )]
    public static void RemoveAllColliders( )
    {
        if ( Selection.activeGameObject != null )
        {
            var colliders = Selection.activeGameObject.GetComponentsInChildren<Collider>( true ).ToList( );
            foreach ( var collider in colliders )
            {
                Debug.Log( $"移除碰撞器: {collider.gameObject}" );
                GameObject.DestroyImmediate( collider );
            }
        }
        else
        {
            Debug.LogError( "先选中一个根节点" );
        }

    }

}
