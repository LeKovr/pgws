/*
  Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.

  This document is licensed as free software under the terms of the
  MIT License: http://www.opensource.org/licenses/mit-license.php

  jQuery PGWS Autocomplete patch
  project: PGWS, http://rm2.tender.pro/projects/pgws/
  version: 1.0 (2012-07-29)
*/

function monkeyPatchAutocomplete() {
  var oldFn = $.ui.autocomplete.prototype._renderItem;
  $.ui.autocomplete.prototype._renderItem = function(ul, item) {
    //  var re = this.term;
    var re = new RegExp(this.term, "ig") ;
    var t = item.label.replace(re,"<span style='font-weight:bold;color:Red;'>" + this.term + "</span>");
    return $("<li></li>")
    .data("item.autocomplete", item)
    .append("<a>" + t + "</a>")
    .appendTo(ul);
  };
}
