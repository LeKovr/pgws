// ----------------------------------------------------------------------------
/*
 * jQuery FormEV Plugin
 * version: 0.3 (2012-09-04)
 *
 * This document is licensed as free software under the terms of the
 * MIT License: http://www.opensource.org/licenses/mit-license.php
 *
 * @copy 2012, Tender.Pro team
 *
 * Project repository: https://github.com/LeKovr/formEV
 */

$.fn.formEV = function(options) {

  "use strict";

  // ----------------------------------------------------------------------------
  // Saving callback example
  var onSubmitExample = function(container, cbSaveSuccess, cbFormDisable, cbFormEnable) {
    var form = container.is('form')?container : container.find('form');
    var params = $(form).serializeArray();
    var post = JSON.stringify(params, null, 2);
    cbFormDisable(container);
    setTimeout(function() {
      window.alert("Ready to send:\n" + post);
      cbFormEnable(container);
      cbSaveSuccess(container);
    }, 2000);
  };

  // ----------------------------------------------------------------------------
  // All options listed here
  options = $.extend(true, {
    fldContainer:     '.editable',          // selector for every form field container
    btnContainer:     '.buttons',           // button container selector
    itemView:         '.view',              // view mode container
    itemEdit:         '.edit',              // edit mode container
    btnEdit:          '.edit_on',           // button to show edit mode
    btnSubmit:        '.save',              // submit control
    btnReset:         '.reset',             // reset control
    chkOn:            '.on',                // checkbox 'On' value container
    chkOff:           '.off',               // checkbox 'Off' value container
    tmpDisabledClass: 'disabled_till_send', // class for input disabling while submit processing
    onSubmit:         onSubmitExample,      // function called when user clicks Submit
    onViewReady:      null                  // function called when fields are ready to be shown in View mode
  }, options);

  // ----------------------------------------------------------------------------
  // Set Edit/View mode
  var show = function (container, isEdit) {
    var h = (isEdit ? options.itemView : options.itemEdit);
    var s = (isEdit ? options.itemEdit : options.itemView);
    container.find(h).hide();
    container.find(s).show();
  };

  // ----------------------------------------------------------------------------
  // Fill Read mode data from inputs
  var refresh = function(container) {
    container.find(options.fldContainer).each(function() {
      var field = $(this).children(options.itemEdit);
      var needWrite = true;
      var target = $(this).children(options.itemView);
      var val;
      if (field.is('select')) {
        val = field.children('option:selected').text();
      } else if ( field.is('label') ) {  // radio
        val = field.find('input[type="radio"]:checked').parent().text();
      } else if ( field.is('input[type="checkbox"]') ) {
        var h = field.is(':checked') ? options.chkOff : options.chkOn;
        var s = field.is(':checked') ? options.chkOn : options.chkOff;
        target.children(h).hide();
        target.children(s).show();
        needWrite = false;
      } else  {
        // text field
        val = field.val();
      }
      if (needWrite) {
        target.text(val);
      }
    });
    if (options.onViewReady) { options.onViewReady(container); }
  };

  // ----------------------------------------------------------------------------
  // Switch to view mode after successfull submit
  var cbSubmitSuccess = function(container) {
    refresh(container);
    show(container, false);
  };

  // ----------------------------------------------------------------------------
  // Disable fields for edit while saving
  var cbFormDisable = function(container) {
    container.find(options.itemEdit).not(':disabled').addClass(options.tmpDisabledClass).attr('disabled', 'disabled');
    // also disable radio inside label
    container.find(options.itemEdit + ' :input').not(':disabled').addClass(options.tmpDisabledClass).attr('disabled', 'disabled');
  };

  // ----------------------------------------------------------------------------
  // Enable back fields for edit after successfull saving
  var cbFormEnable = function(container) {
    container.find('.' + options.tmpDisabledClass).removeAttr('disabled').removeClass(options.tmpDisabledClass);
  };

  // ----------------------------------------------------------------------------
  // Save form data
  var submitForm = function(container) {
    options.onSubmit(container, cbSubmitSuccess, cbFormDisable, cbFormEnable);
  };

  // ----------------------------------------------------------------------------
  // Initialize containers at start
  this.each(function(){
    var container = $(this);
    var btns = container.find(options.btnContainer);
    btns.find(options.btnEdit).click(function()   { show(container, true); });
    btns.find(options.btnReset).click(function()  { show(container, false); return true; });
    btns.find(options.btnSubmit).click(function() { submitForm(container); return false; });
    refresh(container);
  });
};
