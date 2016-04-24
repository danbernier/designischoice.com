---
layout: project
category: project
title: Fractal Circles
event: Re:Generate 2014
when: 2014-08
permalink: /projects/fractal-circles
---

[_Originally posted on invisibleblocks.com_](http://invisibleblocks.com/2015/12/12/fractal-circles/)

In August of 2014, I participated in [Re:GENERATE](http://grovenewhaven.com/art-of-code-regenerate/), a show featuring computer-generated art. I made, among other things, a generative series for the event, that I named Fractal Circles.

<div class='gallery'>
  <img src="02.png" />
  <img src="03.png" />
  <img src="04.png" />
  <img src="05.png" />
  <img src="06.png" />
  <img src="07.png" />
  <img src="08.png" />
  <img src="09.png" />
  <img src="10.png" />
  <img src="11.png" />
  <img src="12.png" />
  <img src="13.png" />
  <img src="14.png" />
</div>

It's a simple recursive algorithm over a region of the sketch:

* Should we recurse?
  * Yes, recurse:
    * Is the region we're looking at wider than tall? (The first time, this is the whole sketch.)
      * Yes: split it into halves, vertically, and recurse into it.
      * No: split it into halves, horizontally, and recurse into it.
  * No, stop recursing:
    * Should we draw a circle in this region?
      * Yes: pick a circle type (solid or hollow) and draw it.

This generates a surprisingly wide variety of shapes, some very natural-looking. 

There are three open-ended questions: 

* Should we recurse?
* Should we draw a circle?
* What kind of circle?

If you decide to recurse every other time, and always draw a circle, and alternate the circles types, you get this image, which I made to help explain:

<img src="explanation.png" />

If you let yourself pick the _type_ of circle randomly, you're left with two questions: whether to recurse, and whether to draw a circle. Answering those questions randomly, and controlling their probability, can generate whole families of images. 

Here are 144 tiny fractal circle images. The probability of recursing decreases as we move from left to right, and the probability of drawing a circle increases as we move from top to bottom.

<img src="orthogonalities.png" class='box-shadow' />



Here's a [p5.js](http://p5js.org/) version of it, where the probabilty-to-recurse increases as the hour passes, and the probability-to-draw increases as the minute passes:

<div id='sketchHolder' class='box-shadow'></div>

<script id='sketchSource'>
function Circle(sizePercent) {
  this.strokeWeightPercentOfSize = sizePercent;

  this.draw = function(top, left, size) {
    var halfSize = size * 0.5;
    var centerX = top + halfSize;
    var centerY = left + halfSize;
    var outerSize = size * 0.95;
    var innerSize = size * (1-this.strokeWeightPercentOfSize);
    
    ellipseMode(CENTER);
    fill(0);
    ellipse(centerX, centerY, outerSize, outerSize);
    fill(255);
    ellipse(centerX, centerY, innerSize, innerSize);
  }
}

function setup() {
  createCanvas(680, 720);
  $('#sketchHolder').append($('#defaultCanvas0'));

  noStroke();
  frameRate(2);
};

function draw() {
  pStopRecursing = norm(minute(), 59, 0); //0.35;
  pDrawACircle = norm(second(), 0, 59); // 0.15;

  background(255);
  recurse(20, 20, 680-40, 680-40);

  fill(0);
  textAlign(CENTER);
  text("Current time: " + nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2), width/2, height-60);
  text("Chance of drawing: " + second() + "/60 = " + nf(pDrawACircle, 1, 3), width/2, height-40);
  text("Chance of recursing: " + minute() + "/60 = " + nf((1-pStopRecursing), 1, 3), width/2, height-20);
};

var pickACircle = (function() {
  var thin = new Circle(0.15);
  var thick = new Circle(1 - (0.85 * 0.5));
  var solid = new Circle(1);
  var choices = [thick, solid];

  return function() {
    return choices[floor(random(choices.length))];
  }
})();

var pStopRecursing = 0.35;
var pDrawACircle = 0.15;

function recurse(left, top, right, bottom) {
  var minSize = 12;
  var wide = right - left;
  var high = bottom - top;
  
  if (random(1) < pStopRecursing || wide < minSize || high < minSize) {
    if (random(1) < pDrawACircle) {
      pickACircle().draw(left, top, wide);
    }
  } 
  else {
    if (wide >= high) {
      var middle = (right + left) * 0.5;
      recurse(left, top, middle, bottom);
      recurse(middle, top, right, bottom);
    } else {
      var middle = (top + bottom) * 0.5;
      recurse(left, top, right, middle);
      recurse(left, middle, right, bottom);
    }
  }
}
</script>
