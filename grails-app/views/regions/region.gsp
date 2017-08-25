<%@ page import="org.grails.encoder.impl.HTMLEncoder" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

    <meta name="breadcrumbParent" content="${grailsApplication.config.breadcrumbParent}"/>
    <meta name="breadcrumbs" content="${g.createLink(uri: '/', absolute: true)},Regions"/>
    <meta name="breadcrumb" content="${region.name}"/>

    <asset:script type="text/javascript">
        var REGION_CONFIG = {
            regionName: '${region.name}',
            regionType: '${region.type}',
            regionFid: '${region.fid}',
            regionPid: '${region.pid}',
            regionLayerName: '${region.layerName}',
            urls: {
                regionsApp: '${g.createLink(uri: '/', absolute: true)}',
                proxyUrl: '${g.createLink(controller: 'proxy', action: 'index')}',
                proxyUrlBbox: '${g.createLink(controller: 'proxy', action: 'bbox')}',
                speciesPageUrl: "${grailsApplication.config.bie.baseURL}/species/",
                biocacheServiceUrl: "${grailsApplication.config.biocacheService.baseURL}",
                biocacheWebappUrl: "${grailsApplication.config.biocache.baseURL}",
                spatialWmsUrl: "${grailsApplication.config.geoserver.baseURL}/ALA/wms?",
                spatialCacheUrl: "${grailsApplication.config.geoserver.baseURL}/gwc/service/wms?",
                spatialServiceUrl: "${grailsApplication.config.layersService.baseURL}/",
            },
            username: '${rg.loggedInUsername()}',
            q: '${region.q}'
        <g:if test="${enableQueryContext}">
            ,qc: "${grailsApplication.config.biocache.queryContext}"
        </g:if>
        ,hubFilter: "${raw((enableHubData ? grailsApplication.config.hub.hubFilter : '') + grailsApplication.config.biocache.filter)}"
            ,enableHubData: ${enableHubData ?: false}
        <g:if test="${enableHubData}">
            ,showHubData: ${hubState}
        </g:if>
        ,bbox: {
            sw: {
                lat: ${region.bbox?.minLat},
                    lng: ${region.bbox?.minLng}
        },
        ne: {
            lat: ${region.bbox?.maxLat},
                        lng: ${region.bbox?.maxLng}
        }
    }
    ,useReflectService: ${useReflect}
        ,enableRegionOverlay: ${enableRegionOverlay != null ? enableRegionOverlay : 'true'}
        };
    </asset:script>

    <meta name="layout" content="${grailsApplication.config.skin.layout ?: 'main'}"/>
    <title>${region.name} | ${grailsApplication.config.orgNameLong}</title>
    <script src="${g.createLink(controller: 'data', action: 'regionsMetadataJavascript')}"></script>

    <script src="https://maps.google.com/maps/api/js?key=${grailsApplication.config.google.apikey}"></script>
    <script src="https://www.gstatic.com/charts/loader.js"></script>

    <asset:javascript src="application"/>
    <asset:stylesheet src="application"/>
    <asset:javascript src="regions_app" asset-defer="true"/>
    <asset:javascript src="region_page" asset-defer="true"/>
</head>

<body class="nav-locations regions">
<g:set var="enableQueryContext" value="${grailsApplication.config.biocache.enableQueryContext?.toBoolean()}"></g:set>
<g:set var="enableHubData" value="${grailsApplication.config.hub.enableHubData?.toBoolean()}"></g:set>
<g:set var="hubState" value="${true}"></g:set>
<div class="row">
    <div class="col-md-12">
        <div class="pull-right">
            <div class="row">
                <a id="alertsButton" class="btn btn-ala pull-right" href="${alertsUrl}">
                    Alerts
                    <i class="icon-bell icon-white"></i>
                </a>
            </div>
        </div>
    </div>
</div>

<div class="row" id="emblemsContainer">
    <div class="col-md-12">
        <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
        </g:if>
        <h1>${region.name}</h1>
        <aa:zone id="emblems"
                 href="${g.createLink(controller: 'region', action: 'showEmblems', params: [regionType: region.type, regionName: region.name, regionPid: region.pid])}">
            <i class="fa fa-cog fa-spin fa-2x"></i>
        </aa:zone>
    </div>
</div>

<div class="row">
    <div class="col-md-8">
        <g:if test="${region.description || region.notes}">
            <section class="section">
                <h2>Description</h2>
                <g:if test="${region.description}"><p>${raw(region.description)}</p></g:if>
                <g:if test="${region.notes}"><h3>Notes on the map layer</h3>

                    <p>${region.notes}</p></g:if>
            </section>
        </g:if>

        <h3 id="occurrenceRecords" class="">Occurrence records <span id="totalRecords"></span></h3>

        <h3 id="speciesCountLabel" class="">Number of species <span id="speciesCount"></span></h3>
    </div>
    <g:if test="${enableHubData}">
        <div class="switch-padding col-md-4">
            <span class="pull-right">
                Toggle: All / MDBA records <input type="checkbox" name="hub-toggle" ${hubState ? "" : "checked"}>
            </span>
        </div>
    </g:if>
