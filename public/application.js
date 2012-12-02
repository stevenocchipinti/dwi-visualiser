$(function () {

  var data = [];
  var options = {
    grid: { clickable: true },
    legend: { show: false }
  }
  $("#graph").bind("plotclick", function (event, pos, item) {
    if (item) {
      $("#focalLength").val(item.series.info['focal_length']);
      $("#aperture").val(item.series.info['aperture']);
      $("#price").val(item.series.info['price']);
      $("#link").text(item.series.label);
      $("#link").attr('href', item.series.info['link']);
      $("#preview").attr('src', item.series.info['image']);
      $("#preview-link").attr('href', item.series.info['link']);
    }
  });

  // Default to the first tab (Nikon)
  updateGraph("/nikon");


  // TODO: DRY this up!
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
    $("#zoom-slider").slider({
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
            label: value['name'],
            lines: { show: true },
            points: { show: true },
            info: value
          });
        });
        $.plot($("#graph"), data, options);
      }
    });
  }


});
