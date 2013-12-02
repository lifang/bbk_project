$(function(){
    $(document).on('click',"input[name='ajax_final']",function(){
        var button = $(this);
        var task_tag_id = $(this).attr("task_tag_id");
        $.ajax({
            async:true,
            type : 'get',
            url :'/users/confirm_final',
            data : {
                task_tag_id : task_tag_id
            },
            success: function(data){
                if(data){
                    alert("确认终检");
                    button.val("终检完成");
                }
            },
            error : function(data){
                alert("终检失败")
            }
        })
    })
    $(document).on('click',"input[name='ajax_download']",function(){
        var button = $(this);
        var task_tag_id = $(this).attr("task_tag_id");
        $.ajax({
            async:true,
            type : 'get',
            url :'/users/download',
            data : {
                task_tag_id : task_tag_id
            },
            success: function(data){
                window.location.href = "/users/ajax_download"
            },
            error : function(data){
                alert("下载失败")
            }
        })
    })

})