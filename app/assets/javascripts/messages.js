$(document).ready(function(){
  $('tr.folded .message, tr.foldable .message').bind('click', function() {
    $this = $(this);
    $tr = $this.parents('tr');
    if ($tr.hasClass('unread')) {
      $tr.find('.read_notification').click();
    }
    $this.parents('tr').toggleClass('folded').toggleClass('foldable');
  });
});