</div>

<div class="row">
    <div class="col-md-6">
        <ul class="nav nav-tabs" id="explorerTabs">
            <li class="active"><a id="speciesTab" href="#speciesTabContent" data-toggle="tab">Explore by species <i
                    class="fa fa-cog fa-spin fa-lg hidden"></i></a></li>
            <li><a id="taxonomyTab" href="#taxonomyTabContent" data-toggle="tab">Explore by taxonomy <i
                    class="fa fa-cog fa-spin fa-lg hidden"></i></a></li>
        </ul>

        <div class="tab-content">
            <div class="tab-pane active" id="speciesTabContent">
                <table id="groups"
                       tagName="tbody"
                       class="table table-condensed table-hover"
                       aa-href="${g.createLink(controller: 'region', action: 'showGroups', params: [regionFid: region.fid, regionType: region.type, regionName: region.name, regionPid: region.pid])}"
                       aa-js-before="setHubConfig();"
                       aa-js-after="regionWidget.groupsLoaded();"
                       aa-refresh-zones="groupsZone"
                       aa-queue="abort">
                    <thead>
                    <tr>
                        <th class="text-center">Group</th>
                    </tr>
                    </thead>
                    <tbody id="groupsZone" tagName="tbody">
                    <tr class="spinner">
                        <td class="spinner text-center">
                            <i class="fa fa-cog fa-spin fa-2x"></i>
                        </td>
                    </tr>
                    </tbody>
                </table>
                <table class="table table-condensed table-hover" id="species">
                    <thead>
                    <tr>
                        <th colspan="2" class="text-center">Species</th>
                        <th class="text-right">Records</th>
                    </tr>
                    </thead>
                    <aa:zone id="speciesZone" tag="tbody" jsAfter="regionWidget.speciesLoaded();">
                        <tr class="spinner">
                            <td colspan="3" class="spinner text-center">
                                <i class="fa fa-cog fa-spin fa-2x"></i>
                            </td>
                        </tr>
                    </aa:zone>
                </table>

                <div id="exploreButtonsZone">

                </div>
            </div>

            <div class="tab-pane" id="taxonomyTabContent">
                <div id="charts">
                    <i class="spinner fa fa-cog fa-spin fa-3x"></i>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-6">

        <ul class="nav nav-tabs" id="controlsMapTab">
            <li class="active">
                <a href="#">Time Controls and Map <i class="fa fa-info-circle fa-lg link" id="timeControlsInfo"
                                                     data-content="Drag handles to restrict date or play by decade."
                                                     data-placement="right" data-toggle="popover"
                                                     data-original-title="How to use time controls"></i></a>
            </li>
        </ul>

        <div id="timeControls" class="text-center">
            <div id="timeButtons">
                <span class="timeControl link" id="playButton" title="Play timeline by decade"
                      alt="Play timeline by decade"></span>
                <span class="timeControl link" id="pauseButton" title="Pause play" alt="Pause play"></span>
                <span class="timeControl link" id="stopButton" title="Stop" alt="Stop"></span>
                <span class="timeControl link" id="resetButton" title="Reset" alt="Reset"></span>
            </div>

            <div id="timeSlider">
                <div id="timeRange"><span id="timeFrom"></span> - <span id="timeTo"></span></div>
            </div>
        </div>

        <div>
            <div id="maploading" class="maploading" hidden>
                <div>
                    <i class="spinner fa fa-cog fa-spin fa-3x" style="margin-top:90px"></i>
                </div>
            </div>

            <div id="region-map">
            </div>
        </div>

        <div class="accordion" id="opacityControls">
            <div class="accordion-group">
                <div class="accordion-heading">
                    <a class="accordion-toggle" data-toggle="collapse" href="#opacityControlsContent">
                        <i class="fa fa-chevron-right"></i>Map opacity controls
                    </a>
                </div>

                <div id="opacityControlsContent" class="accordion-body collapse">
                    <div class="accordion-inner">
                        <label class="checkbox">
                            <input type="checkbox" name="occurrences" id="toggleOccurrences" checked> Occurrences
                        </label>

                        <div id="occurrencesOpacity"></div>
                        <label class="checkbox">
                            <input type="checkbox" name="region" id="toggleRegion" checked> Region
                        </label>

                        <div id="regionOpacity"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<g:if test="${subRegions.size() > 0}">
    <div class="row">
        <div class="col-md-12" id="subRegions">
            <h2>Regions within ${region.name}</h2>
            <g:each in="${subRegions}" var="item">
                <h3>${item.key}</h3>
                <ul>
                    <g:each in="${item.value.list}" var="r">
                        <li><g:link action="region"
                                    params="[regionType: item.value.name, regionName: r, parent: region.name]">${r}</g:link></li>
                    </g:each>
                </ul>
            </g:each>
        </div>
    </div>
</g:if>

</body>
</html>