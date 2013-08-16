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
      onError:            null,
      code:            	  null
    },
    deleteF : function(t, id, prefix, code){
      var file_id = parseInt($(t.element).attr('fileid').replace(/[^0-9]/,""),10);
      $.ajax({
        url: prefix + t.options.action,
        dataType: "json",
        data: {
          id: id,
          file_id: file_id,
          code: code		
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
	bootbox.confirm("Вы действительно хотите удалить файл?", 'Отмена', function(result) {
	  if(result){
	    self.deleteF(self,self.options.id,self.options.prefix, self.options.code);
	  }
	}); 
        return false;
      });
    }
  });
})(jQuery);

var fetchProgress = function(uuid,interval,objElement) {
      var req = new XMLHttpRequest();
      req.open('GET', '/upload/status', 1);
      req.setRequestHeader('X-Progress-ID', uuid);
      req.onreadystatechange = function () {
        if (req.readyState === 4) {
          if (req.status === 200) {
            /* poor-man JSON parser */
            var upload = eval(req.responseText);
            if (upload.state === 'uploading' && upload.received > 0) {
              var percentComplete = Math.floor((upload.received / upload.size)*1000/10);
              $('.file-list table .'+uuid).find('.bar').css('width',percentComplete+'%');
            }
            if (upload.state === 'done' || upload.state === 'error') {
	      window.clearTimeout(interval);
            }
          }
        }
      };
      req.send(null);
};
var generateUuid = function(){
      var uuid = '';
      for (var i = 0; i < 32; i++) {
        uuid += Math.floor(Math.random() * 16).toString(16);
      }
      return uuid;
};
