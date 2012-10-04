/*
  Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.

  This document is licensed as free software under the terms of the
  MIT License: http://www.opensource.org/licenses/mit-license.php

  jQuery Upload functions
  project: PGWS, http://rm2.tender.pro/projects/pgws/
  version: 1.0 (2012-08-26)
*/
(function($) {
  "use strict";
  $.widget("ui.deleteFile", {
    options: {
      action:             null,
      classFile:          '.fileDiv',
      classErrorMessage:  '.deleteStatusError',
      id:                 null,
      prefix:             null,
      onSuccess:          null,
      onError:            null
    },
    deleteF : function(t, id, prefix){
      var file_id = parseInt($(t.element).attr('fileid').replace(/[^0-9]/,""),10);
      $.ajax({
        url: prefix + t.options.action,
        dataType: "json",
        data: {
          id: id,
          file_id: file_id
        },
        success: function( data ) {
          var cont = $(t.element).parents(t.options.classFile);
            if(data.success === 'true'){
              t.options.onSuccess(t,cont);
            }else{
              t.options.onError(t,cont,$(data.result.error).get(0).message);
            }

        }
      });
    },
    _create: function() {
      var self = this;
      $(this.element).click(function(){
        self.deleteF(self,self.options.id,self.options.prefix);
        return false;
      });
    }
  });
})(jQuery);

(function($) {
  "use strict";
  $.widget("ui.formFieldUpload", {
    options: {
      onSuccess:        null,
      onError:          null,
      template:         null,
      statusUrl:        '/upload/status',
      btnReset:         '.process .btnReset',
      objProgressBar:   '.progressbarDiv',
      prepareContainer: '.prepare',
      processContainer: '.process',
      spanLabel:        '.label',
      spanPercent:      '.pb-percent',
      spanSec:          '.pb-sec',
      spanStatus:       '.ui-progressbar-label',
      inputFile:        '.inputFile'
    },
    addForm: function(self){
      var tmpl = this.options.template;
      var container = $(tmpl).clone().appendTo(self.element);
      container.find(this.options.inputFile).change(function(){ container.find('input[type=submit]').removeClass('hide'); });
      container.removeClass('hide');
      var interval;
      container.find(self.options.btnReset).click(function(){
        window.clearTimeout($(this).attr('id'));
        var xhr = $(this).data('xhr');
        if (xhr.readyState === 1) {
          xhr.abort('cancelled');
        }
      });

      container.find('form').ajaxForm({
        beforeSubmit: function(formData, jqForm, settings) {
          container.attr('seconds', 1);
          var uuid = self.generateUuid();
          settings.url = self.options.action + '?X-Progress-ID=' + uuid;
          interval = window.setInterval(function () {
            self.fetchProgress(container, uuid, self.options);
          },1000);
        },
        beforeSend: function(jqXHR, settings){
          container.find(self.options.btnReset).attr('id', interval).data('xhr', jqXHR);
          var objInput = container.find(self.options.inputFile);
          container.find(self.options.spanLabel).text(objInput.val()+': ');
          container.find(self.options.prepareContainer).hide();
          container.find(self.options.processContainer).removeClass('hide');
          container.find(self.options.objProgressBar).progressbar({value: 0.0});
          container.find(self.options.spanStatus).hide();
        },
        error: function(jqXHR, textStatus, errorThrown){
          window.clearTimeout(interval);
          container.find(self.options.processContainer).addClass('hide');
          self.options.onError(container, jqXHR, textStatus, errorThrown);
          if (jqXHR.statusText === 'cancelled') {
            container.find(self.options.prepareContainer).show();
            container.find(self.options.spanLabel).text('');
          }
        },
        success: function(data, responseText, statusText, form) {
          window.clearTimeout(interval);
          container.find(self.options.processContainer).hide();
          self.options.onSuccess(container, data);
        },
        dataType: 'json',
        contentType: 'multipart/form-data',
        async: true
      });
    },
    _create: function() {
      var self = this;
      $(self.element).find('.add').click(function(){ self.addForm(self); });
    },
    generateUuid : function(){
      var uuid = '';
      for (var i = 0; i < 32; i++) {
        uuid += Math.floor(Math.random() * 16).toString(16);
      }
      return uuid;
    },
    fetchProgress : function(container, uuid, options) {
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
    }
  });
})(jQuery);
