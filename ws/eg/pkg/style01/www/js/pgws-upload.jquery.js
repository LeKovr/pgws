/*
  Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.

  This document is licensed as free software under the terms of the
  MIT License: http://www.opensource.org/licenses/mit-license.php

  jQuery Upload functions
  project: PGWS, http://rm2.tender.pro/projects/pgws/
  version: 1.0 (2012-08-26)
*/

function fetch(formId, uuid, options, uri) {
  trueid = formId.substr(11);
  req = new XMLHttpRequest();
  req.open("GET", "/upload/status", 1);
  req.setRequestHeader("X-Progress-ID", trueid);
  req.onreadystatechange = function () {
    if (req.readyState == 4) {
      if (req.status == 200) {
        /* poor-man JSON parser */
        var upload = eval(req.responseText);
        if (upload.state == 'uploading' && upload.received > 0) {
          upload.percents = Math.floor((upload.received / upload.size)*1000/10);
          var speed = 0;
          speed = upload.received - $('#rq'+trueid).val();
          $('#rq'+trueid).val(upload.received);
          var remaining = (upload.size - upload.received) / speed;
          var tRemaining = parseInt(remaining) + ' сек.';
          $('#progressbar'+trueid).progressbar({value: upload.percents});
          $('#progressbar'+trueid).find(".pblabel").text(upload.percents+'%'+' Осталось: '+tRemaining);
        }
        if (upload.state == 'done' || upload.state == 'error') {
          window.clearTimeout(options.interval);
        }
      }
    }
  }
  req.send(null);
}
function showSubmit(t){
  $(t).parent().parent().find('input[type=submit]').show();
}
function clickSubmit(t){
  objParent = $(t).parent().parent();
  objFile = $(objParent).find('input[type=file]');
  $(objFile).parent().append('<font >'+$(objFile).val()+'</font>');
  $(objFile).hide();
  $(t).hide();
}

function stopreq(xhr,t) {
  window.clearTimeout($(t).attr('id'));
  xhr.abort();
}

function hideLoad(t, uuid){
  $("#progressbar"+uuid).hide();
  $(t).hide();
  $(t).parent().parent().find('font').hide();
  $('#loadButton').show();
}

function showBlock(t, uri, doc_id){
  uuid = "";
  for (i = 0; i < 32; i++) {
    uuid += Math.floor(Math.random() * 16).toString(16);
  }
  var options = {
    beforeSubmit: function (formData, jqForm, options) {
      var formId = jqForm.context.id;

      // patch the form-action tag to include the progress-id
      //      options.url = "/upload/share?X-Progress-ID=" + uuid;
      // call the progress-updater every 1000ms
      trueid = formId.substr(11);
      interval = window.setInterval(
        function () {
          fetch(formId, trueid, options, uri);
        },
        1000
      );
      options.interval = interval;
      return true;
    },
    beforeSend: function(jqXHR, settings){
      var link = $('<input />');
      link.attr('value','Отмена');
      link.attr('type', 'button');
      link.attr('id', interval);
      link.attr('onclick', 'hideLoad(this,\''+trueid+'\')');
      link.click(function(){ return stopreq(jqXHR,this) });
      objF = $('#upload-form'+trueid);
      $(objF).find('#upload-form-close').html(link);
    },
    dataType: 'json',
    contentType: 'multipart/form-data',
    async: true
  };

  $(t).parent().append("<form method='post' enctype='multipart/form-data' id='upload-form"+uuid+"' action='/upload/_"+uri+".json?X-Progress-ID=" + uuid+"'><div id='divUpload' ><div class='form' style='float:left;width: auto;'><input type='file' name='name' onchange='showSubmit(this)' /></div><div style=\'float:left;width: auto;\'><input type='submit' value='Отправить' hidden onclick='clickSubmit(this)'></div><div style='float:left;width: auto;'><div id='progressbar"+uuid+"' style='width: 150px'><span class='pblabel'></span><input id='rq"+uuid+"' type='hidden' value='0'></div></div><div id='upload-form-close'></div></div> </form><br><br>");

  $('#upload-form'+uuid).ajaxForm(options);
}

