module Lia.Markdown.HTML.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.HTML.Attributes exposing (Parameters, toAttribute)
import Lia.Markdown.HTML.Types exposing (Node(..))
import Svg
import Svg.Attributes exposing (allowReorder, to)


view : (List (Html.Attribute msg) -> List (Html msg) -> Html msg) -> (x -> Html msg) -> Parameters -> Node x -> Html msg
view containerX fn attr obj =
    case obj of
        Node name attrs children ->
            children
                |> List.map fn
                |> Html.node name
                    (attr
                        |> List.append attrs
                        |> toAttribute
                    )

        InnerHtml content ->
            containerX [ Attr.property "innerHTML" <| JE.string content ] []

        OuterHtml name attrs body ->
            Html.node name
                (attr
                    |> List.append attrs
                    |> toAttribute
                )
                [ Html.text body ]

        SvgNode attrs body foreignObjects ->
            Svg.node "svg"
                ((body
                    |> JE.string
                    |> Attr.property "innerHTML"
                 )
                    :: toSvgAttribute attrs
                )
                (foreignObjects
                    |> List.map
                        (\( foreignAttributes, foreignObject ) ->
                            foreignObject
                                |> List.map fn
                                |> Svg.foreignObject (toAttribute foreignAttributes)
                        )
                )



-- Add this to Lia.Markdown.HTML.Attributes module


