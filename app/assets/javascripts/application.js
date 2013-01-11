//= require jquery
//= require jquery_ujs
//= require jquery.caretposition
//= require jquery.sew
//= require jquery.tablednd
//= require textarea.jquery
//= require garlic
//= require bootstrap
//= require markdown.converter
//= require markdown.sanitizer
//= require markdown.editor
//= require gritter
//= require users
//= require topics
//= require forums
//= require messages
//= require highcharts
//
// Troubles with require_tree which includes scripts twice
// require_tree .

var values = [];
$(document).ready(function() {
  // Does not submit forms twice
  $('form:not([data-remote])').submit(function(){
    $this = $(this);
    if ($this.data('submitted')) {
      return false;
    } else {
      $this.find('input[type=submit]').addClass('disabled');
      $this.data('submitted', true);
    }
  });

  // small messages

  $(document).on('ajax:beforeSend', 'a.delete_small_message', function(){
    $(this).css('visibility', 'hidden');
  }).on('ajax:complete', 'a.delete_small_message', function(){
    $(this).parent().hide('slow');
  });

  $('form.new_small_message').bind('ajax:beforeSend', function(e, data){
    $(this).find('#small_message_content').blur().attr('value', '').attr('disabled', 'disabled').css('visibility', 'hidden');
  })
});
