using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResetPosAfterClip : StateMachineBehaviour
{
    // OnStateEnter is called when a transition starts and the state machine starts to evaluate this state
    //override public void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
   // {
   //     
   // }

    // OnStateUpdate is called on each Update frame between OnStateEnter and OnStateExit callbacks
    //override public void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    //{
    //    
    //}

    // OnStateExit is called when a transition ends and the state machine finishes evaluating this state
    override public void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
		Debug.Log("WHAT " + animator.GetBoneTransform(HumanBodyBones.Hips).position + " animato gameobjo:" + animator.gameObject.name);
		animator.gameObject.transform.position = Vector3.Scale(new Vector3(1f,0f,1f),animator.GetBoneTransform(HumanBodyBones.Hips).position);
		animator.gameObject.transform.forward = Vector3.Scale(new Vector3(1f, 0f, 1f), animator.GetBoneTransform(HumanBodyBones.Hips).forward).normalized;
    }

    // OnStateMove is called right after Animator.OnAnimatorMove()
    override public void OnStateMove(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
		if(Input.GetKey(KeyCode.Space))
		{
			animator.gameObject.transform.position = Vector3.MoveTowards(animator.gameObject.transform.position, new Vector3(5f, 0f, 5f), Time.deltaTime);
		}
        // Implement code that processes and affects root motion
    }

    // OnStateIK is called right after Animator.OnAnimatorIK()
    //override public void OnStateIK(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    //{
    //    // Implement code that sets up animation IK (inverse kinematics)
    //}
}
