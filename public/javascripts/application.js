function expandableSections() {
  $(arguments).each(function(idx, className) {

    $(className).toggle(
      function() {
        $(".expanded", this).animate({height: "show"}, 250, "easeInOutExpo");
      },
      function() {
        $(".expanded", this).animate({height: "hide"}, 250, "easeInOutExpo");
      }
    )

  });
};

