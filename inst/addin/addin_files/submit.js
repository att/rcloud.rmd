// non-empty line to mitigate a whisker bug
var notebook = {{{ notebook }}};

function cancelrmd() {
    window.close();
}

function updateFormAction(url) {
  $('#import-form').attr('action', url + "/api.R/create");
}

$(
  function() {
    $( "#rcloud_url_custom" ).on('input', function(event) {
          var val = $('#rcloud_url_custom')[0].value;
          if(val != "") {
            updateFormAction(val)
          } else {
            updateFormAction($('#rcloud_url_predefined').val())
          }
        });
    $('#rcloud_url_predefined').on('change', function () {
          if($('#rcloud_url_custom')[0].value === "") {
            updateFormAction($('#rcloud_url_predefined').val())
          }
        });
  }
)
$(
  function() {
    $( "#json" )[0].value = JSON.stringify(notebook);
    updateFormAction($('#rcloud_url_predefined').val())
  }
)