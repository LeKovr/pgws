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
