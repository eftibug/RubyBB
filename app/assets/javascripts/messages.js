$(document).ready(function(){
  $('a.delete_notification').bind('click', function(){
    $(this).parents('tr').hide('slow');
  });

  $('tr.folded .message, tr.foldable .message').bind('click', function() {
    $this = $(this);
    $tr = $this.parents('tr');
    if ($tr.hasClass('unread')) {
      $tr.find('.read_notification').click();
      $tr.removeClass('unread');
    }
    $this.parents('tr').toggleClass('folded').toggleClass('foldable');
  });
});
