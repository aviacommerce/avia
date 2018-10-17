import MainView from '../main';

export default class View extends MainView {
    mount() {
        super.mount();

        var ctxbar = document.getElementById("barChart").getContext('2d');
        var barChart = new Chart(ctxbar, {
            type: 'bar',
            data: {
                labels: barchart.labels,
                datasets: [{
                    label: 'No of Orders',
                    data: barchart.data,
                    backgroundColor: '#3e95cd'
                }]
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true
                        }
                    }]
                }
            }
        });

        var ctxline = document.getElementById("lineChart").getContext('2d');
        var lineChart = new Chart(ctxline, {
            type: 'line',
            data: {
                labels: linechart.labels,
                datasets: [{
                    data: linechart.data,
                    currency: linechart.currency,
                    label: "Revenue",
                    borderColor: "#3e95cd",
                    fill: false
                }
                ]
            },
            options: {
                tooltips: {
                    // Disable the on-canvas tooltip
                    enabled: false,
        
                    custom: function(tooltipModel) {
                        // Tooltip Element
                        var tooltipEl = document.getElementById('chartjs-tooltip');
        
                        // Create element on first render
                        if (!tooltipEl) {
                            tooltipEl = document.createElement('div');
                            tooltipEl.id = 'chartjs-tooltip';
                            tooltipEl.innerHTML = "<table></table>";
                            document.body.appendChild(tooltipEl);
                        }
        
                        // Hide if no tooltip
                        if (tooltipModel.opacity === 0) {
                            tooltipEl.style.opacity = 0;
                            return;
                        }
        
                        // Set caret Position
                        tooltipEl.classList.remove('above', 'below', 'no-transform');
                        if (tooltipModel.yAlign) {
                            tooltipEl.classList.add(tooltipModel.yAlign);
                        } else {
                            tooltipEl.classList.add('no-transform');
                        }
        
                        function getBody(bodyItem) {
                            return bodyItem.lines;
                        }
        
                        // Set Text
                        if (tooltipModel.body) {
                            var titleLines = tooltipModel.title || [];
                            var bodyLines = tooltipModel.body.map(getBody);
        
                            var innerHtml = '<thead>';
        
                            titleLines.forEach(function(title) {
                                innerHtml += '<tr><th>' + title + '</th></tr>';
                            });
                            innerHtml += '</thead><tbody>';
        
                            bodyLines.forEach(function(body, i) {
                                var colors = tooltipModel.labelColors[i];
                                var style = 'background:' + colors.backgroundColor;
                                style += '; border-color:' + colors.borderColor;
                                style += '; border-width: 2px';
                                var span = '<span style="' + style + '"></span>';
                                innerHtml += '<tr><td>' + span + body + ' (' + `${linechart.currency[i]}` + ')' + '</td></tr>';
                            });
                            innerHtml += '</tbody>';
        
                            var tableRoot = tooltipEl.querySelector('table');
                            tableRoot.innerHTML = innerHtml;
                        }
        
                        // `this` will be the overall tooltip
                        var position = this._chart.canvas.getBoundingClientRect();
        
                        // Display, position, and set styles for font
                        tooltipEl.style.opacity = 1;
                        tooltipEl.style.backgroundColor = 'lightgrey';
                        tooltipEl.style.position = 'absolute';
                        tooltipEl.style.left = position.left + window.pageXOffset + tooltipModel.caretX + 'px';
                        tooltipEl.style.top = position.top + window.pageYOffset + tooltipModel.caretY + 'px';
                        tooltipEl.style.fontFamily = tooltipModel._bodyFontFamily;
                        tooltipEl.style.fontSize = tooltipModel.bodyFontSize + 'px';
                        tooltipEl.style.fontStyle = tooltipModel._bodyFontStyle;
                        tooltipEl.style.padding = tooltipModel.yPadding + 'px ' + tooltipModel.xPadding + 'px';
                        tooltipEl.style.pointerEvents = 'none';
                    }
                }
            }
        });
    }

    unmount() {
        super.unmount();
    }
}
