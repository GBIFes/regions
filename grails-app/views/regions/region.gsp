<%@ page import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="ala" />
        <title>${region.name} | Atlas of Living Australia</title>
        <link rel="stylesheet" href="${ConfigurationHolder.config.grails.serverURL}/css/regions.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="http://biocache.ala.org.au/static/css/ala/biocache.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="http://biocache.ala.org.au/static/css/base.css" type="text/css" media="screen" />
        <script type="text/javascript" language="javascript" src="http://www.google.com/jsapi"></script>
        <script type="text/javascript" src="http://collections.ala.org.au/js/charts.js"></script>
        <g:javascript library="jquery.jsonp-2.1.4.min"/>
        <g:javascript library="jquery.cookie" />
        <g:javascript library="region" />
        <g:javascript library="wms" />
        <g:javascript library="number-functions" />
        <g:javascript library="jquery.ba-bbq.min" />
        <script src="http://maps.google.com/maps/api/js?v=3.5&sensor=false"></script>
        <g:javascript library="keydragzoom" />
        <script type="text/javascript">
          var altMap = true;
          $(document).ready(function() {
            $('#nav-tabs > ul').tabs();
            greyInitialValues();
          });
        </script>
    </head>
    <body>
    <div id="content">
      <div id="header">
        <!--Breadcrumbs-->
        <div id="breadcrumb">
          <a href="${ConfigurationHolder.config.ala.baseURL}">Home</a>
          <a href="${ConfigurationHolder.config.ala.baseURL}/explore/">Explore</a>
          <a href="${ConfigurationHolder.config.grails.serverURL}/regions">Regions</a>
          %{--TODO: do the following in a tag to support any depth --}%
          <g:if test="${region.parent}">
              <a href="${ConfigurationHolder.config.grails.serverURL}/${region.parent.type}/${region.parent.name}">${region.parent.name}</a>
              <g:if test="${region.parent.child}">
                  <a href="${ConfigurationHolder.config.grails.serverURL}/${region.parent.child.type}/${region.parent.child.name}">${region.parent.child.name}</a>
              </g:if>
          </g:if>
          <span class="current">${region.name}</span></div>
        <div class="section full-width">
          <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
          </g:if>
          <div class="hrgroup">
            <h1>${region.name}</h1>
            <div id="emblems"></div>
          </div><!--close hrgroup-->

        </div><!--close section-->
      </div><!--close header-->

        <g:if test="${region.description || region.notes}">
            <div class="section">
              <h2>Description</h2>
              <g:if test="${region.description}"><p>${region.description}</p></g:if>
              <g:if test="${region.notes}"><h3>Notes on the map layer</h3><p>${region.notes}</p></g:if>
            </div>
        </g:if>

        <div class="section">
          <h2 id="occurrenceRecords">Occurrence records</h2>

          <div id="taxonomy"><h3>Explore by taxonomy</h3><div id="charts"></div></div>

          <div id="species">
              <h3>Explore by species</h3>
              <span id="viewRecords" class="link under">View all records</span>
              <span id="viewImages" class="link under">View images for all species</span>
              <span id="downloadRecords" class="link under">Download records</span>
              <div id="taxaBox">
                  <div id="rightList" class="tableContainer">
                      <table>
                          <thead class="fixedHeader">
                          <tr>
                              <th>&nbsp;</th>
                              <th>Species</th>
                              <th>Records</th>
                          </tr>
                          </thead>
                          <tbody class="scrollContent">
                          </tbody>
                      </table>
                  </div>

                  <div id="leftList">
                      <table id="taxa-level-0">
                          <thead>
                          <tr>
                              <th>Group</th>
                              <th>Species</th>
                          </tr>
                          </thead>
                          <tbody>

                          </tbody>
                      </table>
                  </div>
              </div>
          </div>

        </div><!--close section-->

        <div id="subRegions" class="section">
            <h2>Regions within ${region.name}</h2>
            <g:if test="${subRegions.ibras}">
                <h3>Biogeographic (IBRA)</h3>
                <ul>
                    <g:each in="${subRegions.ibras}" var="r">
                        <li><g:link action="region" params="[regionType:'ibras',regionName:r]">${r}</g:link></li>
                    </g:each>
                </ul>
            </g:if>
            <g:if test="${subRegions.nrms}">
                <h3>Natural Resource Management (NRM)</h3>
                <ul>
                    <g:each in="${subRegions.nrms}" var="r">
                        <li><g:link action="region" params="[regionType:'nrms',regionName:r]">${r}</g:link></li>
                    </g:each>
                </ul>
            </g:if>
            <g:if test="${subRegions.imcras}">
                <h3>Marine and Coastal (IMCRA)</h3>
                <ul>
                    <g:each in="${subRegions.imcras}" var="r">
                        <li><g:link action="region" params="[regionType:'imcras',regionName:r]">${r}</g:link></li>
                    </g:each>
                </ul>
            </g:if>
            <g:if test="${subRegions.subs}">
                <h3>Administrative</h3>
                <ul>
                    <g:each in="${subRegions.subs}" var="r">
                        <li><g:link action="region" params="[regionType:'layer',regionName:r,parent:region.name]">${r}</g:link></li>
                    </g:each>
                </ul>
            </g:if>
        </div>
        <div id="map" class="section">
            <div id="region-map-container">
                <div id="region-map"></div>
                <div id="controls">

                    <div>
                        <div class="tish">
                        <label for="toggleOccurrences">
                            <input type="checkbox" name="occurrences" id="toggleOccurrences" value="1" checked/>
                        Occurrences</label></div>
                        <div id="occurrencesOpacity"> </div>
                    </div>

                    <div>
                        <div class="tish">
                        <label for="toggleRegion">
                            <input type="checkbox" name="region" id="toggleRegion" value="1" checked/>
                        Region</label></div>
                        <div id="regionOpacity"> </div>
                    </div>
                </div>
                <div>LatLng: <span id="location"> </span></div>
                <div><span id="bbox"> </span></div>
            </div>
        </div>

    </div><!--close content-->

    <script type="text/javascript">
        var bieUrl = "${ConfigurationHolder.config.bie.baseURL}";
        var baseUrl = "${ConfigurationHolder.config.grails.serverURL}";
        var showMap = ${region.name == 'Great Eastern Ranges'};

        var $emblems = $('#emblems');
        function showEmblem(emblemType, guid) {
            if (guid == "") return;
            // call the bie to get details
            $.ajax({
              url: bieUrl + "species/moreInfo/" + guid + ".json",
              dataType: 'jsonp',
              error: function() {
                cleanUp();
              },
              success: function(data) {
                  var imageSrc = "http://biocache.ala.org.au/static/images/noImage85.jpg";
                  if (data.images && data.images.length > 0) {
                      imageSrc = data.images[0].thumbnail;
                  }
                  var sciName = data.taxonConcept.nameString;
                  var commonName = "";
                  if (data.commonNames && data.commonNames.length > 0) {
                      commonName = data.commonNames[0].nameString;
                  }
                  var link = bieUrl + "species/" + guid;
                  var frag =
                  '<div class="emblem">' +
                  '<a id="' + makeId(emblemType) + '" href="' + link + '"><img src="' + imageSrc + '" class="emblemThumb" alt="' +
                  sciName + ' image"/></a>' +
                  '<h3>' + emblemType + '</h3>' +
                  '<div id="' + makeId(emblemType) + '"><i>' + sciName + '</i><br> ' + commonName + '</div>' +
                  '</div>';
                  $emblems.append($(frag));
              }
            });
        }
        var query = buildRegionFacet("${region.type}","${region.name}");
        var taxonomyChartOptions = {
            query: query,
            rank: "kingdom",
            width: 400
        }

        var extent = {lat: ${region.extent?.lat},
                      lon: ${region.extent?.lon},
                      zoom: ${region.extent?.zoom} };

        var bbox = {sw: {lat: ${region.bbox.minLat}, lng: ${region.bbox.minLng}},
                    ne: {lat: ${region.bbox.maxLat}, lng: ${region.bbox.maxLng}} };

        // Load Google maps via AJAX API
//        google.load("maps", "3.3", {other_params:"sensor=false"});
        // load visualisations
        google.load("visualization", "1", {packages:["corechart"]});
        // do stuff
        google.setOnLoadCallback(function() {
            showEmblem("Bird emblem", "${emblems?.birdEmblem}");
            showEmblem("Animal emblem", "${emblems?.animalEmblem}");
            showEmblem("Plant emblem", "${emblems?.plantEmblem}");
            showEmblem("Marine emblem", "${emblems?.marineEmblem}");

            loadTaxonomyChart(taxonomyChartOptions);

            initTaxaBox("${region.type}","${region.name}");

            initRegionMap("${region.type}", "${region.name}", "${region.layerName}", extent, bbox);
        });

    </script>
  </body>
</html>