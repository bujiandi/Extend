//
//  HTTPMIME.swift
//  Basic
//
//  Created by 李招利 on 2018/9/30.
//

import Foundation

extension HTTP {
    
    public enum MIME: RawRepresentable {
        
        case common(MIMEFileExtension)
        case custom(String)
        case unknow
        
        public typealias RawValue = String
        
        public init(rawValue: String) {
            if let mime = MIMEFileExtension(rawValue: rawValue) {
                self = .common(mime)
            } else if rawValue.split(separator: "/").count == 2 {
                self = .custom(rawValue)
            } else {
                self = .unknow
            }
        }
        
        public var rawValue: String {
            switch self {
            case .unknow:           return "application/octet-stream"
            case .custom(let text): return text
            case .common(let mime): return mimeType[mime] ?? "application/octet-stream"
            }
        }
    }
    
    public enum MIMEFileExtension: String {
        case h323 = "323"   // "text/h323",
        case z001 = "001"   // "application/x-001",
        case z301 = "301"   // "application/x-301",
        case z906 = "906"   // "application/x-906",
        case d907 = "907"   // "drawing/907",
        case tif            // "image/tiff",
        case xtif           // "application/x-tif",
        case a11            // "application/x-a11",
        case acp            // "audio/x-mei-aac",
        case ai             // "application/postscript",
        case aif            // "audio/aiff",
        case aifc           // "audio/aiff",
        case aiff           // "audio/aiff",
        case anv            // "application/x-anv",
        case asa            // "text/asa",
        case asf            // "video/x-ms-asf",
        case asp            // "text/asp",
        case asx            // "video/x-ms-asf",
        case au             // "audio/basic",
        case avi            // "video/avi",
        case awf            // "application/vnd.adobe.workflow",
        case biz            // "text/xml",
        case bmp            // "application/x-bmp",
        case bot            // "application/x-bot",
        case c4t            // "application/x-c4t",
        case c90            // "application/x-c90",
        case cal            // "application/x-cals",
        case cat            // "application/vnd.ms-pki.seccat",
        case cdf            // "application/x-netcdf",
        case cdr            // "application/x-cdr",
        case cel            // "application/x-cel",
        case cer            // "application/x-x509-ca-cert",
        case cg4            // "application/x-g4",
        case cgm            // "application/x-cgm",
        case cit            // "application/x-cit",
        case `class`        // "java/*",
        case cml            // "text/xml",
        case cmp            // "application/x-cmp",
        case cmx            // "application/x-cmx",
        case cot            // "application/x-cot",
        case crl            // "application/pkix-crl",
        case crt            // "application/x-x509-ca-cert",
        case csi            // "application/x-csi",
        case css            // "text/css",
        case cut            // "application/x-cut",
        case dbf            // "application/x-dbf",
        case dbm            // "application/x-dbm",
        case dbx            // "application/x-dbx",
        case dcd            // "text/xml",
        case dcx            // "application/x-dcx",
        case der            // "application/x-x509-ca-cert",
        case dgn            // "application/x-dgn",
        case dib            // "application/x-dib",
        case dll            // "application/x-msdownload",
        case doc            // "application/msword",
        case dot            // "application/msword",
        case drw            // "application/x-drw",
        case dtd            // "text/xml",
        case dwf            // "Model/vnd.dwf",
        case xdwf           // "application/x-dwf",
        case dwg            // "application/x-dwg",
        case dxb            // "application/x-dxb",
        case dxf            // "application/x-dxf",
        case edn            // "application/vnd.adobe.edn",
        case emf            // "application/x-emf",
        case eml            // "message/rfc822",
        case ent            // "text/xml",
        case epi            // "application/x-epi",
        case xps            // "application/x-ps",
        case eps            // "application/postscript",
        case postscript     // "application/postscript",
        case etd            // "application/x-ebx",
        case exe            // "application/x-msdownload",
        case fax            // "image/fax",
        case fdf            // "application/vnd.fdf",
        case fif            // "application/fractals",
        case fo             // "text/xml",
        case frm            // "application/x-frm",
        case g4             // "application/x-g4",
        case gbr            // "application/x-gbr",
        case gif            // "image/gif",
        case gl2            // "application/x-gl2",
        case gp4            // "application/x-gp4",
        case hgl            // "application/x-hgl",
        case hmr            // "application/x-hmr",
        case hpg            // "application/x-hpgl",
        case hpl            // "application/x-hpl",
        case hqx            // "application/mac-binhex40",
        case hrf            // "application/x-hrf",
        case hta            // "application/hta",
        case htc            // "text/x-component",
        case htm            // "text/html",
        case html           // "text/html",
        case htt            // "text/webviewhtml",
        case htx            // "text/html",
        case icb            // "application/x-icb",
        case ico            // "image/x-icon",
        case xico           // "application/x-ico",
        case iff            // "application/x-iff",
        case ig4            // "application/x-g4",
        case igs            // "application/x-igs",
        case iii            // "application/x-iphone",
        case img            // "application/x-img",
        case ins            // "application/x-internet-signup",
        case isp            // "application/x-internet-signup",
        case IVF            // "video/x-ivf",
        case java           // "java/*",
        case jfif           // "image/jpeg",
        case xjpe           // "application/x-jpe",
        case jpe            // "image/jpeg",
        case jpeg           // "image/jpeg",
        case jpg            // "image/jpeg",
        case xjpg           // "application/x-jpg",
        case js             // "application/x-javascript",
        case jsp            // "text/html",
        case la1            // "audio/x-liquid-file",
        case lar            // "application/x-laplayer-reg",
        case latex          // "application/x-latex",
        case lavs           // "audio/x-liquid-secure",
        case lbm            // "application/x-lbm",
        case lmsff          // "audio/x-la-lms",
        case ls             // "application/x-javascript",
        case ltr            // "application/x-ltr",
        case m1v            // "video/x-mpeg",
        case m2v            // "video/x-mpeg",
        case m3u            // "audio/mpegurl",
        case m4e            // "video/mpeg4",
        case mac            // "application/x-mac",
        case man            // "application/x-troff-man",
        case math           // "text/xml",
        case mdb            // "application/msaccess",
        case xmdb           // "application/x-mdb"
        case mfp            // "application/x-shockwave-flash",
        case mht            // "message/rfc822",
        case mhtml          // "message/rfc822",
        case mi             // "application/x-mi",
        case mid            // "audio/mid",
        case midi           // "audio/mid",
        case mil            // "application/x-mil",
        case mml            // "text/xml",
        case mnd            // "audio/x-musicnet-download",
        case mns            // "audio/x-musicnet-stream",
        case mocha          // "application/x-javascript",
        case movie          // "video/x-sgi-movie",
        case mp1            // "audio/mp1",
        case mp2            // "audio/mp2",
        case mp2v           // "video/mpeg",
        case mp3            // "audio/mp3",
        case mp4            // "video/mpeg4",
        case mpa            // "video/x-mpg",
        case mpd            // "application/vnd.ms-project",
        case mpe            // "video/x-mpeg",
        case mpeg           // "video/mpg",
        case mpg            // "video/mpg",
        case mpga           // "audio/rn-mpeg",
        case mpp            // "application/vnd.ms-project",
        case mps            // "video/x-mpeg",
        case mpt            // "application/vnd.ms-project",
        case mpv            // "video/mpg",
        case mpv2           // "video/mpeg",
        case mpw            // "application/vnd.ms-project",
        case mpx            // "application/vnd.ms-project",
        case mtx            // "text/xml",
        case mxp            // "application/x-mmxp",
        case net            // "image/pnetvue",
        case nrf            // "application/x-nrf",
        case nws            // "message/rfc822",
        case odc            // "text/x-ms-odc",
        case out            // "application/x-out",
        case p10            // "application/pkcs10",
        case p12            // "application/x-pkcs12",
        case p7b            // "application/x-pkcs7-certificates",
        case p7c            // "application/pkcs7-mime",
        case p7m            // "application/pkcs7-mime",
        case p7r            // "application/x-pkcs7-certreqresp",
        case p7s            // "application/pkcs7-signature",
        case pc5            // "application/x-pc5",
        case pci            // "application/x-pci",
        case pcl            // "application/x-pcl",
        case pcx            // "application/x-pcx",
        case pdf            // "application/pdf",
        case pdx            // "application/vnd.adobe.pdx",
        case pfx            // "application/x-pkcs12",
        case pgl            // "application/x-pgl",
        case pic            // "application/x-pic",
        case pko            // "application/vnd.ms-pki.pko",
        case pl             // "application/x-perl",
        case plg            // "text/html",
        case pls            // "audio/scpls",
        case plt            // "application/x-plt",
        case png            // "image/png",
        case xpng           // "application/x-png",
        case pot            // "application/vnd.ms-powerpoint",
        case ppa            // "application/vnd.ms-powerpoint",
        case ppm            // "application/x-ppm",
        case pps            // "application/vnd.ms-powerpoint",
        case ppt            // "application/vnd.ms-powerpoint",
        case xppt           // "application/x-ppt",
        case pr             // "application/x-pr",
        case prf            // "application/pics-rules",
        case prn            // "application/x-prn",
        case prt            // "application/x-prt",
        case ps             // "application/x-ps",
        case ptn            // "application/x-ptn",
        case pwz            // "application/vnd.ms-powerpoint",
        case r3t            // "text/vnd.rn-realtext3d",
        case ra             // "audio/vnd.rn-realaudio",
        case ram            // "audio/x-pn-realaudio",
        case ras            // "application/x-ras",
        case rat            // "application/rat-file",
        case rdf            // "text/xml",
        case rec            // "application/vnd.rn-recording",
        case red            // "application/x-red",
        case rgb            // "application/x-rgb",
        case rjs            // "application/vnd.rn-realsystem-rjs",
        case rjt            // "application/vnd.rn-realsystem-rjt",
        case rlc            // "application/x-rlc",
        case rle            // "application/x-rle",
        case rm             // "application/vnd.rn-realmedia",
        case rmf            // "application/vnd.adobe.rmf",
        case rmi            // "audio/mid",
        case rmj            // "application/vnd.rn-realsystem-rmj",
        case rmm            // "audio/x-pn-realaudio",
        case rmp            // "application/vnd.rn-rn_music_package",
        case rms            // "application/vnd.rn-realmedia-secure",
        case rmvb           // "application/vnd.rn-realmedia-vbr",
        case rmx            // "application/vnd.rn-realsystem-rmx",
        case rnx            // "application/vnd.rn-realplayer",
        case rp             // "image/vnd.rn-realpix",
        case rpm            // "audio/x-pn-realaudio-plugin",
        case rsml           // "application/vnd.rn-rsml",
        case rt             // "text/vnd.rn-realtext",
        case rtf            // "application/msword",
        case xrtf           // "application/x-rtf",
        case rv             // "video/vnd.rn-realvideo",
        case sam            // "application/x-sam",
        case sat            // "application/x-sat",
        case sdp            // "application/sdp",
        case sdw            // "application/x-sdw",
        case sit            // "application/x-stuffit",
        case slb            // "application/x-slb",
        case sld            // "application/x-sld",
        case slk            // "drawing/x-slk",
        case smi            // "application/smil",
        case smil           // "application/smil",
        case smk            // "application/x-smk",
        case snd            // "audio/basic",
        case sol            // "text/plain",
        case sor            // "text/plain",
        case spc            // "application/x-pkcs7-certificates",
        case spl            // "application/futuresplash",
        case spp            // "text/xml",
        case ssm            // "application/streamingmedia",
        case sst            // "application/vnd.ms-pki.certstore",
        case stl            // "application/vnd.ms-pki.stl",
        case stm            // "text/html",
        case sty            // "application/x-sty",
        case svg            // "text/xml",
        case swf            // "application/x-shockwave-flash",
        case tdf            // "application/x-tdf",
        case tg4            // "application/x-tg4",
        case tga            // "application/x-tga",
        case tiff           // "image/tiff",
        case tld            // "text/xml",
        case top            // "drawing/x-top",
        case torrent        // "application/x-bittorrent",
        case tsd            // "text/xml",
        case txt            // "text/plain",
        case uin            // "application/x-icq",
        case uls            // "text/iuls",
        case vcf            // "text/x-vcard",
        case vda            // "application/x-vda",
        case vdx            // "application/vnd.visio",
        case vml            // "text/xml",
        case vpg            // "application/x-vpeg005",
        case vsd            // "application/vnd.visio",
        case xvsd           // "application/x-vsd",
        case vss            // "application/vnd.visio",
        case vst            // "application/vnd.visio",
        case xvst           // "application/x-vst",
        case vsw            // "application/vnd.visio",
        case vsx            // "application/vnd.visio",
        case vtx            // "application/vnd.visio",
        case vxml           // "text/xml",
        case wav            // "audio/wav",
        case wax            // "audio/x-ms-wax",
        case wb1            // "application/x-wb1",
        case wb2            // "application/x-wb2",
        case wb3            // "application/x-wb3",
        case wbmp           // "image/vnd.wap.wbmp",
        case wiz            // "application/msword",
        case wk3            // "application/x-wk3",
        case wk4            // "application/x-wk4",
        case wkq            // "application/x-wkq",
        case wks            // "application/x-wks",
        case wm             // "video/x-ms-wm",
        case wma            // "audio/x-ms-wma",
        case wmd            // "application/x-ms-wmd",
        case wmf            // "application/x-wmf",
        case wml            // "text/vnd.wap.wml",
        case wmv            // "video/x-ms-wmv",
        case wmx            // "video/x-ms-wmx",
        case wmz            // "application/x-ms-wmz",
        case wp6            // "application/x-wp6",
        case wpd            // "application/x-wpd",
        case wpg            // "application/x-wpg",
        case wpl            // "application/vnd.ms-wpl",
        case wq1            // "application/x-wq1",
        case wr1            // "application/x-wr1",
        case wri            // "application/x-wri",
        case wrk            // "application/x-wrk",
        case ws             // "application/x-ws",
        case ws2            // "application/x-ws",
        case wsc            // "text/scriptlet",
        case wsdl           // "text/xml",
        case wvx            // "video/x-ms-wvx",
        case xdp            // "application/vnd.adobe.xdp",
        case xdr            // "text/xml",
        case xfd            // "application/vnd.adobe.xfd",
        case xfdf           // "application/vnd.adobe.xfdf",
        case xhtml          // "text/html",
        case xls            // "application/vnd.ms-excel",
        case xxls           // "application/x-xls",
        case xlw            // "application/x-xlw",
        case xml            // "text/xml",
        case xpl            // "audio/scpls",
        case xq             // "text/xml",
        case xql            // "text/xml",
        case xquery         // "text/xml",
        case xsd            // "text/xml",
        case xsl            // "text/xml",
        case xslt           // "text/xml",
        case xwd            // "application/x-xwd",
        case x_b            // "application/x-x_b",
        case sis            // "application/vnd.symbian.install",
        case sisx           // "application/vnd.symbian.install",
        case x_t            // "application/x-x_t",
        case ipa            // "application/vnd.iphone",
        case apk            // "application/vnd.android.package-archive",
        case xap            // "application/x-silverlight-app"
    }
    
}



