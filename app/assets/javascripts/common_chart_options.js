var commonChartOptions = {
  title: { text: null },
  xAxis: { showEmpty: false },
  yAxis: { showEmpty: false },
  legend: {
    align: 'center',
    x: -30,
    margin: 20,
    verticalAlign: 'bottom',
    floating: false,
    backgroundColor: 'white',
    shadow: false
  },
  plotOptions: {
    bar: {
      stacking: 'normal',
    },
    column: {
      dataLabels: {
        color: '#232b49'
      },
    },
    pie: {
      allowPointSelect: true,
      colors: ["#9c3367", "#67347f", "#501e74", "#935fb8", "#e676a3", "#e4558b", "#7a9fb1", "#5297c6", "#97c086", "#3f7d69", "#6dc691", "#8e8d6b", "#e5c07c", "#e9d889", "#e59757", "#f4966c", "#e5644e", "#cd4851", "#bd4d65", "#515749"],
      cursor: 'pointer',
      dataLabels: { enabled: false },
      showInLegend: true,
      point: {
        events: {
          legendItemClick: function () {
            return false;
          }
        }
      }
    },
    line: {
      tooltip: {
        headerFormat: '<b>{point.key}</b><br>',
        pointFormat: '{point.y:.2f} kW'
      }
    },
    scatter: {
      marker: {
        radius: 5,
        states: {
          hover: {
            enabled: true,
            lineColor: 'rgb(100,100,100)'
          }
        }
      },
      states: {
        hover: {
          marker: {
            enabled: false
          }
        }
      },
      tooltip: {
        headerFormat: '<b>{series.name}</b><br>',
        pointFormat: '{point.x:.2f} °C, {point.y:.2f} kWh'
      }
    }
  }
}


function barColumnLine(d, c, chartIndex, seriesData, chartType) {
  var subChartType = d.chart1_subtype;
  console.log('bar or column or line ' + subChartType);

  var xAxisCategories = d.x_axis_categories;
  var yAxisLabel = d.y_axis_label;
  var y2AxisLabel = d.y2_axis_label;

  c.xAxis[0].setCategories(xAxisCategories);

  // BAR Charts
  if (chartType == 'bar') {
    console.log('bar');
    c.update({ chart: { inverted: true }, yAxis: [{ stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }], plotOptions: { bar: { tooltip: { headerFormat: '<b>{series.name}</b><br>', pointFormat: yAxisLabel + '{point.y:.2f}' }}}});
  }

  // LINE charts
  if (chartType == 'line') {
    if (y2AxisLabel !== undefined && y2AxisLabel == 'Temperature') {
      console.log('Yaxis - Temperature');
      c.addAxis({ title: { text: '°C' }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}, opposite: true });
      c.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: '{point.y:.2f} °C' }}}});
    } else {
      c.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: '{point.y:.2f}' + yAxisLabel }}}});
    }
  }

  // Column charts
  if (chartType == 'column') {
    console.log('column: ' + subChartType);
    c.update({ chart: { zoomType: 'x'}, subtitle: { text: document.ontouchstart === undefined ?  'Click and drag in the plot area to zoom in' : 'Pinch the chart to zoom in' }});


    if (subChartType == 'stacked') {
      c.update({ plotOptions: { column: { tooltip: { headerFormat: '<b>{series.name}</b><br>', pointFormat: '{point.y:.2f}' + yAxisLabel }, stacking: 'normal'}}, yAxis: [{title: { text: yAxisLabel }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' } } }]});
    } else {
      c.update({ plotOptions: { column: { tooltip: { headerFormat: '<b>{series.name}</b><br>', pointFormat: '{point.y:.2f}' + yAxisLabel }}}});
    }

    if (y2AxisLabel !== undefined && y2AxisLabel == 'Temperature') {
      console.log('Yaxis - Temperature days');
      c.addAxis({ title: { text: '°C' }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}, opposite: true });
      c.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: '{point.y:.2f} °C' }}}});
    }
    if (y2AxisLabel !== undefined && y2AxisLabel == 'Degree Days') {
      console.log('Yaxis - Degree days');
      c.addAxis({ title: { text: 'Degree days' }, stackLabels: { style: { fontWeight: 'bold',  color: '#232b49' }}, opposite: true });
      c.update({ plotOptions: { line: { tooltip: { headerFormat: '<b>{point.key}</b><br>',  pointFormat: '{point.y:.2f} Degree days' }}}});
    }
  }

  Object.keys(seriesData).forEach(function (key) {
    console.log('Series data name: ' + seriesData[key].name);

    if (seriesData[key].name == 'CUSUM') {
      c.update({ plotOptions: { line: { tooltip: { pointFormat: '{point.y:.2f}', valueSuffix: yAxisLabel }}}});
    }

    if (isAStringAndStartsWith(seriesData[key].name, 'Energy') && seriesData[key].type == 'line') {
      console.log(seriesData[key]);
      seriesData[key].tooltip = { pointFormat: '{point.y:.2f} ' + yAxisLabel  }
      seriesData[key].dashStyle =  'Dash';
    }
    // The false parameter stops it being redrawed after every addition of series data
    c.addSeries(seriesData[key], false);
  });

  updateChartLabels(d, c);

  c.redraw();
}

function updateChartLabels(data, chart){

  var yAxisLabel = data.y_axis_label;
  var xAxisLabel = data.x_axis_label;

  if (yAxisLabel) {
    console.log('we have a yAxisLabel ' + yAxisLabel);
    chart.update({ yAxis: [{ title: { text: yAxisLabel }}]});
  }

  if (xAxisLabel) {
    console.log('we have a xAxisLabel ' + xAxisLabel);
    chart.update({ xAxis: [{ title: { text: xAxisLabel }}]});
  }
}

function isAStringAndStartsWith(thing, startingWith) {
  // IE Polyfill for startsWith
  if (!String.prototype.startsWith) {
    String.prototype.startsWith = function(search, pos) {
      return this.substr(!pos || pos < 0 ? 0 : +pos, search.length) === search;
    };
  }

  (typeof thing === 'string' || thing instanceof String) && thing.startsWith('Energy')
}

function scatter(d, c, chartIndex, seriesData) {
  console.log('scatter');


  updateChartLabels(d, c);
  c.update({chart: { type: 'scatter', zoomType: 'xy'}, subtitle: { text: document.ontouchstart === undefined ?  'Click and drag in the plot area to zoom in' : 'Pinch the chart to zoom in' }});


  Object.keys(seriesData).forEach(function (key) {
    console.log(seriesData[key].name);
    c.addSeries(seriesData[key], false);
  });
  c.redraw();
}

function pie(d, c, chartIndex, seriesData, $chartDiv) {
  $chartDiv.addClass('pie-chart');
  var chartHeight = $chartDiv.height();
  var yAxisLabel = d.y_axis_label;

  c.addSeries(seriesData, false);
  c.update({chart: {
    height: chartHeight,
    plotBackgroundColor: null,
    plotBorderWidth: null,
    plotShadow: false,
    type: 'pie'
  },
  plotOptions: {
   pie: {
    tooltip: {
        headerFormat: '<b>{point.key}</b><br>',
        pointFormat: '{point.y:.2f} ' + yAxisLabel
      }
    }
  }
  });
  c.redraw();
}
