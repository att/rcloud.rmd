
((function() {

    return {
        init: function(ocaps, k) {

            // Are we in a notebook?
            if (RCloud.UI.advanced_menu.add) {

                oc = RCloud.promisify_paths(ocaps, [
                    [ 'importRmd' ]
                ], true);

                RCloud.UI.advanced_menu.add({

                    rmdImport: {
                        sort: 10001,
                        text: 'Import Rmarkdown file',
                        modes: ['edit'],
                        action: function() {
                            var that = this;

                            function create_import_file_dialog() {
                                var notebook_raw = null;
                                var notebook = null;
                                var notebook_status = null;
                                var import_button = null;

                                function do_upload(file) {
                                    notebook_status.hide();
                                    var fr = new FileReader();
                                    fr.onloadend = function(e) {
                                        notebook_status.show();
                                        notebook_status.html(
                                            '<pre>' + fr.result.split("\n")
                                                .slice(0,15)
                                                .join("\n") + '\n...\n</pre>'
                                        );
                                        ui_utils.enable_bs_button(import_button);
                                        notebook_raw = fr.result;
                                    };
                                    fr.readAsText(file);

                                }

                                function do_import() {
                                    var desc = "Imported from Rmarkdown";

                                    // Need to call back to R to import the notebook
                                    oc.importRmd(notebook_raw).then(
                                        function(x) {
                                            console.log(x);
                                            notebook = Notebook.sanitize(x);
                                            if (notebook && desc.length > 0) {
                                                notebook.description = desc;

                                                rcloud.create_notebook(notebook, false).then(function(notebook) {
                                                    editor.star_notebook(true, {notebook: notebook}).then(function() {
                                                        editor.set_notebook_visibility(notebook.id, true);

                                                        // highlight the node:
                                                        editor.highlight_imported_notebooks(notebook);
                                                    });
                                                });

                                                dialog.modal('hide');
                                            }
                                        }
                                    );
                                }

                                var body = $('<div class="container"/>');
                                var file_select = $('<input type="file" id="notebook-file-upload" size="50"></input>');

                                file_select
                                    .click(function() {
                                        ui_utils.disable_bs_button(import_button);
                                        notebook_status.hide();
                                        file_select.val(null);
                                    })
                                    .change(function() {
                                        do_upload(file_select[0].files[0]);
                                    });

                                notebook_status = $('<div />');
                                notebook_status.append(notebook_status);

                                body.append($('<p/>').append(file_select))
                                    .append($('<p/>').append(notebook_status.hide()));
                                var cancel = $('<span class="btn btn-cancel">Cancel</span>')
                                    .on('click', function() { $(dialog).modal('hide'); });
                                import_button = $('<span class="btn btn-primary">Import</span>')
                                    .on('click', do_import);

                                ui_utils.disable_bs_button(import_button);

                                var footer = $('<div class="modal-footer"></div>')
                                    .append(cancel).append(import_button);
                                var header = $(['<div class="modal-header">',
                                                '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>',
                                                '<h3>Import Notebook File</h3>',
                                                '</div>'].join(''));
                                var dialog = $('<div id="import-notebook-file-dialog" class="modal fade"></div>')
                                    .append($('<div class="modal-dialog"></div>')
                                            .append($('<div class="modal-content"></div>')
                                                    .append(header).append(body).append(footer)));
                                $("body").append(dialog);
                                dialog
                                    .on('show.bs.modal', function() {
                                        $("#notebook-file-upload")[0].value = null;
                                        notebook_status.text('');
                                        notebook_status.hide();
                                    });

                                // keep selected file, in case repeatedly importing is helpful
                                // but do reset Import button!
                                dialog.data("reset", function() {
                                    notebook = null;
                                    ui_utils.disable_bs_button(import_button);
                                });
                                return dialog;
                            }
                            var dialog = $("#import-notebook-file-dialog");
                            if(!dialog.length)
                                dialog = create_import_file_dialog();
                            else
                                dialog.data().reset();
                            dialog.modal({keyboard: true});

                        }       // action

                    }           // rmdImport

                });
            }

            k()

        }
    };

})());