let mimeType:[HTTP.MIMEFileExtension:String] = [
    //        .*（ 二进制流，不知道下载文件类型）:    "application/octet-stream",
    .z001:      "application/x-001",
    .z301:      "application/x-301",
    .h323:      "text/h323",
    .z906:      "application/x-906",
    .d907:      "drawing/907",
    .a11:       "application/x-a11",
    .acp:       "audio/x-mei-aac",
    .ai:        "application/postscript",
    .aif:       "audio/aiff",
    .aifc:      "audio/aiff",
    .aiff:      "audio/aiff",
    .anv:       "application/x-anv",
    .asa:       "text/asa",
    .asf:       "video/x-ms-asf",
    .asp:       "text/asp",
    .asx:       "video/x-ms-asf",
    .au:        "audio/basic",
    .avi:       "video/avi",
    .awf:       "application/vnd.adobe.workflow",
    .biz:       "text/xml",
    .bmp:       "application/x-bmp",
    .bot:       "application/x-bot",
    .c4t:       "application/x-c4t",
    .c90:       "application/x-c90",
    .cal:       "application/x-cals",
    .cat:       "application/vnd.ms-pki.seccat",
    .cdf:       "application/x-netcdf",
    .cdr:       "application/x-cdr",
    .cel:       "application/x-cel",
    .cer:       "application/x-x509-ca-cert",
    .cg4:       "application/x-g4",
    .cgm:       "application/x-cgm",
    .cit:       "application/x-cit",
    .class:     "java/*",
    .cml:       "text/xml",
    .cmp:       "application/x-cmp",
    .cmx:       "application/x-cmx",
    .cot:       "application/x-cot",
    .crl:       "application/pkix-crl",
    .crt:       "application/x-x509-ca-cert",
    .csi:       "application/x-csi",
    .css:       "text/css",
    .cut:       "application/x-cut",
    .dbf:       "application/x-dbf",
    .dbm:       "application/x-dbm",
    .dbx:       "application/x-dbx",
    .dcd:       "text/xml",
    .dcx:       "application/x-dcx",
    .der:       "application/x-x509-ca-cert",
    .dgn:       "application/x-dgn",
    .dib:       "application/x-dib",
    .dll:       "application/x-msdownload",
    .doc:       "application/msword",
    .dot:       "application/msword",
    .drw:       "application/x-drw",
    .dtd:       "text/xml",
    .dwf:       "Model/vnd.dwf",
    .xdwf:      "application/x-dwf",
    .dwg:       "application/x-dwg",
    .dxb:       "application/x-dxb",
    .dxf:       "application/x-dxf",
    .edn:       "application/vnd.adobe.edn",
    .emf:       "application/x-emf",
    .eml:       "message/rfc822",
    .ent:       "text/xml",
    .epi:       "application/x-epi",
    .xps:       "application/x-ps",
    .eps:       "application/postscript",
    .etd:       "application/x-ebx",
    .exe:       "application/x-msdownload",
    .fax:       "image/fax",
    .fdf:       "application/vnd.fdf",
    .fif:       "application/fractals",
    .fo:        "text/xml",
    .frm:       "application/x-frm",
    .g4:        "application/x-g4",
    .gbr:       "application/x-gbr",
    .gif:       "image/gif",
    .gl2:       "application/x-gl2",
    .gp4:       "application/x-gp4",
    .hgl:       "application/x-hgl",
    .hmr:       "application/x-hmr",
    .hpg:       "application/x-hpgl",
    .hpl:       "application/x-hpl",
    .hqx:       "application/mac-binhex40",
    .hrf:       "application/x-hrf",
    .hta:       "application/hta",
    .htc:       "text/x-component",
    .htm:       "text/html",
    .html:      "text/html",
    .htt:       "text/webviewhtml",
    .htx:       "text/html",
    .icb:       "application/x-icb",
    .ico:       "image/x-icon",
    .xico:      "application/x-ico",
    .iff:       "application/x-iff",
    .ig4:       "application/x-g4",
    .igs:       "application/x-igs",
    .iii:       "application/x-iphone",
    .img:       "application/x-img",
    .ins:       "application/x-internet-signup",
    .isp:       "application/x-internet-signup",
    .IVF:       "video/x-ivf",
    .java:      "java/*",
    .jfif:      "image/jpeg",
    .jpe:       "image/jpeg",
    .xjpe:      "application/x-jpe",
    .jpeg:      "image/jpeg",
    .jpg:       "image/jpeg",
    .xjpg:      "application/x-jpg",
    .js:        "application/x-javascript",
    .jsp:       "text/html",
    .la1:       "audio/x-liquid-file",
    .lar:       "application/x-laplayer-reg",
    .latex:     "application/x-latex",
    .lavs:      "audio/x-liquid-secure",
    .lbm:       "application/x-lbm",
    .lmsff:     "audio/x-la-lms",
    .ls:        "application/x-javascript",
    .ltr:       "application/x-ltr",
    .m1v:       "video/x-mpeg",
    .m2v:       "video/x-mpeg",
    .m3u:       "audio/mpegurl",
    .m4e:       "video/mpeg4",
    .mac:       "application/x-mac",
    .man:       "application/x-troff-man",
    .math:      "text/xml",
    .mdb:       "application/msaccess",
    .xmdb:      "application/x-mdb",
    .mfp:       "application/x-shockwave-flash",
    .mht:       "message/rfc822",
    .mhtml:     "message/rfc822",
    .mi:        "application/x-mi",
    .mid:       "audio/mid",
    .midi:      "audio/mid",
    .mil:       "application/x-mil",
    .mml:       "text/xml",
    .mnd:       "audio/x-musicnet-download",
    .mns:       "audio/x-musicnet-stream",
    .mocha:     "application/x-javascript",
    .movie:     "video/x-sgi-movie",
    .mp1:       "audio/mp1",
    .mp2:       "audio/mp2",
    .mp2v:      "video/mpeg",
    .mp3:       "audio/mp3",
    .mp4:       "video/mpeg4",
    .mpa:       "video/x-mpg",
    .mpd:       "application/vnd.ms-project",
    .mpe:       "video/x-mpeg",
    .mpeg:      "video/mpg",
    .mpg:       "video/mpg",
    .mpga:      "audio/rn-mpeg",
    .mpp:       "application/vnd.ms-project",
    .mps:       "video/x-mpeg",
    .mpt:       "application/vnd.ms-project",
    .mpv:       "video/mpg",
    .mpv2:      "video/mpeg",
    .mpw:       "application/vnd.ms-project",
    .mpx:       "application/vnd.ms-project",
    .mtx:       "text/xml",
    .mxp:       "application/x-mmxp",
    .net:       "image/pnetvue",
    .nrf:       "application/x-nrf",
    .nws:       "message/rfc822",
    .odc:       "text/x-ms-odc",
    .out:       "application/x-out",
    .p10:       "application/pkcs10",
    .p12:       "application/x-pkcs12",
    .p7b:       "application/x-pkcs7-certificates",
    .p7c:       "application/pkcs7-mime",
    .p7m:       "application/pkcs7-mime",
    .p7r:       "application/x-pkcs7-certreqresp",
    .p7s:       "application/pkcs7-signature",
    .pc5:       "application/x-pc5",
    .pci:       "application/x-pci",
    .pcl:       "application/x-pcl",
    .pcx:       "application/x-pcx",
    .pdf:       "application/pdf",
    .pdx:       "application/vnd.adobe.pdx",
    .pfx:       "application/x-pkcs12",
    .pgl:       "application/x-pgl",
    .pic:       "application/x-pic",
    .pko:       "application/vnd.ms-pki.pko",
    .pl:        "application/x-perl",
    .plg:       "text/html",
    .pls:       "audio/scpls",
    .plt:       "application/x-plt",
    .png:       "image/png",
    .xpng:      "application/x-png",
    .pot:       "application/vnd.ms-powerpoint",
    .ppa:       "application/vnd.ms-powerpoint",
    .ppm:       "application/x-ppm",
    .pps:       "application/vnd.ms-powerpoint",
    .ppt:       "application/vnd.ms-powerpoint",
    .xppt:      "application/x-ppt",
    .pr:        "application/x-pr",
    .prf:       "application/pics-rules",
    .prn:       "application/x-prn",
    .prt:       "application/x-prt",
    .ps:        "application/postscript",
    .ptn:       "application/x-ptn",
    .pwz:       "application/vnd.ms-powerpoint",
    .r3t:       "text/vnd.rn-realtext3d",
    .ra:        "audio/vnd.rn-realaudio",
    .ram:       "audio/x-pn-realaudio",
    .ras:       "application/x-ras",
    .rat:       "application/rat-file",
    .rdf:       "text/xml",
    .rec:       "application/vnd.rn-recording",
    .red:       "application/x-red",
    .rgb:       "application/x-rgb",
    .rjs:       "application/vnd.rn-realsystem-rjs",
    .rjt:       "application/vnd.rn-realsystem-rjt",
    .rlc:       "application/x-rlc",
    .rle:       "application/x-rle",
    .rm:        "application/vnd.rn-realmedia",
    .rmf:       "application/vnd.adobe.rmf",
    .rmi:       "audio/mid",
    .rmj:       "application/vnd.rn-realsystem-rmj",
    .rmm:       "audio/x-pn-realaudio",
    .rmp:       "application/vnd.rn-rn_music_package",
    .rms:       "application/vnd.rn-realmedia-secure",
    .rmvb:      "application/vnd.rn-realmedia-vbr",
    .rmx:       "application/vnd.rn-realsystem-rmx",
    .rnx:       "application/vnd.rn-realplayer",
    .rp:        "image/vnd.rn-realpix",
    .rpm:       "audio/x-pn-realaudio-plugin",
    .rsml:      "application/vnd.rn-rsml",
    .rt:        "text/vnd.rn-realtext",
    .rtf:       "application/msword",
    .xrtf:      "application/x-rtf",
    .rv:        "video/vnd.rn-realvideo",
    .sam:       "application/x-sam",
    .sat:       "application/x-sat",
    .sdp:       "application/sdp",
    .sdw:       "application/x-sdw",
    .sit:       "application/x-stuffit",
    .slb:       "application/x-slb",
    .sld:       "application/x-sld",
    .slk:       "drawing/x-slk",
    .smi:       "application/smil",
    .smil:      "application/smil",
    .smk:       "application/x-smk",
    .snd:       "audio/basic",
    .sol:       "text/plain",
    .sor:       "text/plain",
    .spc:       "application/x-pkcs7-certificates",
    .spl:       "application/futuresplash",
    .spp:       "text/xml",
    .ssm:       "application/streamingmedia",
    .sst:       "application/vnd.ms-pki.certstore",
    .stl:       "application/vnd.ms-pki.stl",
    .stm:       "text/html",
    .sty:       "application/x-sty",
    .svg:       "text/xml",
    .swf:       "application/x-shockwave-flash",
    .tdf:       "application/x-tdf",
    .tg4:       "application/x-tg4",
    .tga:       "application/x-tga",
    .tif:       "image/tiff",
    .xtif:      "application/x-tif",
    .tiff:      "image/tiff",
    .tld:       "text/xml",
    .top:       "drawing/x-top",
    .torrent:   "application/x-bittorrent",
    .tsd:       "text/xml",
    .txt:       "text/plain",
    .uin:       "application/x-icq",
    .uls:       "text/iuls",
    .vcf:       "text/x-vcard",
    .vda:       "application/x-vda",
    .vdx:       "application/vnd.visio",
    .vml:       "text/xml",
    .vpg:       "application/x-vpeg005",
    .vsd:       "application/vnd.visio",
    .xvsd:      "application/x-vsd",
    .vss:       "application/vnd.visio",
    .vst:       "application/vnd.visio",
    .xvst:      "application/x-vst",
    .vsw:       "application/vnd.visio",
    .vsx:       "application/vnd.visio",
    .vtx:       "application/vnd.visio",
    .vxml:      "text/xml",
    .wav:       "audio/wav",
    .wax:       "audio/x-ms-wax",
    .wb1:       "application/x-wb1",
    .wb2:       "application/x-wb2",
    .wb3:       "application/x-wb3",
    .wbmp:      "image/vnd.wap.wbmp",
    .wiz:       "application/msword",
    .wk3:       "application/x-wk3",
    .wk4:       "application/x-wk4",
    .wkq:       "application/x-wkq",
    .wks:       "application/x-wks",
    .wm:        "video/x-ms-wm",
    .wma:       "audio/x-ms-wma",
    .wmd:       "application/x-ms-wmd",
    .wmf:       "application/x-wmf",
    .wml:       "text/vnd.wap.wml",
    .wmv:       "video/x-ms-wmv",
    .wmx:       "video/x-ms-wmx",
    .wmz:       "application/x-ms-wmz",
    .wp6:       "application/x-wp6",
    .wpd:       "application/x-wpd",
    .wpg:       "application/x-wpg",
    .wpl:       "application/vnd.ms-wpl",
    .wq1:       "application/x-wq1",
    .wr1:       "application/x-wr1",
    .wri:       "application/x-wri",
    .wrk:       "application/x-wrk",
    .ws:        "application/x-ws",
    .ws2:       "application/x-ws",
    .wsc:       "text/scriptlet",
    .wsdl:      "text/xml",
    .wvx:       "video/x-ms-wvx",
    .xdp:       "application/vnd.adobe.xdp",
    .xdr:       "text/xml",
    .xfd:       "application/vnd.adobe.xfd",
    .xfdf:      "application/vnd.adobe.xfdf",
    .xhtml:     "text/html",
    .xls:       "application/vnd.ms-excel",
    .xxls:      "application/x-xls",
    .xlw:       "application/x-xlw",
    .xml:       "text/xml",
    .xpl:       "audio/scpls",
    .xq:        "text/xml",
    .xql:       "text/xml",
    .xquery:    "text/xml",
    .xsd:       "text/xml",
    .xsl:       "text/xml",
    .xslt:      "text/xml",
    .xwd:       "application/x-xwd",
    .x_b:       "application/x-x_b",
    .sis:       "application/vnd.symbian.install",
    .sisx:      "application/vnd.symbian.install",
    .x_t:       "application/x-x_t",
    .ipa:       "application/vnd.iphone",
    .apk:       "application/vnd.android.package-archive",
    .xap:       "application/x-silverlight-app"
]

extension HTTP.MIME {
    
    public static let textXML:HTTP.MIME = .common(.xml)
    public static let textHTML:HTTP.MIME = .common(.html)
    public static let imageJPEG:HTTP.MIME = .common(.jpeg)
    public static let imagePNG:HTTP.MIME = .common(.png)
    
}
