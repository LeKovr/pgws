(function($) {
  "use strict";
  $.widget("ui.ajaxUrl", {
    options: {
      onSuccess: null,
      titleSuffix: '',
      titleDelim: ' - '
    },
    generateUuid : function(){
      var uuid = '';
      for (var i = 0; i < 32; i++) {
        uuid += Math.floor(Math.random() * 16).toString(16);
      }
      return uuid;
    },
    clickUrl:function(obj){
      var titleTotal = $(obj).text() + this.options.titleDelim + this.options.titleSuffix;
      document.title = titleTotal;
      var ident = $(obj).attr('ident');
      if(typeof ident == "undefined"){
        ident = this.generateUuid();
        $(obj).attr('ident', ident);
      }
      var data = { title: titleTotal, ident:ident};
      window.history.pushState(data,titleTotal, $(obj).attr('href'));
      this.options.onSuccess(obj);
    },
    _create: function() {
      self = this;
      $(window).bind("popstate",function(e){
        var state = e.originalEvent.state;
        window.location.href.replace = location.pathname;
        document.title = state.title;
        $(self.options.contentBlockId).html(state.content);
        self.options.onSuccess($('[ident='+state.ident+']'));
        return false;
      });

      $(this.element).click(function(){
        self.clickUrl(this);
        return false;
      });
    }
  });
})(jQuery);
