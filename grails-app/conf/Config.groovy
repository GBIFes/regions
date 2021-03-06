import org.apache.log4j.Level

/******************************************************************************\
 *  CONFIG MANAGEMENT
 \******************************************************************************/
def ENV_NAME = "${appName.toUpperCase()}_CONFIG"
config_dir = "/data/${appName}/config/"
default_config = "/data/${appName}/config/${appName}-config.properties"
if(!grails.config.locations || !(grails.config.locations instanceof List)) {
    grails.config.locations = []
}
if(System.getenv(ENV_NAME) && new File(System.getenv(ENV_NAME)).exists()) {
    println "[${appName}] Including configuration file specified in environment: " + System.getenv(ENV_NAME);
    grails.config.locations.add "file:" + System.getenv(ENV_NAME)
} else if(System.getProperty(ENV_NAME) && new File(System.getProperty(ENV_NAME)).exists()) {
    println "[${appName}] Including configuration file specified on command line: " + System.getProperty(ENV_NAME);
    grails.config.locations.add "file:" + System.getProperty(ENV_NAME)
} else if(new File(default_config).exists()) {
    println "[${appName}] Including default configuration file: " + default_config;
    grails.config.locations.add "file:" + default_config
} else {
    println "[${appName}] No external configuration file defined."
}
println "[${appName}] (*) grails.config.locations = ${grails.config.locations}"

/******************************************************************************\
 *  RELOADABLE CONFIG
 \******************************************************************************/
//reloadable.cfgPollingFrequency = 1000 * 60 * 60 // 1 hour
//reloadable.cfgPollingRetryAttempts = 5
reloadable.cfgs = ["file:/data/${appName}/config/${appName}-config.properties"]

/******************************************************************************\
 *  SKINNING
 \******************************************************************************/
if (!ala.skin) {
    ala.skin = 'ala2';
}
// Defaults used for the breadcrumb if the skin doesn't override them
// Skins should use the prefix: skin.breadcrumb instead of breadcrumb.default.  They can also
// supply a skin.homeURL which will be used as a prefix for the paths.
breadcrumb.default.level1.title='Home'
breadcrumb.default.level1.path=''
breadcrumb.default.level2.title='Explore'
breadcrumb.default.level2.path='/explore/'


grails.project.groupId = 'au.org.ala' // change this to alter the default package name and Maven publishing destination

// The ACCEPT header will not be used for content negotiation for user agents containing the following strings (defaults to the 4 major rendering engines)
grails.mime.disable.accept.header.userAgents = ['Gecko', 'WebKit', 'Presto', 'Trident']
grails.mime.types = [ // the first one is the default format
                      all          : '*/*', // 'all' maps to '*' or the first available format in withFormat
                      atom         : 'application/atom+xml',
                      css          : 'text/css',
                      csv          : 'text/csv',
                      form         : 'application/x-www-form-urlencoded',
                      html         : ['text/html', 'application/xhtml+xml'],
                      js           : 'text/javascript',
                      json         : ['application/json', 'text/json'],
                      multipartForm: 'multipart/form-data',
                      rss          : 'application/rss+xml',
                      text         : 'text/plain',
                      hal          : ['application/hal+json', 'application/hal+xml'],
                      xml          : ['text/xml', 'application/xml']
]

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// What URL patterns should be processed by the resources plugin
grails.resources.adhoc.patterns = ['/js/*', '/images/*', '/css/*', '/plugins/*', '/vendor/*']
grails.resources.adhoc.includes = ['/js/**', '/images/**', '/css/**','/plugins/**', '/vendor/**']


// Legacy setting for codec used to encode data with ${}
grails.views.default.codec = "html"

// The default scope for controllers. May be prototype, session or singleton.
// If unspecified, controllers are prototype scoped.
grails.controllers.defaultScope = 'singleton'

// GSP settings
grails {
    views {
        gsp {
            encoding = 'UTF-8'
            htmlcodec = 'xml' // use xml escaping instead of HTML4 escaping
            codecs {
                expression = 'html' // escapes values inside ${}
                scriptlet = 'html' // escapes output from scriptlets in GSPs
                taglib = 'none' // escapes output from taglibs
                staticparts = 'none' // escapes output from static template parts
            }
        }
        // escapes all not-encoded output at final stage of outputting
        // filteringCodecForContentType.'text/html' = 'html'
    }
}


grails.converters.encoding = "UTF-8"
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []
// whether to disable processing of multi part requests
grails.web.disable.multipart = false

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ['password']

// configure auto-caching of queries by default (if false you can cache individual queries with 'cache: true')
grails.hibernate.cache.queries = false

// configure passing transaction's read-only attribute to Hibernate session, queries and criterias
// set "singleSession = false" OSIV mode in hibernate configuration after enabling
grails.hibernate.pass.readonly = false
// configure passing read-only to OSIV session by default, requires "singleSession = false" OSIV mode
grails.hibernate.osiv.readonly = false

def loggingDir = (System.getProperty('catalina.base') ? System.getProperty('catalina.base') + '/logs' : './logs')
def appName = grails.util.Metadata.current.'app.name'
// log4j configuration
log4j = {
// Example of changing the log pattern for the default console
// appender:
    appenders {
        environments {
            production {
                rollingFile name: "tomcatLog", maxFileSize: '1MB', file: "${loggingDir}/${appName}.log", threshold: Level.ERROR, layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")
            }
            development {
                console name: "stdout", layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n"), threshold: Level.DEBUG
            }
            test {
                rollingFile name: "stdout,tomcatLog", maxFileSize: '1MB', file: "/tmp/${appName}", threshold: Level.DEBUG, layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")
            }
        }
    }
    root {
// change the root logger to my tomcatLog file
        error 'tomcatLog'
        warn 'tomcatLog'
        additivity = true
    }

    warn 'au.org.ala.cas.client',
            'grails.spring.BeanBuilder',
            'grails.plugin.webxml',
            'grails.plugin.cache.web.filter',
            'grails.app.services.org.grails.plugin.resource',
            'grails.app.taglib.org.grails.plugin.resource',
            'grails.app.resourceMappers.org.grails.plugin.resource'

    debug 'grails.app'
}

// app specific config
// switch this on to query hub specific data
hub.enableHubData=false
// add hub id here eg. "data_hub_uid:dh10"
hub.hubFilter=""

// switch on query context
biocache.enableQueryContext=false
// add query context eg. 'cl2110:"Murray-Darling Basin Boundary"'
biocache.queryContext=""

// show only regions that intersect with an ALA OBJECT
layers.enableObjectIntersection=false
layers.intersectObject=""

// configuration to show a default layer on the map. This layer is on top of the layers selected from accordion.
// helpful for regions app implementation for a hub.
layers.showQueryContext=false
layers.queryContextName=''
layers.queryContextShortName=''
layers.queryContextDisplayName=''
layers.queryContextFid=''
layers.queryContextBieContext=''
layers.queryContextOrder=''

// do a redirect for downloads - to make use of the biocache downloads plugin for offline downloads
redirectDownloads = false