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
    });
    
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
    });
    $("td.task_batch").click(function(){
        var task_tag_id = $(this).attr("task_tag_id");
        $.ajax({
            async:true,
            type :'get',
            url : '/tasks/tasktag_pptlist',
            data : {
                task_tag_id : task_tag_id
            }
        })
    })
})


function add_user_unique(){
//    alert(1);
//    var doc_height = $(document).height();
//    var doc_width = $(document).width();
//    var u_height = $("#add_user").height();
//    var u_width = $("#add_user").width();
//    var top = (doc_height-u_height)/2;
//    var left = (doc_width-u_width)/2;
//     $("#add_user").css("margin-top",top);
//     $("#add_user").css("margin-left",left);
    $("#users_add_ff").show();
    $("#add_user").show();
}

function edit_user_unique(){
    var id = $(this).attr("user_id");
    $.ajax({
        async:true,
        type :'get',
        url : '/users/edit',
        data : {
            id : id
        }
    })
}

function settlement_change(){
    var month = $("select[sec_class='month_sec']").val();
    var types = $("select[sec_class='types_sec']").val();
    $.ajax({
        async:true,
        type : 'get',
        dataType : 'script',
        url:"/calculations/settlement_list",
        data : {
            month : month,
            types : types
        }
    })
}

function whether_payment(obj){
    var calculation_id = $(obj).attr("calculation_id");
    if (confirm("确认更改？")==true){
        $.ajax({
            async:true,
            type : 'get',
            dataType : 'json',
            url:'/calculations/whether_payment',
            data : {
                calculation_id : calculation_id
            },
            success: function(data){
                if(data.status==0)
                    $(obj).val("未付款");
                else{
                    $(obj).val("已付款");
                }
            }
        })
    }
   
}