var gulp = require('gulp');

/* CoffeeScript compile deps */
var path = require('path');
var rename = require('gulp-rename');
var livereload = require('gulp-livereload');
var webpack = require("gulp-webpack");
var sass = require("gulp-sass");
var gutil = require('gulp-util');
var cache = require('gulp-cached');
var remember = require('gulp-remember');
var plumber = require('gulp-plumber');
var nodemon = require("gulp-nodemon");
var jade = require("gulp-jade");
var net = require("net");
var spy = require("through2-spy");


function namedLog(name) {
	return function gutilLog(log) {
		gc = gutil.colors;

		items = ["[- " + gc.magenta(name) + " -]"];

		for(i in arguments) {
			items.push(arguments[i]);
		}

		gutil.log.apply(null, items);
	}
}

tasks = {
	jade: [
		{
			name: "test",
			source: ["./test/test.jade"],
			base: "./test/",
			destination: "./test/"
		}
	],
	sass: [
		{
			name: "test",
			source: ["./test/style.scss"],
			base: "./test/",
			destination: "./test/"
		}
	]
}

function concatName(type, name) {
	return type + "-" + name;
}

for (var type in tasks) {
	var subTasks = tasks[type];

	for (var i in subTasks) {
		var subTask = subTasks[i];

		(function(type, subTask) {
			var taskName = concatName(type, subTask.name);

			gulp.task(taskName, function() {
				var processor;

				switch(type) {
					case "jade":
						processor = jade(/*{locals: require("./templateUtil")}*/);
						break;
					case "sass":
						processor = sass();
						break;
				}

				return gulp.src(subTask.source, {base: subTask.base})
					.pipe(plumber())
					.pipe(cache(taskName))
					.pipe(processor.on('error', gutil.log))
					.pipe(spy.obj(namedLog(taskName)))
					.pipe(remember(taskName))
					.pipe(gulp.dest(subTask.destination));
			});
		})(type, subTask);
	}
}

function checkServerUp(){
	setTimeout(function(){
		var sock = new net.Socket();
		sock.setTimeout(50);
		sock.on("connect", function(){
			console.log("Triggering page reload...");
			livereload.changed("*");
			sock.destroy();
		})
		.on("timeout", checkServerUp)
		.on("error", checkServerUp)
		.connect(5555);
	}, 70);
}

var startupTasks = [];
var watchTasks = [];

for (var type in tasks) {
	var subTasks = tasks[type];

	for (var i in subTasks) {
		var subTask = subTasks[i];
		var taskName = concatName(type, subTask.name);
		startupTasks.push(taskName);
		watchTasks.push([subTask, taskName]);
	}
}

gulp.task('webpack', function(){
	return gulp.src("./test/test.js")
		.pipe(webpack({
			watch: true,
			module: {
				loaders: [{ test: /\.coffee$/, loader: "coffee-loader" }]
			},
			resolve: { extensions: ["", ".web.coffee", ".web.js", ".coffee", ".js"] }
		}))
		.pipe(rename("test-bundle.js"))
		.pipe(gulp.dest("./test/"));
});

gulp.task('watch', function () {
	global.isWatching = true;
	livereload.listen();
	gulp.watch(['./test/*.js', './test/*.html', './test/*.css']).on('change', livereload.changed);

	for (i in watchTasks) {
		task = watchTasks[i];
		gulp.watch(task[0].source, [task[1]]);
	}

	nodemon({script: "./bin/www", ext: "js", delay: 500}).on("start", checkServerUp);
});

startupTasks.push("webpack", "watch");

gulp.task('default', startupTasks);