toSvgAttribute : Parameters -> List (Svg.Attribute msg)
toSvgAttribute params =
    List.map
        (\( key, value ) ->
            case key of
                "accentheight" ->
                    Svg.Attributes.accentHeight value

                "allowreorder" ->
                    Svg.Attributes.allowReorder value

                "arabicform" ->
                    Svg.Attributes.arabicForm value

                "attributename" ->
                    Svg.Attributes.attributeName value

                "attributetype" ->
                    Svg.Attributes.attributeType value

                "autoreverse" ->
                    Svg.Attributes.autoReverse value

                "basefrequency" ->
                    Svg.Attributes.baseFrequency value

                "baseprofile" ->
                    Svg.Attributes.baseProfile value

                "calcmode" ->
                    Svg.Attributes.calcMode value

                "capheight" ->
                    Svg.Attributes.capHeight value

                "clippathunits" ->
                    Svg.Attributes.clipPathUnits value

                "contentscripttype" ->
                    Svg.Attributes.contentScriptType value

                "contentstyletype" ->
                    Svg.Attributes.contentStyleType value

                "diffuseconstant" ->
                    Svg.Attributes.diffuseConstant value

                "edgemode" ->
                    Svg.Attributes.edgeMode value

                "externalresourcesrequired" ->
                    Svg.Attributes.externalResourcesRequired value

                "filterres" ->
                    Svg.Attributes.filterRes value

                "filterunits" ->
                    Svg.Attributes.filterUnits value

                "glyphname" ->
                    Svg.Attributes.glyphName value

                "glyphref" ->
                    Svg.Attributes.glyphRef value

                "gradienttransform" ->
                    Svg.Attributes.gradientTransform value

                "gradientunits" ->
                    Svg.Attributes.gradientUnits value

                "horizadvx" ->
                    Svg.Attributes.horizAdvX value

                "horizoriginx" ->
                    Svg.Attributes.horizOriginX value

                "horizOriginY" ->
                    Svg.Attributes.horizOriginY value

                "in" ->
                    Svg.Attributes.in_ value

                "kernelmatrix" ->
                    Svg.Attributes.kernelMatrix value

                "kernelunitlength" ->
                    Svg.Attributes.kernelUnitLength value

                "keypoints" ->
                    Svg.Attributes.keyPoints value

                "keysplines" ->
                    Svg.Attributes.keySplines value

                "keytimes" ->
                    Svg.Attributes.keyTimes value

                "lengthadjust" ->
                    Svg.Attributes.lengthAdjust value

                "limitingconeangle" ->
                    Svg.Attributes.limitingConeAngle value

                "markerheight" ->
                    Svg.Attributes.markerHeight value

                "markerunits" ->
                    Svg.Attributes.markerUnits value

                "markerwidth" ->
                    Svg.Attributes.markerWidth value

                "maskcontentunits" ->
                    Svg.Attributes.maskContentUnits value

                "maskunits" ->
                    Svg.Attributes.maskUnits value

                "numoctaves" ->
                    Svg.Attributes.numOctaves value

                "overlineposition" ->
                    Svg.Attributes.overlinePosition value

                "overlinethickness" ->
                    Svg.Attributes.overlineThickness value

                "pathlength" ->
                    Svg.Attributes.pathLength value

                "patterncontentunits" ->
                    Svg.Attributes.patternContentUnits value

                "patterntransform" ->
                    Svg.Attributes.patternTransform value

                "patternunits" ->
                    Svg.Attributes.patternUnits value

                "pointorder" ->
                    Svg.Attributes.pointOrder value

                "pointsatx" ->
                    Svg.Attributes.pointsAtX value

                "pointsaty" ->
                    Svg.Attributes.pointsAtY value

                "pointsatz" ->
                    Svg.Attributes.pointsAtZ value

                "preservealpha" ->
                    Svg.Attributes.preserveAlpha value

                "preserveaspectratio" ->
                    Svg.Attributes.preserveAspectRatio value

                "primitiveunits" ->
                    Svg.Attributes.primitiveUnits value

                "refx" ->
                    Svg.Attributes.refX value

                "refy" ->
                    Svg.Attributes.refY value

                "renderingintent" ->
                    Svg.Attributes.renderingIntent value

                "repeatcount" ->
                    Svg.Attributes.repeatCount value

                "repeatdur" ->
                    Svg.Attributes.repeatDur value

                "requiredextensions" ->
                    Svg.Attributes.requiredExtensions value

                "requiredfeatures" ->
                    Svg.Attributes.requiredFeatures value

                "specularconstant" ->
                    Svg.Attributes.specularConstant value

                "specularexponent" ->
                    Svg.Attributes.specularExponent value

                "spreadmethod" ->
                    Svg.Attributes.spreadMethod value

                "startoffset" ->
                    Svg.Attributes.startOffset value

                "stddeviation" ->
                    Svg.Attributes.stdDeviation value

                "stitchtiles" ->
                    Svg.Attributes.stitchTiles value

                "strikethroughposition" ->
                    Svg.Attributes.strikethroughPosition value

                "strikethroughthickness" ->
                    Svg.Attributes.strikethroughThickness value

                "surfacescale" ->
                    Svg.Attributes.surfaceScale value

                "systemlanguage" ->
                    Svg.Attributes.systemLanguage value

                "tablevalues" ->
                    Svg.Attributes.tableValues value

                "targetx" ->
                    Svg.Attributes.targetX value

                "targety" ->
                    Svg.Attributes.targetY value

                "textlength" ->
                    Svg.Attributes.textLength value

                "type" ->
                    Svg.Attributes.type_ value

                "underlineposition" ->
                    Svg.Attributes.underlinePosition value

                "underlinethickness" ->
                    Svg.Attributes.underlineThickness value

                "unicoderange" ->
                    Svg.Attributes.unicodeRange value

                "unitsperem" ->
                    Svg.Attributes.unitsPerEm value

                "valphabetic" ->
                    Svg.Attributes.vAlphabetic value

                "vhanging" ->
                    Svg.Attributes.vHanging value

                "videographic" ->
                    Svg.Attributes.vIdeographic value

                "vmathematical" ->
                    Svg.Attributes.vMathematical value

                "vertadvy" ->
                    Svg.Attributes.vertAdvY value

                "vertoriginx" ->
                    Svg.Attributes.vertOriginX value

                "vertoriginy" ->
                    Svg.Attributes.vertOriginY value

                "viewbox" ->
                    Svg.Attributes.viewBox value

                "viewtarget" ->
                    Svg.Attributes.viewTarget value

                "xheight" ->
                    Svg.Attributes.xHeight value

                "xchannelselector" ->
                    Svg.Attributes.xChannelSelector value

                "xlinkactuate" ->
                    Svg.Attributes.xlinkActuate value

                "xlinkarcrole" ->
                    Svg.Attributes.xlinkArcrole value

                "xlinkHref" ->
                    Svg.Attributes.xlinkHref value

                "xlinkrole" ->
                    Svg.Attributes.xlinkRole value

                "xlinkshow" ->
                    Svg.Attributes.xlinkShow value

                "xlinktitle" ->
                    Svg.Attributes.xlinkTitle value

                "xlinktype" ->
                    Svg.Attributes.xlinkType value

                "xmlbase" ->
                    Svg.Attributes.xmlBase value

                "xmllang" ->
                    Svg.Attributes.xmlLang value

                "xmlspace" ->
                    Svg.Attributes.xmlSpace value

                "ychannelselector" ->
                    Svg.Attributes.yChannelSelector value

                "zoomandpan" ->
                    Svg.Attributes.zoomAndPan value

                "alignmentbaseline" ->
                    Svg.Attributes.alignmentBaseline value

                "baselineshift" ->
                    Svg.Attributes.baselineShift value

                "clippath" ->
                    Svg.Attributes.clipPath value

                "cliprule" ->
                    Svg.Attributes.clipRule value

                "colorinterpolationfilters" ->
                    Svg.Attributes.colorInterpolationFilters value

                "colorinterpolation" ->
                    Svg.Attributes.colorInterpolation value

                "colorprofile" ->
                    Svg.Attributes.colorProfile value

                "colorrendering" ->
                    Svg.Attributes.colorRendering value

                "dominantbaseline" ->
                    Svg.Attributes.dominantBaseline value

                "enablebackground" ->
                    Svg.Attributes.enableBackground value

                "fillopacity" ->
                    Svg.Attributes.fillOpacity value

                "fillrule" ->
                    Svg.Attributes.fillRule value

                "floodcolor" ->
                    Svg.Attributes.floodColor value

                "floodopacity" ->
                    Svg.Attributes.floodOpacity value

                "fontfamily" ->
                    Svg.Attributes.fontFamily value

                "fontsizeadjust" ->
                    Svg.Attributes.fontSizeAdjust value

                "fontsize" ->
                    Svg.Attributes.fontSize value

                "fontstretch" ->
                    Svg.Attributes.fontStretch value

                "fontstyle" ->
                    Svg.Attributes.fontStyle value

                "fontvariant" ->
                    Svg.Attributes.fontVariant value

                "fontweight" ->
                    Svg.Attributes.fontWeight value

                "glyphorientationhorizontal" ->
                    Svg.Attributes.glyphOrientationHorizontal value

                "glyphorientationvertical" ->
                    Svg.Attributes.glyphOrientationVertical value

                "imagerendering" ->
                    Svg.Attributes.imageRendering value

                "letterspacing" ->
                    Svg.Attributes.letterSpacing value

                "lightingcolor" ->
                    Svg.Attributes.lightingColor value

                "markerend" ->
                    Svg.Attributes.markerEnd value

                "markermid" ->
                    Svg.Attributes.markerMid value

                "markerstart" ->
                    Svg.Attributes.markerStart value

                "pointerevents" ->
                    Svg.Attributes.pointerEvents value

                "shaperendering" ->
                    Svg.Attributes.shapeRendering value

                "stopcolor" ->
                    Svg.Attributes.stopColor value

                "stopopacity" ->
                    Svg.Attributes.stopOpacity value

                "strokedasharray" ->
                    Svg.Attributes.strokeDasharray value

                "strokedashoffset" ->
                    Svg.Attributes.strokeDashoffset value

                "strokelinecap" ->
                    Svg.Attributes.strokeLinecap value

                "strokelinejoin" ->
                    Svg.Attributes.strokeLinejoin value

                "strokemiterlimit" ->
                    Svg.Attributes.strokeMiterlimit value

                "strokeopacity" ->
                    Svg.Attributes.strokeOpacity value

                "strokewidth" ->
                    Svg.Attributes.strokeWidth value

                "textanchor" ->
                    Svg.Attributes.textAnchor value

                "textdecoration" ->
                    Svg.Attributes.textDecoration value

                "textrendering" ->
                    Svg.Attributes.textRendering value

                "unicodebidi" ->
                    Svg.Attributes.unicodeBidi value

                "wordspacing" ->
                    Svg.Attributes.wordSpacing value

                "writingmode" ->
                    Svg.Attributes.writingMode value

                -- Add other SVG-specific attributes
                _ ->
                    Attr.attribute key value
        )
        params
