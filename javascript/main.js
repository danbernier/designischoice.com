$(document).ready(function() {
  $('img.open').wrap(function() {
    var path = $(this).attr('src');
    return "<a href='" + path + "'></a>";
  });

  $('.gallery img').wrap(function() {
    var path = $(this).attr('src');
    return "<a href='" + path + "'></a>";
  });
});
