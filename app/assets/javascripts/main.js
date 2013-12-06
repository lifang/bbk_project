$(function(){
	
	$(".second_box").on("click",".close",function(){
		$(".second_box").hide();
		$(".second_bg").hide();
	});
	
	$(".theTab").click(function(){
		$(".theTab").removeClass("used");
		$(".tabDiv").removeClass("used");
		$(this).addClass("used");
		var i = $(".theTab").index(this);
		//alert(i);
		$(".tabDiv").eq(i).addClass("used");
	});
	
	$("tr").each(function(){
		var table = $(this).parents("table");
		var i = table.find("tr").index($(this));
		if(i % 2 ==0 && i != 0){
			$(this).css("background","#F2F6F6");
		}
	});
	
	$(".file_1").change(function(){
		$(this).parents(".fileBox").find(".fileText_1").val($(this).val());
	});
	
	
});