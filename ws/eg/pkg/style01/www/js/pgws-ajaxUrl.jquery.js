(function($) {
  "use strict";
  $.widget("ui.ajaxUrl", {
    options: {
      onSuccess: null,
      titleSuffix: '',
      titleDelim: ' - ',
      classMenuItemActive: null
    },
    generateUuid : function(){
      var uuid = '';
      for (var i = 0; i < 32; i++) {
        uuid += Math.floor(Math.random() * 16).toString(16);
      }
      return uuid;
    },
    identFunc: function(objIdent){
      var ident = $(objIdent).attr('ident');
      if(typeof ident == "undefined"){
        ident = this.generateUuid();
        $(objIdent).attr('ident', ident);
      }
      return ident;
    },
    clickUrl:function(obj){
      var titleTotal = $(obj).text() + this.options.titleDelim + this.options.titleSuffix;
      var titleTotalOld = $('a' + this.options.classMenuItemActive).text() + this.options.titleDelim + this.options.titleSuffix;
      document.title = titleTotal;
      var data = { title: titleTotal, ident:this.identFunc(obj),href:$(obj).attr('href')};
      var dataOld = { title: titleTotalOld, ident:this.identFunc('a' + this.options.classMenuItemActive),href:$('a' + this.options.classMenuItemActive).attr('href')};
      window.history.replaceState(dataOld,titleTotalOld, $('a' + this.options.classMenuItemActive).attr('href'));
      window.history.pushState(data,titleTotal, $(obj).attr('href'));
      this.options.onSuccess(obj);
      },
    _create: function() {
      self = this;
      $(window).bind("popstate",function(e){
        var state = e.originalEvent.state;
	self.options.onSuccess($('[ident='+state.ident+']'));
	document.title = state.title;
        return false;
      });
      $(this.element).click(function(){
	  self.clickUrl(this);
	return false;
      });
    }
  });
})(jQuery);

