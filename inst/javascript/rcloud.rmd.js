
((function() {

    return {
        init: function(ocaps, k) {

            // Are we in a notebook?
            if (RCloud.UI.advanced_menu.add) {

                RCloud.UI.advanced_menu.add({

                    rmdImport: {
                        sort: 10001,
                        text: 'Import Rmarkdown file',
                        modes: ['edit'],
                        action: function() {

                            console.log("Importing RMD!");

                        }
                    }

                });
            }

            k()

        }
    };

})());
