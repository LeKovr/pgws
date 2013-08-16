 //Triggering table columns by settings checkboxz
  window.PGWS.body_colums_setting = function(t){
    var $trigger = $(t);
    trigger = $trigger.is(':checked');
    col = $trigger.data('column');
    $table = $('.' + $trigger.closest('.grid-settings').data('grid')).not(':hidden');
    $col = $table.find('th[data-column="' + col + '"]');
    $col.toggle(trigger);
    $table.find('tr').each(function(i, row) {
      $(row).find('td').eq($col.index()).toggle(trigger);
    });
  };
window.PGWS.body_colums_setting_array = function(tt){
  $.each(tt, function(i, t){
    window.PGWS.body_colums_setting(t);
  });
};
//Checkbox disable row
  window.PGWS.body_disabled_row = function(t){
    var check = $(t),
    row = check.closest('tr');
    row.toggleClass('disabled', !check.is(':checked'))
      .find('textarea,select,input:not(.disable-row)')
      .prop('disabled', function(i, disabled) {
	check.prop('title', 'Поле конкурса ' + (disabled ? 'включено' : 'выключено'));
	return !disabled;
    });
  };
  //Checkbox visibility row
  window.PGWS.body_visibility_row = function(t){
    var $trigger = $(t);
    trigger = $trigger.is(':checked');
    $table = $('.' + $('.grid-settings').data('grid')).not(':hidden');
    $table.find('tr.disabled').each(function(i, row) {
      $(row).toggle(trigger);
    });
  };
window.PGWS.initSteps = function(){
  window.PGWS.body_colums_setting_array($('.col-trigger:not(disabled)'));
  $('.col-trigger:not(disabled)').bind('click', function() {
    window.PGWS.body_colums_setting(this);
  }); 
  $('.disable-row').bind('click', function() {
    window.PGWS.body_disabled_row(this);
  }); 
  window.PGWS.body_visibility_row($('.row-trigger'));
  $('.row-trigger').bind('click', function() {
    window.PGWS.body_visibility_row(this);
  });
  $('.grid-settings').find('.dropdown-menu').click(function (e) { e.stopPropagation() });// не скрывать меню после клика внутри
};

$(document).ready(function(){
  window.PGWS.initSteps();
});
