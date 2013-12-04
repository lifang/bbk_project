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

//审核任务（一检、二检）
function verify(obj, user_id, task_id)
{
    $(obj).remove();
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

//刷新任务数据
function reload_tasks()
{
    $.ajax({
        url : "/tasks/reload_tasks",
        type:'get',
        dataType : 'script',
        success:function(){
        }
    });
}

//显示或隐藏聊天栏
function chat(obj)
{
    display_val = $(obj).parents().parents().next().css('display');
    div_id = $(obj).parents().parents().next().attr('id');
    $(obj).parents().parents().parents().find("[class='chat_bar']").hide();
    if(display_val == 'none')
        $(obj).parents().parents().next().show();
    else
        $(obj).parents().parents().next().find("[id=div_id]");
}