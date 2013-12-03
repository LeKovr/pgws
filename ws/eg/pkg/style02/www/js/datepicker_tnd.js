  $(document).ready(function(){
    $('.date').datepicker({
      language: 'ru'
    }).on('changeDate', function(e){
	from = $(this).attr('data-date').split(".");
	var startDate = new Date(from[2], from[1] - 1, from[0]);
	var diff = Math.floor((e.date.getTime() - startDate.getTime()) / 86400000);
	var inpupSubmit =  $(this).parents('.blockCalendar:first').find('.diffDate');
	var diffStart = $(this).attr('data-diff-start');
	$(inpupSubmit).val((parseInt(diffStart)+diff));
    });
    $('.time').datetimepicker({
      pickDate: false,
      pickSeconds: false
    });
    $("i").click(function(){
       if($(this).parents('div:first').find('input').is(':disabled')){
	 return false;
       }
    });
  });
