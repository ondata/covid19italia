// carica definizione grafico Nazionale
var specN = "./spec/terapieIntensiveN.json";
// renderizza grafico Nazionale
vegaEmbed('#visN', specN, {
  theme: "fivethirtyeight",
  timeFormatLocale: {
    "dateTime": "%A %e %B %Y, %X",
    "date": "%d/%m/%Y",
    "time": "%H:%M:%S",
    "periods": ["AM", "PM"],
    "days": ["Domenica", "Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato"],
    "shortDays": ["Dom", "Lun", "Mar", "Mer", "Gio", "Ven", "Sab"],
    "months": ["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"],
    "shortMonths": ["Gen", "Feb", "Mar", "Apr", "Mag", "Giu", "Lug", "Ago", "Set", "Ott", "Nov", "Dic"]
  },
  actions: false
})

// carica definizione grafico Regionale
var specR = "./spec/terapieIntensiveR.json";
// renderizza grafico Regionale
vegaEmbed('#visR', specR, {
  theme: "fivethirtyeight",
  timeFormatLocale: {
    "dateTime": "%A %e %B %Y, %X",
    "date": "%d/%m/%Y",
    "time": "%H:%M:%S",
    "periods": ["AM", "PM"],
    "days": ["Domenica", "Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato"],
    "shortDays": ["Dom", "Lun", "Mar", "Mer", "Gio", "Ven", "Sab"],
    "months": ["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"],
    "shortMonths": ["Gen", "Feb", "Mar", "Apr", "Mag", "Giu", "Lug", "Ago", "Set", "Ott", "Nov", "Dic"]
  },
  actions: false
}).then(res => {
  view = res.view;
  console.log(view.data('source_0'));
})
