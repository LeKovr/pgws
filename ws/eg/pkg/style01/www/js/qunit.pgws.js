$(document).ready(function(){
  var o = $('#selectTest');
  window.PGWS.select_test($(o).val());
  $(o).change(function(){
    window.PGWS.select_test($(this).val());
  });
});

window.PGWS.select_test = function(p){
   $('#tabs').hide();
   $('#step').hide();
   $('#qunit-tests').empty();
   if(p=='api'){
     window.PGWS.apitest();
   }
   if(p=='ajaxurl'){
     $('#tabs').show();
     window.PGWS.ajaxurl();
   }
   if(p=='step'){
     $('#step').show();
     window.PGWS.stepTest();
   }
}

window.PGWS.apitest = function(){
  asyncTest( "ws.method_lookup средствами jquery", function() {
    $.ajax({
        url: "/api/_ws.method_lookup.json",
        dataType: "json",
        data: {
          code: ""
        },
        success: function( data ) {
	  if(data.error == null){
	    ok(true, 'Jquery Ajax тест выполнения метода');
	    start();
	  }
        }
      });
  });
  asyncTest( "ws.method_lookup средствами api функции", function() {
   var params = {
      code:''
    };
    api("ws.method_lookup",'',function(f, r){
      if(r.error == null){
	ok(true, 'PGWS API тест выполнения метода');
	start();
      }
    },params ,'',false,'');
    });
  
  asyncTest( "info.add", function() {
    
    var params = {
      a:3,
      b:4
    };

    api("info.add",'',function(f, r){
	ok(r == 7, '3+4 = 7');
	start();
    },params ,'',false,'');
  });
  asyncTest( "info.status", function() {
    expect(1);
    
    var params = {
      
    };

    api("info.status",'',function(f, r){
      if(r.error == null){
	ok(true, 'PGWS API тест выполнения метода');
	start();
      }
    },params ,'',false,'');
  });
  asyncTest( "info.date", function() {
    var params = {
    };

    api("info.date",'',function(f, r){
      if(r.error == null){
	ok(true, 'PGWS API тест выполнения метода');
	start();
      }
    },params ,'',false,'');
  });
}
window.PGWS.ajaxurl = function(){
  test( "pgws-ajaxUrl.jquery", function() {
    expect(3);
    
    $.each($('.ajax'),function(i){
      var t = this;
      $(t).click();
      if($(t).parent('li').hasClass('active')){
	ok(true, 'Проверка на клики по вкладке '+(i+1));
      }
    });
  });
}
window.PGWS.stepTest = function(){
  window.PGWS.initSteps();
  test( "step.js", function() {
    expect(4);
    $('input[data-column="view"]').click();
    window.PGWS.body_colums_setting($('input[data-column="view"]'));
    ok(true, 'Клик по чекбоксу просмотр');
    $('input[data-column="seton"]').click();
    window.PGWS.body_colums_setting($('input[data-column="seton"]'));
    ok(true, 'Клик по чекбоксу включено');
    $('.disable-row').click();
    $.each($('.disable-row'), function(){
      window.PGWS.body_disabled_row(this);
    });
    ok(true, 'Клик по всем чекбоксам в колонке включено');
    $('.row-trigger').click();
    window.PGWS.body_visibility_row($('.row-trigger'));
    ok(true, 'Клик по чекбоксу Все поля');
  });
};

   /**
   * переопределили стандартный метод чтобы подставлять имя теста из селектора в ссылку при редиректе
   */
  QUnit.url = function(params){
    params = QUnit.extend( QUnit.extend( {}, QUnit.urlParams ), params );
    delete params['test_name'];
    var key,
    querystring = "?";
    for ( key in params ) {
      if ( QUnit.hasOwnProperty.call( params, key ) ) {
	querystring += encodeURIComponent( key ) + "=" +
	encodeURIComponent( params[ key ] ) + "&";
      }
    }
    querystring += encodeURIComponent( 'test_name' ) + "=" +
    encodeURIComponent( $('#selectTest').val() ) + "&";
    
    return window.location.protocol + "//" + window.location.host +
    window.location.pathname + querystring.slice( 0, -1 ); 
  };