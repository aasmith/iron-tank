function expandableSections() {
  $(arguments).each(function(idx, className) {
    $("."+className+":not(.remaining) div:not(.expanded)").
      css({cursor:'pointer'});
  
    $("."+className+" div:not(.expanded)").click(
      function(){
        var h = $("~ .expanded:hidden", this);
        var v = $("~ .expanded:visible", this);
        h.size() == 1 ? 
          h.animate({height:"show"}, 250, "easeInOutExpo") :
          v.animate({height:"hide"}, 250, "easeInOutExpo") ;
      }
    )
  });
};

