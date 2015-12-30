/*
  Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.

  This document is licensed as free software under the terms of the
  MIT License: http://www.opensource.org/licenses/mit-license.php

  jQuery PGWS utility functions
  project: PGWS, http://rm2.tender.pro/projects/pgws/
  version: 2.1 (2009-08-14)
*/

var l = function(){
  "use strict";
  // 4rows from http://www.webtoolkit.info/javascript-sprintf.html
  if (typeof arguments === "undefined") { return null; }
  if (arguments.length < 1) { return null; }
  if (typeof arguments[0] !== "string") { return null; }
  if (typeof RegExp === "undefined") { return null; }

  var string = arguments[0];
  if (arguments.length > 0) {
    for (var i = 1; i < arguments.length; i++)  {
      var re = new RegExp('\\[_'+i+'\\]', "g");
      string = string.replace(re, arguments[i]);
    }
  }
  return string;
};

var show_debug = function(data){
  "use strict";
  var s='';
  var ht = $('#debug-console').html();
  if (data && $('#debug-console')) {
    var i, len, row;
    for ( i = 0, len = data.length; i<len; ++i ){
      row = data[i];
      s = s + l('<tr class="[_1]"><td nowrap valign="top" width="30%">[ [_2] / [_3] / [_4] ] [_5] / [_6]</td><td>[_7]</td></tr>',
      (i % 2)?'even':'odd', row.source, row.stage, row.level, row.caller, row.line,
      (row.message)?row.message:'<pre id="debug-'+i+'" style="font-size:9px; color: grey"></pre>'
      );
    }
    ht = (ht !== '') ? '<hr style="margin:15px 0px;" />' + ht : '';
    $('#debug-console > table > tbody').prepend(s + '<tr><td colspan="2"><hr></td></tr>');
    for ( i = 0, len = data.length; i<len; ++i ){
      row = data[i];
      if (! row.message) { $('#debug-'+ i).text(row.data); }
    }
  }
};

$.fn.serializeObject = function(formId) {
  "use strict";
  var o = {};
  var a = this.serializeArray();
  var formId = '#' + this.attr('id');
  $.each(a, function() {
    $(formId + '_' + this.name + '_err').text('');
    if (o[this.name]) {
      if (!o[this.name].push) {
        o[this.name] = [o[this.name]];
      }
      o[this.name].push(this.value || '');
    } else {
      o[this.name] = this.value || '';
    }
  });
  // Пересылаем значение checkbox, даже если он не отмечен
  // Т.к. в этом случае простой сабмит не отправляет ничего,
  // а мы хотим получить на сервер значение 0 для checkbox-а без галочки
  // TODO: this.find('input[type=checkbox]:not(:checked):not(:disabled)').map(
  $(formId + ' input[type=checkbox]:not(:checked):not(:disabled)').map(
    function() {
      o[this.name] = 0
    }
  );
  if (o['_id']) {
    // TODO: иногда id не попадает в сериализацию
    o['id'] = o['_id']; delete o['_id'];
  }
  if (!o['_join']) {
    // обычный вариант, без сборки массивов
    return o;
  }
  // при наличии поля _join производится сериализация массивов
  var pref = o['_join']; delete o['_join']; // or software error
  var fields = o[pref + '._field'].split(' '); delete o[pref + '._field'];
  var index = o[pref + '._index']; delete o[pref + '._index'];
  // ---- вариант для хэша массивов
  for(var x = 0; x < o[index].length; x++) {
    for(var y = 0; y < fields.length; y++) {
      var key = [pref, o[index][x], fields[y]].join('.');
      var z = o[key]; delete o[key];
      if (!x) o[fields[y]] = [];
      o[fields[y]].push(z);
    }
 }
  return o;
};

var api_input_enable = function(formId) {
  $.each($(formId)[0].elements, function(k, v) {
    if ($(this).hasClass('tmpPGWSDisabled')) $(this).removeAttr('disabled').removeClass('tmpPGWSDisabled');
  });
  $('.fileinput-button').removeClass('disabled'); //disabled для кнопки Выбора файлы, т.к. она span
}

var api = function(mtd, formId, cb, vparams, cb_er, ena, options){
  "use strict";
  options = $.extend(true, {
     statusBlock: '#status',
     errorBlock:'#errors',
     debugForm:'#debug-form',
     apiLog:'#api-log'
  }, options);

  $(options.statusBlock).text(options.processMsg);
  $(options.errorBlock).text('');
  var req = {
    id: 77,
    jsonrpc: '2.0',
    method: mtd,
    sid: window.PGWS.req.sid,
    lang: window.PGWS.req.lang,
    params: vparams,
    debug: $(options.debugForm).serializeObject()
  };
  $.ajax({
    type:         "POST",
    url:          window.PGWS.req.post_uri,
    data:         $.toJSON(req),
    processData:  false,
    async:        true,
    timeout:      2400000, // msec
    contentType:  "application/json",
    dataType:     "json",
    success:      function(response){
      if (ena) { api_input_enable(formId) }
      show_debug(response.debug);
      if (response.error) {
        var msg = options.sysErrorMsg + ': ' + response.error.code + '. '+ response.error.message;
        $(options.statusBlock).text(msg);
        $(options.apiLog).append(msg + '<br />');
        if (cb_er) { cb_er(formId, response);}
      } else if (response.result.error) {
        for ( var i = 0, len = response.result.error.length; i < len; ++i ){
          var t = formId + '_' + response.result.error[i].id + '_err';
          $(t).text(response.result.error[i].message);
	  $(formId + ' > div.control-group').addClass('error');
        }
        $(options.statusBlock).text(options.formErrorMsg);
        if (cb_er) { cb_er(formId, response);}
      } else {
        $(options.statusBlock).text(options.successMsg);
        $(formId + ' > div.control-group').removeClass('error');
        if (cb) { 
	  cb(formId, response.result.data);
	}
      }
    },
    error:        function(response){
      var msg = options.reqErrorMsg + ': ' + response.status + '. '+ response.statusText;
      $(options.statusBlock).text(msg);
      $(options.apiLog).append(msg + '<br />');
      if (ena) { api_input_enable(formId) }
      show_debug(response.debug);
      if (cb_er) { cb_er(formId, response);}
    }
  });
};

var api_form = function(action, formId, onSuccesse, onError, options){
  "use strict";
  options = $.extend(true, {
    statusBlock: '#status',
    errorBlock:'#errors',
    debugForm:'#debug-form',
    apiLog:'#api-log',
    sysErrorMsg: 'System error',
    formErrorMsg: 'Form error(s)',
    reqErrorMsg: 'Request error',
    successMsg: 'OK',
    processMsg: 'In process...',
    ena: true
  }, options);

  var params = $(formId).serializeObject();
  $.each($(formId)[0].elements, function(k, v) {
    if ($(this).attr('disabled') !== 'disabled') $(this).addClass('tmpPGWSDisabled').attr('disabled','disabled');
  });
  $('.fileinput-button').addClass('disabled');//disabled для кнопки Выбора файлы, т.к. она span
  api(action, formId, onSuccesse, params, onError, options.ena, options);
};
