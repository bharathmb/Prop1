//Result01

// (function (H) {
//     function deferRender (proceed) {
//         console.log(this.chart.container.parentNode.id)
//         var series = this, 
//             $renderTo = $(this.chart.container.parentNode);
//         console.log("r",$renderTo.is(':appeared'),$renderTo.is(':visible'),$renderTo.is(':animated'))
//         // It is appeared, render it
//         // if ($renderTo.is(':appeared') || !series.options.animation) {
//         //     console.log("if")
//         //     proceed.call(series);
            
//         // // It is not appeared, halt renering until appear
//         // } else  {
//             console.log("else")
//             $('#' + this.chart.container.parentNode.id).appear(); // Initialize appear plugin
//             $('#' + this.chart.container.parentNode.id).on('appear', function () {
//                 proceed.call(series);
//             });
//             $('#' + this.chart.container.parentNode.id).on('disappear', function () {
//                 proceed.call(series);
//             });
//         // }
//     };
    
//     H.wrap(H.Series.prototype, 'render', deferRender);
    
// }(Highcharts));



Highcharts.chart('Result01', {

  chart: {
      height: 230,
      width: 855,

  },

  title: {
      text: 'Defaulters - ROC Curves'
  },

  credits: {
      enabled: false
  },

  // subtitle: {
  //   text: 'Source: thesolarfoundation.com'
  // },


  xAxis: {
      categories: ['0.0', '0.2', '0.4', '10', '2', '1.0', '1.2', '1.4']
  },

  yAxis: {
      title: {
          text: 'Hit Rate ( Sensitivity )'
      },
  },


  legend: {
      layout: 'vertical',
      align: 'right',
      verticalAlign: 'middle'
  },

  plotOptions: {
      series: {
          animation: {
              duration: 10000,
              easing: 'easeOutBounce'
          },
          label: {
              connectorAllowed: false
          },
          pointStart: 0
      }
  },

  series: [{
      name: 'Area under the curve',
      data: [2, 3, 4, 8, 9, 10]
  },
      //   {
      //   name: 'Manufacturing',
      //   data: [0.6, 1.2, 0.9, 1.6, 2.8, 0]
      // }, 
  ],

  responsive: {
      rules: [{
          condition: {
              maxWidth: 200
          },
          chartOptions: {
              legend: {
                  layout: 'horizontal',
                  align: 'center',
                  verticalAlign: 'bottom'
              }
          }
      }]
  }

});




//Result02

Highcharts.chart('Result02', {
  chart: {
      height: 230,
      width: 855
  },

  title: {
      text: 'Hit Rate vs Capture Rate'
  },

  credits: {
      enabled: false
  },


  // subtitle: {
  //   text: 'Source: thesolarfoundation.com'
  // },

  yAxis: {
      title: {
          text: 'Hit Rate | Capture Rate'
      }
  },

  xAxis: {
      categories: ['0.0', '0.2', '0.4', '10', '2', '1.0', '1.2', '1.4']
  },

  legend: {
      layout: 'vertical',
      align: 'right',
      verticalAlign: 'middle'
  },

  plotOptions: {
      series: {
          animation: {
              duration: 10000,
              easing: 'easeOutBounce'
          },
          label: {
              connectorAllowed: false
          },
          pointStart: 0
      }
  },

  series: [{
      name: 'Hit Rate',
      data: [1.2, 7.5, 3.8, 6.2, 9.2, 3.3, 2, 4.2]
  },
  {
      name: 'Capture Rate',
      data: [0.6, 1.2, 0.9, 1.6, 2.8, 0]
  },
  ],

  responsive: {
      rules: [{
          condition: {
              maxWidth: 200
          },
          chartOptions: {
              legend: {
                  layout: 'horizontal',
                  align: 'center',
                  verticalAlign: 'bottom'
              }
          }
      }]
  }

});




//Evaluate01
Highcharts.chart('Evaluate01', {
  chart: {
      height: 230,
      width: 540
  },

  title: {
      text: 'Model Loss'
  },

  credits: {
      enabled: false
  },


  // subtitle: {
  //   text: 'Source: thesolarfoundation.com'
  // },

  yAxis: {
      title: {
          text: 'Training | Validation'
      }
  },

  xAxis: {
      categories: ['0.0', '0.2', '0.4', '10', '2', '1.0', '1.2', '1.4']
  },

  legend: {
      layout: 'vertical',
      align: 'right',
      verticalAlign: 'middle'
  },

  plotOptions: {
      series: {
          animation: {
              duration: 20000,
              easing: 'easeOutBounce'
          },
          label: {
              connectorAllowed: false
          },
          pointStart: 0
      }
  },

  series: [{
      name: 'Training',
      data: [1.2, 7.5, 3.8, 6.2, 9.2, 3.3, 2, 4.2]
  },
  {
      name: 'Validation',
      data: [0.6, 1.2, 0.9, 1.6, 2.8, 0]
  },
  ],

  responsive: {
      rules: [{
          condition: {
              maxWidth: 200
          },
          chartOptions: {
              legend: {
                  layout: 'horizontal',
                  align: 'center',
                  verticalAlign: 'bottom'
              }
          }
      }]
  }

});



