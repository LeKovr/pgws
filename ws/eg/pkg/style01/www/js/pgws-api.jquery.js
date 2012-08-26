/*
  Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.

  This document is licensed as free software under the terms of the
  MIT License: http://www.opensource.org/licenses/mit-license.php

  jQuery PGWS utility functions
  project: PGWS, http://rm2.tender.pro/projects/pgws/
  version: 2.1 (2009-08-14)
*/

function l() {
  // 4rows from http://www.webtoolkit.info/javascript-sprintf.html
  if (typeof arguments == "undefined") { return null; }
  if (arguments.length < 1) { return null; }
  if (typeof arguments[0] != "string") { return null; }
  if (typeof RegExp == "undefined") { return null; }

  var string = arguments[0];
  if (arguments.length > 0) {
    for (var i = 1; i < arguments.length; i++)  {
      var re = new RegExp('\\[_'+i+'\\]', "g");
      string = string.replace(re, arguments[i]);
    }
  }
  return string;
}

$.fn.serializeObject = function(formid)
{
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

// based on: http://asistobe851.hp.infoseek.co.jp/JavaScript/json-rpc.html
  function api_form (mtd, formid, cb, cb_er){
    params = $(formid).serializeObject(formid)
    $(formid+' :input').attr("disabled","disabled");
    api(mtd, formid, cb, params, cb_er, true);
  }
  function api(mtd, formid, cb, vparams, cb_er, ena){
      $("#status").text( "In process..." );
      $("#errors").text('');
      req = {
        id: 77,
        jsonrpc: '2.0',
        method: mtd,
        sid: PWL_sid,
        lang: PWL_lang,
        params: vparams,
        debug: $('#debug-form').serializeObject('#debug-form')
      };
        $.ajax({
          type: "POST",
          url: PWL_post_uri,
          data: $.toJSON(req),
          processData: false,
          async: true,
          timeout: 30000, // msec
          contentType: "application/json",
          dataType: "json",
          success: function(response){
            if (ena) $(formid+' :input').removeAttr("disabled");
            show_debug(response.debug);
            if (response.error) {
              $("#status").text("System error: " + response.error.code + ': '+ response.error.message);
              $("#api-log").append(l('System error [_1]: [_2]<br />', response.error.code, response.error.message));
              if (cb_er) { cb_er(formid, response);}
            } else if (response.result.error) {
              for ( var i=0, len=response.result.error.length; i<len; ++i ){
                t = formid+'_'+response.result.error[i].id+'_err';
                $(t).text(response.result.error[i].message);
              }
              $("#status").text( "Form error(s)" );
              if (cb_er) { cb_er(formid, response);}
            } else {
              $("#status").text( "OK" );
             if (cb) { cb(formid, response.result.data);}
            }
          },
          error: function(response){
            $("#status").text("Request error: " + response.status + ': '+ response.statusText);
            $("#api-log").append(l('Error [_1]: [_2]<br />', response.status, response.statusText));
            if (ena) $(formid+' :input').removeAttr("disabled");
            show_debug(response.debug);
            if (cb_er) { cb_er(formid, response);}
          }
        });
      }

function show_debug(data) {
  var s='';
  var ht = $("#debug-console").html();
  if (data && $("#debug-console")) {
    for ( var i = 0, len = data.length; i<len; ++i ){
      var row = data[i];
      s = s + l('<tr class="[_1]"><td nowrap valign="top" width="30%">[ [_2] / [_3] / [_4] ] [_5] / [_6]</td><td>[_7]</td></tr>',
                (i % 2)?'even':'odd', row.source, row.stage, row.level, row.caller, row.line,
                (row.message)?row.message:'<pre id="debug-'+i+'" style="font-size:9px; color: grey"></pre>');
    }
    ht = (ht != '') ? '<hr style="margin:15px 0px;" />' + ht : '';
    $("#debug-console").html('<table class="debug">' + s + '</table>' + ht);
    for ( var i = 0, len = data.length; i<len; ++i ){
      var row = data[i];
      if (! row.message) { $("#debug-" + i).text(row.data); }
    }
  }
}
