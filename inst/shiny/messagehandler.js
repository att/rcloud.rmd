
Shiny.addCustomMessageHandler(
    "rcloudexport",
    function(message) {
        post_to_url(
            message.url + '/api.R/create',
            { "json": JSON.stringify(message.notebook) },
            'post'
        );
    }
);

// http://stackoverflow.com/questions/133925/
// javascript-post-request-like-a-form-submit/3259946#3259946
function post_to_url(path, params, method) {
    method = method || "post";

    var form = document.createElement("form");

    //Move the submit function to another variable
    //so that it doesn't get overwritten.
    form._submit_function_ = form.submit;

    form.setAttribute("method", method);
    form.setAttribute("action", path);

    for(var key in params) {
        var hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("name", key);
        hiddenField.setAttribute("value", params[key]);

        form.appendChild(hiddenField);
    }

    document.body.appendChild(form);
    form._submit_function_(); //Call the renamed function.
}
