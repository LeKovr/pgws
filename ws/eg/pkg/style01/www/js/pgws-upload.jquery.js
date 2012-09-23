/*
  Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.

  This document is licensed as free software under the terms of the
  MIT License: http://www.opensource.org/licenses/mit-license.php

  jQuery Upload functions
  project: PGWS, http://rm2.tender.pro/projects/pgws/
  version: 1.0 (2012-08-26)
*/
$.fn.formFieldUpload = function(options) {

  "use strict";

  var generateUuid = function(){
    var uuid = '';
    for (var i = 0; i < 32; i++) {
      uuid += Math.floor(Math.random() * 16).toString(16);
    }
    return uuid;
  };

  var fetchProgress = function(container, uuid, options) {
    var req = new XMLHttpRequest();
    req.open('GET', options.statusUrl, 1);
    req.setRequestHeader('X-Progress-ID', uuid);
    req.onreadystatechange = function () {
      if (req.readyState === 4) {
        if (req.status === 200) {
          /* poor-man JSON parser */
          var upload = eval(req.responseText);
          if (upload.state === 'uploading' && upload.received > 0) {
            var percentComplete = Math.floor((upload.received / upload.size)*1000/10);
            var seconds = parseFloat(container.attr('seconds'));
            var speed = upload.received / seconds;
            container.attr('seconds', seconds + 1);
            var remaining = Math.floor((upload.size - upload.received)/ speed) + 1;
            container.find(options.objProgressBar).progressbar('option', 'value', percentComplete);
            container.find(options.spanPercent).text(percentComplete);
            container.find(options.spanSec).text(remaining);
            container.find(options.spanStatus).show();
          }
          if (upload.state === 'done' || upload.state === 'error') {
            var objButton = container.find(options.btnReset);
            window.clearTimeout(objButton.attr('id'));
          }
        }
      }
    };
    req.send(null);
  };
  var addForm = function($self, options){
    var tmpl = $(options.template);
    var container = tmpl.clone().appendTo($self);
    container.find(options.inputFile).change(function(){ container.find('input[type=submit]').removeClass('hide'); });
    container.removeClass('hide');
    var interval;
    container.find('form').ajaxForm({
      beforeSubmit: function(formData, jqForm, settings) {
        container.attr('seconds', 1);
        var uuid = generateUuid();
        settings.url = options.action + '?X-Progress-ID=' + uuid;
        interval = window.setInterval(function () {
          fetchProgress(container, uuid, options);
          },
          1000
        );
      },
      beforeSend: function(jqXHR, settings){
        container.find(options.btnReset).attr('id', interval).click(function(){
          window.clearTimeout($(this).attr('id'));
          jqXHR.abort();
          if (options.clearOnStop) {
            container.hide();
          } else {
            container.find(options.processContainer).addClass('hide');
            container.find(options.prepareContainer).show();
            container.find(options.spanLabel).text('');
          }
        });
        var objInput = container.find(options.inputFile);
        container.find(options.spanLabel).text(objInput.val()+': ');
        container.find(options.prepareContainer).hide();
        container.find(options.objProgressBar).progressbar({value: 0.0});
        container.find(options.processContainer).removeClass('hide');
        container.find(options.spanStatus).hide();
      },
      error: function(jqXHR, textStatus, errorThrown){
        window.clearTimeout(interval);
        jqXHR.abort();
        options.onError(container, jqXHR, textStatus, errorThrown);
      },
      success: function(data, responseText, statusText, form) {
        window.clearTimeout(interval);
        container.find(options.processContainer).hide();
        options.onSuccess(container, data);
      },
      dataType: 'json',
      contentType: 'multipart/form-data',
      async: true
    });
  };

  // ----------------------------------------------------------------------------
  // All options listed here
  options = $.extend(true, {
    onSuccess:        null,
    onError:          null,
    template:         null,
    clearOnStop:      false,
    statusUrl:        '/upload/status',
    btnReset:         '.process .btnReset',
    objProgressBar:   '.progressbarDiv',
    prepareContainer: '.prepare',
    processContainer: '.process',
    spanLabel:        '.label',
    spanPercent:      '.pb-percent',
    spanSec:          '.pb-sec',
    spanStatus:       '.pb',
    inputFile:        '.inputFile'
  }, options);

  var $self = $(this);
  $self.find('.add').click(function(){ addForm($self, options); });

};
