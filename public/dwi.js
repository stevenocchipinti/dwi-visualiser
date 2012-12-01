$(function () {

  var data = [];
  var options = {
    grid: { clickable: true },
    legend: { show: false }
  }
  updateGraph("/nikon");
  $("#graph").bind("plotclick", function (event, pos, item) {
    // TODO: Show inidividual lens attributes
    if (item) {
      $("#info").text(item.series.label);
    }
  });


  $('.nikon-link').click(function() {
    $('.nav li').removeClass('active');
    $(this).parent().addClass('active');
    updateGraph("/nikon");
  });
  $('.canon-link').click(function() {
    $('.nav li').removeClass('active');
    $(this).parent().addClass('active');
    updateGraph("/canon");
  });
  $('.sigma-link').click(function() {
    $('.nav li').removeClass('active');
    $(this).parent().addClass('active');
    updateGraph("/sigma");
  });
  $('.tamron-link').click(function() {
    $('.nav li').removeClass('active');
    $(this).parent().addClass('active');
    updateGraph("/tamron");
  });
  $('.tokina-link').click(function() {
    $('.nav li').removeClass('active');
    $(this).parent().addClass('active');
    updateGraph("/tokina");
  });

  $(function() {
    $("#slider-range").slider({
      range: true,
      min: 0,    // TODO: Calculate the actual minimum and maximum
      max: 500,
      values: [0, 500],
      slide: function(event, ui) {
        zoom(ui.values[0], ui.values[1]);
      }
    });
  });

  function zoom(minimum, maximum) {
    $.plot($("#graph"), data,
      $.extend(true, {}, options, {
        xaxis: { min: minimum, max: maximum }
      })
    );
  }

  function updateGraph(url) {
    $.ajax({
      url: url,
      method: "GET",
      dataType: "json",
      success: function(lenses) {
        data = [];
        $.each(lenses, function(index, value) {
          data.push({
            data: value['plot'],
            label: value['name'] + " - " + value['price'],
            lines: { show: true },
            points: { show: true }
          });
        });
        $.plot($("#graph"), data, options);
      }
    });
  }


});
