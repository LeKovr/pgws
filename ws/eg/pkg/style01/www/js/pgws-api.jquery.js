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
    $('#debug-console').html('<table class="debug">' + s + '</table>' + ht);
    for ( i = 0, len = data.length; i<len; ++i ){
      row = data[i];
      if (! row.message) { $('#debug-'+ i).text(row.data); }
    }
  }
};

$.fn.serializeObject = function(formid) {
  "use strict";
  var o = {};
  var a = this.serializeArray();
  $.each(a, function() {
    $(formid+'_'+this.name+'_err').text(''); // TODO: get formid from 'this"
    if (o[this.name]) {
      if (!o[this.name].push) {
        o[this.name] = [o[this.name]];
      }
      o[this.name].push(this.value || '');
    } else {
      o[this.name] = this.value || '';
    }
  });
  return o;
};

var api = function(mtd, formid, cb, vparams, cb_er, ena,options){
  "use strict";
  options = $.extend(true, {
     statusBlock: '#status',
     errorBlock:'#errors',
     debugForm:'#debug-form',
     apiLog:'#api-log'
  }, options);

  $(options.statusBlock).text( "In process..." );
  $(options.errorBlock).text('');
  var req = {
    id: 77,
    jsonrpc: '2.0',
    method: mtd,
    sid: window.PGWS.req.sid,
    lang: window.PGWS.req.lang,
    params: vparams,
    debug: $(options.debugForm).serializeObject(options.debugForm)
  };
  $.ajax({
    type:         "POST",
    url:          window.PGWS.req.post_uri,
    data:         $.toJSON(req),
    processData:  false,
    async:        true,
    timeout:      30000, // msec
    contentType:  "application/json",
    dataType:     "json",
    success:      function(response){
      if (ena) { $(formid+':input').removeAttr("disabled"); }
      show_debug(response.debug);
      if (response.error) {
        $(options.statusBlock).text("System error: " + response.error.code + ': '+ response.error.message);
        $(options.apiLog).append(l('System error [_1]: [_2]<br />', response.error.code, response.error.message));
        if (cb_er) { cb_er(formid, response);}
      } else if (response.result.error) {
        for ( var i = 0, len = response.result.error.length; i < len; ++i ){
          var t = formid + '_' + response.result.error[i].id+'_err';
          $(t).text(response.result.error[i].message);
        }
        $(options.statusBlock).text( "Form error(s)" );
        if (cb_er) { cb_er(formid, response);}
      } else {
        $(options.statusBlock).text( "OK" );
        if (cb) { cb(formid, response.result.data);}
      }
    },
    error:        function(response){
      $(options.statusBlock).text("Request error: " + response.status + ': '+ response.statusText);
      $(options.apiLog).append(l('Error [_1]: [_2]<br />', response.status, response.statusText));
      if (ena) { $(formid+' :input').removeAttr("disabled"); }
      show_debug(response.debug);
      if (cb_er) { cb_er(formid, response);}
    }
  });
};

var api_form = function(action, form, onSuccesse, onError, options){
  "use strict";
  options = $.extend(true, {
    statusBlock: '#status',
    errorBlock:'#errors',
    debugForm:'#debug-form',
    apiLog:'#api-log'
  }, options);

  var params = $(form).serializeObject($(form).attr('id'));
  $($(form).attr('id')+' :input').attr("disabled","disabled");
  api(action, $(form).attr('id'), onSuccesse, params, onError, true,options);
};