//Evaluate02

Highcharts.chart('Evaluate02', {
  chart: {
      height: 230,
      width: 540
  },

  title: {
      text: 'Model Accuracy'
  },

  credits: {
      enabled: false
  },


  // subtitle: {
  //   text: 'Source: thesolarfoundation.com'
  // },

  yAxis: {
      title: {
          text: 'Training | Validation'
      }
  },

  xAxis: {
      categories: ['0.0', '0.2', '0.4', '10', '2', '1.0', '1.2', '1.4']
  },

  legend: {
      layout: 'vertical',
      align: 'right',
      verticalAlign: 'middle'
  },

  plotOptions: {
      series: {
          animation: {
              duration: 20000,
              easing: 'easeOutBounce'
          },
          label: {
              connectorAllowed: false
          },
          pointStart: 0
      }
  },

  series: [{
      name: 'Training',
      data: [7.2, 3.5, 5.8, 4.2, 9.2, 3.3, 5, 8.2]
  },
  {
      name: 'Validation',
      data: [1.6, 2.2, 0.2, 2.6, 1.8, 2.0]
  },
  ],

  responsive: {
      rules: [{
          condition: {
              maxWidth: 200
          },
          chartOptions: {
              legend: {
                  layout: 'horizontal',
                  align: 'center',
                  verticalAlign: 'bottom'
              }
          }
      }]
  }

});





//variable profiling

Highcharts.chart('variable-profiling', {
  chart: {
      type: 'column',
      height: 420,
      width: 710,
      inverted: true
  },

  title: {
      text: 'World\'s largest cities per 2017'
  },

  credits: {
      enabled: false
  },

  // subtitle: {
  //     text: 'Source: <a href="http://en.wikipedia.org/wiki/List_of_cities_proper_by_population">Wikipedia</a>'
  // },

  xAxis: {
      type: 'category',
      labels: {
          rotation: -45,
          // style: {
          //     fontSize: '13px',
          //     fontFamily: 'Verdana, sans-serif'
          // }
      }
  },

  yAxis: {
      min: 0,
      title: {
          text: 'Population (millions)'
      }
  },

  legend: {
      enabled: false
  },

  tooltip: {
      pointFormat: 'Population in 2017: <b>{point.y:.1f} millions</b>'
  },

  plotOptions: {
      series: {
          animation: {
              duration: 10000
          },
          label: {
              connectorAllowed: false
          },
          pointStart: 0
      }
  },

  series: [{
      name: 'Population',
      data: [
          ['Shanghai', 12.2],
          ['Beijing', 20.8],
          ['Karachi', 14.9],
          ['Shenzhen', 13.7],
          ['Guangzhou', 23.1],
          ['Istanbul', 12.7],
          ['Mumbai', 19.4],
          ['Moscow', 28.2],
          ['São Paulo', 12.0],
          ['Delhi', 21.7],
          // ['Kinshasa', 15.5],
          // ['Tianjin', 28.2],
          // ['Lahore', 11.1],
          // ['Jakarta', 21.6],
          // ['Dongguan', 5.6],
          // ['Lagos', 10.6],
          // ['Bengaluru', 17.3],
          // ['Seoul', 9.8],
          // ['Foshan', 16.3],
          // ['Tokyo', 20.3]
      ],
      dataLabels: {
          enabled: true,
          //rotation: -90,
          color: '#FFF',
          align: 'right',
          format: '{point.y:.1f}', // one decimal
          y: 0, // 10 pixels down from the top
          style: {
              fontSize: '11px',
              // fontFamily: 'Verdana, sans-serif'
          }
      }
  }]
});




//varaible-profiling-02

Highcharts.chart('dose', {
  chart: {
      type: 'column',
      width: 360,
      height: 420
  },

  credits: {
      enabled: false
  },


  title: {
      text: 'Dose'
  },

  xAxis: {
      categories: ['0', '5', '10']
  },

  yAxis: {
      min: 0,
      title: {
          text: 'Len'
      }
  },

  // plotOptions: {
  //     series: {
  //         animation: {
  //             duration: 2000,
  //         }
  //     }
  // },

  plotOptions: {
      series: {
          animation: {
              duration: 10000
          },
          label: {
              connectorAllowed: false
          },
          pointStart: 0
      }
  },

  series: [{
      name: 'Dose',
      data: [
          29.9, 71.5, 106.4
      ],
      dataLabels: {
          enabled: true,
          rotation: -90,
          color: '#FFF',
          align: 'right',
          format: '{point.y:.1f}', // one decimal
          y: 10, // 10 pixels down from the top
          style: {
              fontSize: '11px',
              // fontFamily: 'Verdana, sans-serif'
          }
      }
  }]
 
});
