<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-gb" lang="en-gb" dir="ltr">
    <head>
        <base href="http://www.highcharts.com/" />
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta name="robots" content="index, follow" />
        <title>code.highcharts.com</title>
        <link href="/favicon.ico" rel="shortcut icon" type="image/x-icon" />
        <link rel="stylesheet" href="/templates/yoo_symphony/css/template.css" type="text/css" />
        <link rel="stylesheet" href="/templates/yoo_symphony/css/variations/brown.css" type="text/css" />
        <link rel="stylesheet" href="/templates/yoo_symphony/css/custom.css" type="text/css" />
        <style type="text/css">
            body {
                margin: 10px
            }
            h2 {
                color: black;
                background: #DDD;
                padding: 0.3em;
            }
        </style>
        <script src="http://code.jquery.com/jquery.min.js"></script>
        <script>
            $(function() {
                $('li').each(function() {
                    var $li = $(this),
                        url = $li.html();
                    $li.html("<a href='"+ url + "'>" + url + "</a>");
                });
            });
        </script>
    </head>
    <body>
        <h1 style="color:red">Error on Highcharts file service</h1>
        <h4>Please check the url you used with the patterns listed here.</h4>

        <h2>Highcharts</h2>
        <h4>Latest stable</h4>
        <p>The latest stable version of Highcharts is served from the root of code.highcharts.com:</p>
        <ul>
            <li>http://code.highcharts.com/highcharts.js</li>
            <li>http://code.highcharts.com/highcharts.src.js</li>
            <li>http://code.highcharts.com/highcharts-more.js</li>
            <li>http://code.highcharts.com/highcharts-more.src.js</li>
            <li>http://code.highcharts.com/modules/exporting.js</li>
            <li>http://code.highcharts.com/modules/exporting.src.js</li>
            <li>http://code.highcharts.com/adapters/mootools-adapter.js</li>
            <li>http://code.highcharts.com/adapters/mootools-adapter.src.js</li>
            <li>http://code.highcharts.com/adapters/prototype-adapter.js</li>
            <li>http://code.highcharts.com/adapters/prototype-adapter.src.js</li>
        </ul>

        <h4>Specific version</h4>
        <p>You'll find a specific Highcharts version by appending the version number to the root level:</p>
        <ul>
            <li>http://code.highcharts.com/2.2.4/highcharts.js</li>
            <li>http://code.highcharts.com/2.2.4/modules/exporting.js</li>
            <li>http://code.highcharts.com/2.2.4/highcharts-more.js</li>
            <li>http://code.highcharts.com/2.2.4/adapters/mootools-adapter.js</li>
        </ul>

        <h4>Truncated versions</h4>
        <p>By truncating the version number you'll be able to load the latest stable release within that
        major version number. For example, <strong>2.2</strong> points to the latest stable 2.2.x, but when
        2.3 or 3.0 is released, you will still load the latest release of 2.2.</p>
        <ul>
            <li>http://code.highcharts.com/2.2/highcharts.js</li>
            <li>http://code.highcharts.com/2.2/highcharts-more.js</li>
            <li>http://code.highcharts.com/2.2/modules/exporting.js</li>
            <li>http://code.highcharts.com/2.2/adapters/mootools-adapter.js</li>
        </ul>


        <h2>Highstock</h2>
        <p>Highstock files are available under the <strong>/stock</strong> subfolder, with the same folder
            structure as above.</p>

        <h4>Latest stable</h4>
        <p>The latest stable versjon of Highstock is served from code.highcharts.com/stock:</p>
        <ul>
            <li>http://code.highcharts.com/stock/highstock.js</li>
            <li>http://code.highcharts.com/stock/highstock.src.js</li>
            <li>http://code.highcharts.com/stock/highcharts-more.js</li>
            <li>http://code.highcharts.com/stock/highcharts-more.src.js</li>
            <li>http://code.highcharts.com/stock/modules/exporting.js</li>
            <li>http://code.highcharts.com/stock/modules/exporting.src.js</li>
            <li>http://code.highcharts.com/stock/adapters/mootools-adapter.js</li>
            <li>http://code.highcharts.com/stock/adapters/mootools-adapter.src.js</li>
            <li>http://code.highcharts.com/stock/adapters/prototype-adapter.js</li>
            <li>http://code.highcharts.com/stock/adapters/prototype-adapter.src.js</li>
        </ul>

        <h4>Specific version</h4>
        <p>You'll find a specific Highcharts version by appending the version number to the /stock folder:</p>
        <ul>
            <li>http://code.highcharts.com/stock/1.2.5/highstock.js</li>
            <li>http://code.highcharts.com/stock/1.2.5/highcharts-more.js</li>
            <li>http://code.highcharts.com/stock/1.2.5/modules/exporting.js</li>
            <li>http://code.highcharts.com/stock/1.2.5/adapters/mootools-adapter.js</li>
        </ul>

        <h4>Truncated versions</h4>
        <ul>
            <li>http://code.highcharts.com/stock/1.2/highstock.js</li>
            <li>http://code.highcharts.com/stock/1.2/highcharts-more.js</li>
            <li>http://code.highcharts.com/stock/1.2/modules/exporting.js</li>
            <li>http://code.highcharts.com/stock/1.2/adapters/mootools-adapter.js</li>
        </ul>




        <h2>Latest development from GitHub</h2>
        <p>The file path can be pointed to a specific branch, commit or tag in
            <a href="https://github.com/highslide-software/highcharts.com/">our GitHub repo</a>.
            Both Highcharts and Highstock share the same repo, so you'll find highcharts.src.js
            and highstock.src.js on the same level.</p>

        <h4>Branch: "master"</h4>
        <ul>
            <li>http://github.highcharts.com/master/highcharts.src.js</li>
            <li>http://github.highcharts.com/master/highcharts-more.js</li>
            <li>http://github.highcharts.com/master/highstock.src.js</li>
            <li>http://github.highcharts.com/master/modules/exporting.src.js</li>
            <li>http://github.highcharts.com/master/adapters/mootools-adapter.src.js</li>
            <li>http://github.highcharts.com/master/adapters/prototype-adapter.src.js</li>
        </ul>

        <h4>Specific commit: "efed5f14f7"</h4>
        <ul>
            <li>http://github.highcharts.com/efed5f14f7/highcharts.src.js</li>
            <li>http://github.highcharts.com/efed5f14f7/highstock.src.js</li>
            <li>http://github.highcharts.com/efed5f14f7/highcharts-more.js</li>
            <li>http://github.highcharts.com/efed5f14f7/modules/exporting.src.js</li>
            <li>http://github.highcharts.com/efed5f14f7/adapters/mootools-adapter.src.js</li>
            <li>http://github.highcharts.com/efed5f14f7/adapters/prototype-adapter.src.js</li>
        </ul>

        <h4>Tag: "v2.0.0"</h4>
        <p>See <a href="https://github.com/highslide-software/highcharts.com/tags">the available tags</a>
            on GitHub.</p>
        <ul>
            <li>http://github.highcharts.com/v2.2.0/highcharts.src.js</li>
            <li>http://github.highcharts.com/v2.2.0/highstock.src.js</li>
            <li>http://github.highcharts.com/v2.2.0/highcharts-more.js</li>
            <li>http://github.highcharts.com/v2.2.0/modules/exporting.src.js</li>
            <li>http://github.highcharts.com/v2.2.0/adapters/mootools-adapter.src.js</li>
            <li>http://github.highcharts.com/v2.2.0/adapters/prototype-adapter.src.js</li>
        </ul>


    </body>
</html>
