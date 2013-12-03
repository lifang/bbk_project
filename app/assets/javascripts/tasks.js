// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

//领取任务（PPT和动画制作者）
function get_tasks(user_id)
{
    $.ajax({
//        async : true,
        url : "/tasks/assign_tasks",
        type:'get',
        dataType : 'script',
        data : {
            user_id : user_id
        },
        success:function(){
//           alert(2);
        }
    });
}

function verify(user_id,task_id)
{
    $.ajax({
//        async : true,
        url : "/tasks/verify_task",
        type:'get',
        dataType : 'script',
        data : {
            user_id : user_id,
            task_id : task_id
        },
        success:function(){
//           alert(2);
        }
    });
}