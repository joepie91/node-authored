var authored = require("../lib/");
var $ = require("jquery");

var stage = new authored();
stage.use(require("../lib/layers"));
stage.use(require("../lib/layer-panel"));
stage.use(require("../lib/scene-panel"));
stage.use(require("../lib/object-panel"));
stage.use(require("../lib/property-panel"));
stage.use(require("../lib/object-type-text"));
stage.use(require("../lib/object-type-image"));
stage.use(require("../lib/html-renderer"));

$(function(){
	stage.plugins.layerPanel.attach($(".layers"));
	stage.plugins.scenePanel.attach($(".scenes"));
	stage.plugins.objectPanel.attach($(".objects"));
	stage.plugins.propertyPanel.attach($(".properties"));
	stage.plugins.htmlRenderer.attach($(".renderer"));
});
