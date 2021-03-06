$(function () {

  // Hide these elements until they are needed (i.e. data loaded, etc.)
  $('.zoom-box').hide();
  $('#link-icon').hide();

  // The setup
  var options = {
    grid: { clickable: true },
    legend: { show: false },
    yaxis: {
      tickFormatter: function(val, axis) {
        return "F" + val.toFixed(1);
      }
    },
    xaxis: {
      tickFormatter: function(val, axis) {
        return val.toFixed(0) + "mm";
      }
    }
  }

  // Make clicking on points work
  $("#graph").bind("plotclick", function (event, pos, item) {
    if (item) {
      $("#focalLength").text(item.series.info['focal_length']);
      $("#aperture").text(item.series.info['aperture']);
      $("#price").text(item.series.info['price']);
      $("#link").text(item.series.label);
      $("#link").attr('href', item.series.info['link']);
      $("#link-icon").show();
      $("#preview").attr('src', item.series.info['image']);
      $("#preview-link").attr('href', item.series.info['link']);
    }
  });

  // Default to the first tab (Nikon)
  updateGraph("/lenses/nikon");

  // Use the links in the navbar to update the graph
  $('.update-graph').click(function() {
    $('.nav li').removeClass('active');
    $(this).parent().addClass('active');
    updateGraph($(this)[0].href);
    return false;
  });

  $('#loadingSpinner')
    .ajaxStart(function() { $(this).show(); })
    .ajaxStop(function()  { $(this).hide(); });

  // Redraw the graph with data from a given url
  function updateGraph(url) {
    $.ajax({
      url: url,
      method: "GET",
      dataType: "json",
      success: function(lenses) {
        drawGraph(lenses);
      }
    });
  }

  // Draw the graph and all related view controls
  function drawGraph(lenses) {
    data = [];
    min_focal_length = parseInt(lenses[0]['plot'][0]);
    max_focal_length = min_focal_length

    $.each(lenses, function(index, lens) {
      // Get all the data points (in zoom range) to plot on the graph
      data.push({
        data: lens['plot'],
        label: lens['name'],
        color: getColor(lens['price']),
        lines: { show: true },
        points: { show: true },
        info: lens
      });

      // Find minimum and maximum
      $.each(lens['plot'], function(index, value) {
        if (parseInt(value[0]) < min_focal_length)
          min_focal_length = parseInt(value[0])
        if (parseInt(value[0]) > max_focal_length)
          max_focal_length = parseInt(value[0])
      });
    });

    // Draw the graph with the data!
    $.plot($("#graph"), data, options);

    // Draw the zoom slider!
    $("#zoom-slider").slider({
      range: true,
      min: min_focal_length,
      max: max_focal_length,
      values: [min_focal_length, max_focal_length],
      slide: function(event, ui) {
        zoomX({"min": ui.values[0], "max": ui.values[1]});
      }
    });
    $("#min-zoom").show().val(min_focal_length);
    $("#max-zoom").show().val(max_focal_length);
  }

  // Make changing the zoom text boxes, actually zoom the graph
  $(".zoom-box").change(function() {
    var absMin = parseInt($("#zoom-slider").slider('option', 'min'));
    var absMax = parseInt($("#zoom-slider").slider('option', 'max'));
    var min = parseInt($("#min-zoom").val());
    var max = parseInt($("#max-zoom").val());
    var xaxis = {};
    if (min && min >= absMin && min < max) {
      xaxis['min'] = min;
    }
    if (max && max <= absMax && min < max) {
      xaxis['max'] = max;
    }
    zoomX(xaxis);
  });

  // Zoom the x axis of the graph and update the related controls
  function zoomX(xAxisOptions) {
    min = xAxisOptions["min"];
    max = xAxisOptions["max"];

    $.plot($("#graph"), getData(min, max),
      $.extend(true, {}, options, {
        xaxis: xAxisOptions
      })
    );

    if (min) {
      $("#min-zoom").val(min);
      $("#zoom-slider").slider("values", 0, min);
    }
    if (max) {
      $("#max-zoom").val(max);
      $("#zoom-slider").slider("values", 1, max);
    }
  }

  // Return a subset of the data
  function getData(minimum, maximum) {
    subset = [];
    $.each(data, function(i, lens) {
      push = true;
      $.each(lens.data, function(j, coordinates) {
        x = parseInt(coordinates[0]);
        if (x < minimum || x > maximum) { push = false }
      });
      if (push) { subset.push(lens); }
    });
    return subset;
  }

  // Generate RGB color between red and green
  function getColor(price) {
    price = parseInt(price.replace( /^\D+/g, ''));
    expensive = 1000;
    if (price > expensive) {
      return "rgb(255,0,0)";
    } else {
      x = parseInt((price / expensive) * 512)
      return x < 256 ? "rgb("+x+",255,0)" : "rgb(255,"+x+",0)";
    }
  }

});
